import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/dream_jar.dart';
import '../data/dream_jar_repository.dart';

/// Page size for `GET /dream-jar/:id/contributions` (`ux/uiux-spec.md` §1.6:
/// "Paginate/lazy-load using the existing `limit`/`offset` query params").
const int _pageSize = 20;

/// STORY-014 P4 paginated contribution-history state (`ux/uiux-spec.md`
/// §1.6).
sealed class ContributionHistoryState {
  const ContributionHistoryState();
}

class ContributionHistoryLoading extends ContributionHistoryState {
  const ContributionHistoryLoading();
}

/// [hasMore] mirrors the endpoint's own pagination contract: a page shorter
/// than the requested [_pageSize] means there is no next page.
/// [isLoadingMore] gates [ContributionHistoryCubit.loadMore] so a fast
/// double-scroll cannot fire two overlapping next-page requests (mirrors the
/// P2 `addContribution` double-submit guard for the same reason).
/// [loadMoreFailed] surfaces a failed next-page fetch inline without losing
/// the already-loaded [contributions].
class ContributionHistoryLoaded extends ContributionHistoryState {
  const ContributionHistoryLoaded({
    required this.contributions,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Contribution> contributions;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  ContributionHistoryLoaded copyWith({
    List<Contribution>? contributions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) => ContributionHistoryLoaded(
    contributions: contributions ?? this.contributions,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
}

/// AC3: an unpaired user's `fetchContributions` never resolves; render the
/// unpaired notice instead of a bare error.
class ContributionHistoryUnpaired extends ContributionHistoryState {
  const ContributionHistoryUnpaired();
}

/// Any other repository failure on the first page (e.g. network failure).
class ContributionHistoryFailed extends ContributionHistoryState {
  const ContributionHistoryFailed(this.failure);

  final Object failure;
}

class ContributionHistoryCubit extends Cubit<ContributionHistoryState> {
  ContributionHistoryCubit({
    required DreamJarRepository repository,
    required String jarId,
  }) : _repository = repository,
       _jarId = jarId,
       super(const ContributionHistoryLoading());

  final DreamJarRepository _repository;
  final String _jarId;

  Future<void> loadFirstPage() async {
    emit(const ContributionHistoryLoading());
    try {
      final page = await _repository.fetchContributions(
        _jarId,
        limit: _pageSize,
        offset: 0,
      );
      if (!isClosed) {
        emit(
          ContributionHistoryLoaded(
            contributions: page,
            hasMore: page.length == _pageSize,
          ),
        );
      }
    } on DreamJarUnpairedFailure {
      if (!isClosed) emit(const ContributionHistoryUnpaired());
    } catch (failure) {
      if (!isClosed) emit(ContributionHistoryFailed(failure));
    }
  }

  /// Ignored unless the current state has a further page and no next-page
  /// fetch is already in flight.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ContributionHistoryLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final nextPage = await _repository.fetchContributions(
        _jarId,
        limit: _pageSize,
        offset: currentState.contributions.length,
      );
      if (!isClosed) {
        emit(
          ContributionHistoryLoaded(
            contributions: <Contribution>[
              ...currentState.contributions,
              ...nextPage,
            ],
            hasMore: nextPage.length == _pageSize,
          ),
        );
      }
    } catch (failure) {
      if (!isClosed) {
        final latestState = state;
        if (latestState is ContributionHistoryLoaded) {
          emit(
            latestState.copyWith(isLoadingMore: false, loadMoreFailed: true),
          );
        }
      }
    }
  }

  Future<void> deleteContribution(String contributionId) async {
    final currentState = state;
    if (currentState is! ContributionHistoryLoaded) return;

    try {
      await _repository.deleteContribution(
        jarId: _jarId,
        contributionId: contributionId,
      );
      if (!isClosed) {
        emit(
          currentState.copyWith(
            contributions: currentState.contributions
                .where((c) => c.id != contributionId)
                .toList(),
          ),
        );
      }
    } catch (_) {}
  }
}
