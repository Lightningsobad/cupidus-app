# cupid_api.api.Epic4LoveTimelineApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**timelineControllerAddEvent**](Epic4LoveTimelineApi.md#timelinecontrolleraddevent) | **POST** /timeline | Add a manual memory to the timeline
[**timelineControllerDeleteEvent**](Epic4LoveTimelineApi.md#timelinecontrollerdeleteevent) | **DELETE** /timeline/{id} | Delete a timeline event
[**timelineControllerGetTimeline**](Epic4LoveTimelineApi.md#timelinecontrollergettimeline) | **GET** /timeline | Get timeline events


# **timelineControllerAddEvent**
> timelineControllerAddEvent(createTimelineEventDto)

Add a manual memory to the timeline

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4LoveTimelineApi();
final CreateTimelineEventDto createTimelineEventDto = ; // CreateTimelineEventDto | 

try {
    api.timelineControllerAddEvent(createTimelineEventDto);
} on DioException catch (e) {
    print('Exception when calling Epic4LoveTimelineApi->timelineControllerAddEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createTimelineEventDto** | [**CreateTimelineEventDto**](CreateTimelineEventDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **timelineControllerDeleteEvent**
> timelineControllerDeleteEvent(id)

Delete a timeline event

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4LoveTimelineApi();
final String id = id_example; // String | 

try {
    api.timelineControllerDeleteEvent(id);
} on DioException catch (e) {
    print('Exception when calling Epic4LoveTimelineApi->timelineControllerDeleteEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **timelineControllerGetTimeline**
> timelineControllerGetTimeline(limit, offset)

Get timeline events

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4LoveTimelineApi();
final String limit = limit_example; // String | 
final String offset = offset_example; // String | 

try {
    api.timelineControllerGetTimeline(limit, offset);
} on DioException catch (e) {
    print('Exception when calling Epic4LoveTimelineApi->timelineControllerGetTimeline: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **String**|  | 
 **offset** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

