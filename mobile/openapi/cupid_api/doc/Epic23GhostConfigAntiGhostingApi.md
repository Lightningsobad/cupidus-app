# cupid_api.api.Epic23GhostConfigAntiGhostingApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**ghostConfigControllerApprove**](Epic23GhostConfigAntiGhostingApi.md#ghostconfigcontrollerapprove) | **PATCH** /ghost-config/{id}/approve | Approve a pending config request
[**ghostConfigControllerCreate**](Epic23GhostConfigAntiGhostingApi.md#ghostconfigcontrollercreate) | **POST** /ghost-config | Create or update Ghost Config (requires partner approval)
[**ghostConfigControllerGetActive**](Epic23GhostConfigAntiGhostingApi.md#ghostconfigcontrollergetactive) | **GET** /ghost-config | Get current active Ghost Config
[**ghostConfigControllerGetPending**](Epic23GhostConfigAntiGhostingApi.md#ghostconfigcontrollergetpending) | **GET** /ghost-config/pending | Get pending (unapproved) Ghost Configs
[**ghostConfigControllerGetStormStatus**](Epic23GhostConfigAntiGhostingApi.md#ghostconfigcontrollergetstormstatus) | **GET** /ghost-config/storm-status/{partnerId} | Check if user is allowed to send an Emoji Storm
[**ghostConfigControllerReject**](Epic23GhostConfigAntiGhostingApi.md#ghostconfigcontrollerreject) | **PATCH** /ghost-config/{id}/reject | Reject a pending config request


# **ghostConfigControllerApprove**
> ghostConfigControllerApprove(id)

Approve a pending config request

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic23GhostConfigAntiGhostingApi();
final String id = id_example; // String | 

try {
    api.ghostConfigControllerApprove(id);
} on DioException catch (e) {
    print('Exception when calling Epic23GhostConfigAntiGhostingApi->ghostConfigControllerApprove: $e\n');
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

# **ghostConfigControllerCreate**
> ghostConfigControllerCreate(createGhostConfigDto)

Create or update Ghost Config (requires partner approval)

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic23GhostConfigAntiGhostingApi();
final CreateGhostConfigDto createGhostConfigDto = ; // CreateGhostConfigDto | 

try {
    api.ghostConfigControllerCreate(createGhostConfigDto);
} on DioException catch (e) {
    print('Exception when calling Epic23GhostConfigAntiGhostingApi->ghostConfigControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createGhostConfigDto** | [**CreateGhostConfigDto**](CreateGhostConfigDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ghostConfigControllerGetActive**
> ghostConfigControllerGetActive()

Get current active Ghost Config

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic23GhostConfigAntiGhostingApi();

try {
    api.ghostConfigControllerGetActive();
} on DioException catch (e) {
    print('Exception when calling Epic23GhostConfigAntiGhostingApi->ghostConfigControllerGetActive: $e\n');
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

# **ghostConfigControllerGetPending**
> ghostConfigControllerGetPending()

Get pending (unapproved) Ghost Configs

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic23GhostConfigAntiGhostingApi();

try {
    api.ghostConfigControllerGetPending();
} on DioException catch (e) {
    print('Exception when calling Epic23GhostConfigAntiGhostingApi->ghostConfigControllerGetPending: $e\n');
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

# **ghostConfigControllerGetStormStatus**
> ghostConfigControllerGetStormStatus(partnerId)

Check if user is allowed to send an Emoji Storm

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic23GhostConfigAntiGhostingApi();
final String partnerId = partnerId_example; // String | 

try {
    api.ghostConfigControllerGetStormStatus(partnerId);
} on DioException catch (e) {
    print('Exception when calling Epic23GhostConfigAntiGhostingApi->ghostConfigControllerGetStormStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **partnerId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ghostConfigControllerReject**
> ghostConfigControllerReject(id)

Reject a pending config request

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic23GhostConfigAntiGhostingApi();
final String id = id_example; // String | 

try {
    api.ghostConfigControllerReject(id);
} on DioException catch (e) {
    print('Exception when calling Epic23GhostConfigAntiGhostingApi->ghostConfigControllerReject: $e\n');
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

