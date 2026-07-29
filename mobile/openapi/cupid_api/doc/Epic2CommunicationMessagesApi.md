# cupid_api.api.Epic2CommunicationMessagesApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**messagesControllerCreate**](Epic2CommunicationMessagesApi.md#messagescontrollercreate) | **POST** /messages | Create a new chat message (fallback for websocket)
[**messagesControllerFindAll**](Epic2CommunicationMessagesApi.md#messagescontrollerfindall) | **GET** /messages | Get messages history


# **messagesControllerCreate**
> messagesControllerCreate()

Create a new chat message (fallback for websocket)

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic2CommunicationMessagesApi();

try {
    api.messagesControllerCreate();
} on DioException catch (e) {
    print('Exception when calling Epic2CommunicationMessagesApi->messagesControllerCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **messagesControllerFindAll**
> messagesControllerFindAll(partnerId, page, limit)

Get messages history

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic2CommunicationMessagesApi();
final String partnerId = partnerId_example; // String | 
final num page = 8.14; // num | 
final num limit = 8.14; // num | 

try {
    api.messagesControllerFindAll(partnerId, page, limit);
} on DioException catch (e) {
    print('Exception when calling Epic2CommunicationMessagesApi->messagesControllerFindAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **partnerId** | **String**|  | 
 **page** | **num**|  | 
 **limit** | **num**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

