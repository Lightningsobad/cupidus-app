# cupid_api.api.Epic3SyncedAlarmsApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**alarmsControllerConfirm**](Epic3SyncedAlarmsApi.md#alarmscontrollerconfirm) | **PATCH** /alarms/{id}/confirm | Confirm alarm time set by partner
[**alarmsControllerCreate**](Epic3SyncedAlarmsApi.md#alarmscontrollercreate) | **POST** /alarms | Create or update synced alarm time
[**alarmsControllerFindOne**](Epic3SyncedAlarmsApi.md#alarmscontrollerfindone) | **GET** /alarms | Get current coupled alarm setup
[**alarmsControllerStop**](Epic3SyncedAlarmsApi.md#alarmscontrollerstop) | **PATCH** /alarms/{id}/stop | Stop alarm while ringing


# **alarmsControllerConfirm**
> alarmsControllerConfirm(id)

Confirm alarm time set by partner

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3SyncedAlarmsApi();
final String id = id_example; // String | 

try {
    api.alarmsControllerConfirm(id);
} on DioException catch (e) {
    print('Exception when calling Epic3SyncedAlarmsApi->alarmsControllerConfirm: $e\n');
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

# **alarmsControllerCreate**
> alarmsControllerCreate(createAlarmDto)

Create or update synced alarm time

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3SyncedAlarmsApi();
final CreateAlarmDto createAlarmDto = ; // CreateAlarmDto | 

try {
    api.alarmsControllerCreate(createAlarmDto);
} on DioException catch (e) {
    print('Exception when calling Epic3SyncedAlarmsApi->alarmsControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAlarmDto** | [**CreateAlarmDto**](CreateAlarmDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **alarmsControllerFindOne**
> alarmsControllerFindOne()

Get current coupled alarm setup

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3SyncedAlarmsApi();

try {
    api.alarmsControllerFindOne();
} on DioException catch (e) {
    print('Exception when calling Epic3SyncedAlarmsApi->alarmsControllerFindOne: $e\n');
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

# **alarmsControllerStop**
> alarmsControllerStop(id)

Stop alarm while ringing

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3SyncedAlarmsApi();
final String id = id_example; // String | 

try {
    api.alarmsControllerStop(id);
} on DioException catch (e) {
    print('Exception when calling Epic3SyncedAlarmsApi->alarmsControllerStop: $e\n');
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

