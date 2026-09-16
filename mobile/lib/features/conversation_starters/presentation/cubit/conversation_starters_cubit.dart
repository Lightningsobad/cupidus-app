import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../../core/realtime/backend_user_id_store.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../data/calendar_event_state_repository.dart';
import '../../domain/calendar_event_service.dart';
import '../../domain/starter_content.dart';
import '../../domain/starter_selector.dart';

/// How many lines one round of screen (6) draws (`ux/uiux-spec.md` §2).
///
/// A layout constant, not a pack assumption: a pack shorter than this renders
/// exactly what it ships rather than padding to this number (AC-28).
const int kStartersPerRound = 3;

/// Everything screen (6) draws.
///
/// [page] is the rotation cursor, and it lives here and nowhere else: no Drift
/// row, no `SharedPreferences` key. Leaving the screen forgets it, which is
/// what keeps "where you were in the pack" from becoming a second store
/// (`architecture/solution.md` §4, SC-1').
class ConversationStartersState {
  const ConversationStartersState({
    required this.loading,
    required this.page,
    required this.starters,
    required this.events,
  });

  static const ConversationStartersState initial = ConversationStartersState(
    loading: true,
    page: 0,
    starters: <RenderedStarter>[],
    events: <VisibleCalendarEvent>[],
  );

  final bool loading;
  final int page;
  final List<RenderedStarter> starters;
  final List<VisibleCalendarEvent> events;

  ConversationStartersState _copyWith({
    bool? loading,
    int? page,
    List<RenderedStarter>? starters,
    List<VisibleCalendarEvent>? events,
  }) =>
      ConversationStartersState(
        loading: loading ?? this.loading,
        page: page ?? this.page,
        starters: starters ?? this.starters,
        events: events ?? this.events,
      );
}

/// Screen (6)'s state holder: read the two shipped packs, rank the lines
/// against what the user wrote, and hand an event over to the shared hub.
///
/// It reads no clock — [today] is injected by the entry point — so the same
/// inputs render the same round either side of midnight (AC-17). It writes
/// nothing of its own except the event-handled row the service owns.
class ConversationStartersCubit extends Cubit<ConversationStartersState> {
  ConversationStartersCubit({
    required ContextNotebookReader notebook,
    required ActivityCardRepository cardRepository,
    required CalendarEventStateRepository eventStateRepository,
    required BackendUserIdStore ownerKeyStore,
    required String today,
    ContentPackageLoader loader = const ContentPackageLoader(),
    int perPage = kStartersPerRound,
  })  : _notebook = notebook,
        _cardRepository = cardRepository,
        _eventStateRepository = eventStateRepository,
        _ownerKeyStore = ownerKeyStore,
        _today = today,
        _loader = loader,
        _perPage = perPage,
        super(ConversationStartersState.initial);

  final ContextNotebookReader _notebook;
  final ActivityCardRepository _cardRepository;
  final CalendarEventStateRepository _eventStateRepository;
  final BackendUserIdStore _ownerKeyStore;
  final String _today;
  final ContentPackageLoader _loader;
  final int _perPage;

  ContentPackage<StarterItem>? _starterPackage;
  CalendarEventService? _eventService;
  List<NotebookEntry> _notebookEntries = const <NotebookEntry>[];
  String? _ownerKey;

  Future<void> load() async {
    final ContentPackage<StarterItem> starters =
        _starterPackage ?? await _loadStarters();
    final CalendarEventService service =
        _eventService ?? await _loadEventService();
    final String ownerKey = _ownerKey ?? await _requireOwnerKey();
    final List<NotebookEntry> entries = await _notebook.entries();
    final List<VisibleCalendarEvent> events = await service.visibleEvents(
      ownerKey: ownerKey,
      today: _today,
    );
    if (isClosed) {
      return;
    }

    _starterPackage = starters;
    _eventService = service;
    _ownerKey = ownerKey;
    _notebookEntries = entries;

    emit(
      state._copyWith(
        loading: false,
        starters: _renderPage(state.page),
        events: events,
      ),
    );
  }

  /// The next round of lines. Never disabled, never exhausted: the selector
  /// wraps the window round the eligible pool, so asking again past the end of
  /// the pack lands back at its head with no "đã hết" state in between
  /// (AC-4/AC-27/AC-28).
  void nextPage() {
    final int page = state.page + 1;
    emit(state._copyWith(page: page, starters: _renderPage(page)));
  }

  /// Re-ranks in place after the inline ask card records an answer. Same page,
  /// same screen: answering a question never moves the reader (AC-8).
  Future<void> refreshContext() async {
    final List<NotebookEntry> entries = await _notebook.entries();
    if (isClosed) {
      return;
    }
    _notebookEntries = entries;
    emit(state._copyWith(starters: _renderPage(state.page)));
  }

  /// Hands one event to the shared hub of screen (1) and drops it from the
  /// strip. A second tap on an already-converted event writes no second card —
  /// the service returns null — and the row is gone either way (AC-12).
  Future<void> addEventToStore(VisibleCalendarEvent event) async {
    await _eventService!.addToStore(ownerKey: _ownerKey!, event: event);
    _dropEvent(event.id);
  }

  /// One tap, no confirmation, no reason asked (AC-14).
  Future<void> dismissEvent(VisibleCalendarEvent event) async {
    await _eventService!.dismiss(ownerKey: _ownerKey!, eventId: event.id);
    _dropEvent(event.id);
  }

  void _dropEvent(String eventId) {
    if (isClosed) {
      return;
    }
    emit(
      state._copyWith(
        events: <VisibleCalendarEvent>[
          for (final VisibleCalendarEvent visible in state.events)
            if (visible.id != eventId) visible,
        ],
      ),
    );
  }

  List<RenderedStarter> _renderPage(int page) => StarterSelector.select(
        package: _starterPackage!,
        notebook: _notebookEntries,
        today: _today,
        page: page,
        perPage: _perPage,
      );

  Future<ContentPackage<StarterItem>> _loadStarters() =>
      _loader.load<StarterItem>(
        startersAssetKey,
        expectedSchemaId: startersSchemaId,
        itemParser: starterItemFromJson,
      );

  Future<CalendarEventService> _loadEventService() async {
    final ContentPackage<CalendarEvent> package =
        await _loader.load<CalendarEvent>(
      calendarEventsAssetKey,
      expectedSchemaId: calendarEventsSchemaId,
      itemParser: calendarEventFromJson,
    );
    return CalendarEventService(
      cardRepository: _cardRepository,
      stateRepository: _eventStateRepository,
      package: package,
    );
  }

  Future<String> _requireOwnerKey() async {
    final String? ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'ConversationStartersCubit used before a backend user id resolved.',
      );
    }
    return ownerKey;
  }
}
