# cupid_api.api.Epic6AdminConfigurationsApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminControllerGetAllConfigs**](Epic6AdminConfigurationsApi.md#admincontrollergetallconfigs) | **GET** /admin/config | Get all system configurations
[**adminControllerGetConfig**](Epic6AdminConfigurationsApi.md#admincontrollergetconfig) | **GET** /admin/config/{key} | Get a specific system configuration
[**adminControllerGetMetrics**](Epic6AdminConfigurationsApi.md#admincontrollergetmetrics) | **GET** /admin/metrics | Get system metrics (users, couples, etc.)
[**adminControllerUpdateConfig**](Epic6AdminConfigurationsApi.md#admincontrollerupdateconfig) | **PATCH** /admin/config/{key} | Update a specific system configuration


# **adminControllerGetAllConfigs**
> adminControllerGetAllConfigs()

Get all system configurations

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic6AdminConfigurationsApi();

try {
    api.adminControllerGetAllConfigs();
} on DioException catch (e) {
    print('Exception when calling Epic6AdminConfigurationsApi->adminControllerGetAllConfigs: $e\n');
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

# **adminControllerGetConfig**
> adminControllerGetConfig(key)

Get a specific system configuration

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic6AdminConfigurationsApi();
final String key = key_example; // String | 

try {
    api.adminControllerGetConfig(key);
} on DioException catch (e) {
    print('Exception when calling Epic6AdminConfigurationsApi->adminControllerGetConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminControllerGetMetrics**
> adminControllerGetMetrics()

Get system metrics (users, couples, etc.)

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic6AdminConfigurationsApi();

try {
    api.adminControllerGetMetrics();
} on DioException catch (e) {
    print('Exception when calling Epic6AdminConfigurationsApi->adminControllerGetMetrics: $e\n');
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

# **adminControllerUpdateConfig**
> adminControllerUpdateConfig(key, updateConfigDto)

Update a specific system configuration

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic6AdminConfigurationsApi();
final String key = key_example; // String | 
final UpdateConfigDto updateConfigDto = ; // UpdateConfigDto | 

try {
    api.adminControllerUpdateConfig(key, updateConfigDto);
} on DioException catch (e) {
    print('Exception when calling Epic6AdminConfigurationsApi->adminControllerUpdateConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **updateConfigDto** | [**UpdateConfigDto**](UpdateConfigDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

