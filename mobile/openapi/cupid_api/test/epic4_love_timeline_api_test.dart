import 'package:test/test.dart';
import 'package:cupid_api/cupid_api.dart';


/// tests for Epic4LoveTimelineApi
void main() {
  final instance = CupidApi().getEpic4LoveTimelineApi();

  group(Epic4LoveTimelineApi, () {
    // Add a manual memory to the timeline
    //
    //Future timelineControllerAddEvent(CreateTimelineEventDto createTimelineEventDto) async
    test('test timelineControllerAddEvent', () async {
      // TODO
    });

    // Delete a timeline event
    //
    //Future timelineControllerDeleteEvent(String id) async
    test('test timelineControllerDeleteEvent', () async {
      // TODO
    });

    // Get timeline events
    //
    //Future timelineControllerGetTimeline(String limit, String offset) async
    test('test timelineControllerGetTimeline', () async {
      // TODO
    });

  });
}
