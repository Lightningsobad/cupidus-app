# cupid_api.api.Epic5DreamJarApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**dreamJarControllerAddContribution**](Epic5DreamJarApi.md#dreamjarcontrolleraddcontribution) | **POST** /dream-jar/{id}/contributions | Add a contribution to a Dream Jar
[**dreamJarControllerCreate**](Epic5DreamJarApi.md#dreamjarcontrollercreate) | **POST** /dream-jar | Create a new Dream Jar
[**dreamJarControllerFindAll**](Epic5DreamJarApi.md#dreamjarcontrollerfindall) | **GET** /dream-jar | Get all Dream Jars
[**dreamJarControllerFindOne**](Epic5DreamJarApi.md#dreamjarcontrollerfindone) | **GET** /dream-jar/{id} | Get a specific Dream Jar
[**dreamJarControllerGetContributions**](Epic5DreamJarApi.md#dreamjarcontrollergetcontributions) | **GET** /dream-jar/{id}/contributions | Get contribution history of a Dream Jar
[**dreamJarControllerRemove**](Epic5DreamJarApi.md#dreamjarcontrollerremove) | **DELETE** /dream-jar/{id} | Delete a Dream Jar
[**dreamJarControllerUpdate**](Epic5DreamJarApi.md#dreamjarcontrollerupdate) | **PATCH** /dream-jar/{id} | Update a Dream Jar


# **dreamJarControllerAddContribution**
> dreamJarControllerAddContribution(id, addContributionDto)

Add a contribution to a Dream Jar

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5DreamJarApi();
final String id = id_example; // String | 
final AddContributionDto addContributionDto = ; // AddContributionDto | 

try {
    api.dreamJarControllerAddContribution(id, addContributionDto);
} on DioException catch (e) {
    print('Exception when calling Epic5DreamJarApi->dreamJarControllerAddContribution: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **addContributionDto** | [**AddContributionDto**](AddContributionDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dreamJarControllerCreate**
> dreamJarControllerCreate(createDreamJarDto)

Create a new Dream Jar

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5DreamJarApi();
final CreateDreamJarDto createDreamJarDto = ; // CreateDreamJarDto | 

try {
    api.dreamJarControllerCreate(createDreamJarDto);
} on DioException catch (e) {
    print('Exception when calling Epic5DreamJarApi->dreamJarControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createDreamJarDto** | [**CreateDreamJarDto**](CreateDreamJarDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dreamJarControllerFindAll**
> dreamJarControllerFindAll(limit, offset)

Get all Dream Jars

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5DreamJarApi();
final String limit = limit_example; // String | 
final String offset = offset_example; // String | 

try {
    api.dreamJarControllerFindAll(limit, offset);
} on DioException catch (e) {
    print('Exception when calling Epic5DreamJarApi->dreamJarControllerFindAll: $e\n');
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

# **dreamJarControllerFindOne**
> dreamJarControllerFindOne(id)

Get a specific Dream Jar

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5DreamJarApi();
final String id = id_example; // String | 

try {
    api.dreamJarControllerFindOne(id);
} on DioException catch (e) {
    print('Exception when calling Epic5DreamJarApi->dreamJarControllerFindOne: $e\n');
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

# **dreamJarControllerGetContributions**
> dreamJarControllerGetContributions(id, limit, offset)

Get contribution history of a Dream Jar

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5DreamJarApi();
final String id = id_example; // String | 
final String limit = limit_example; // String | 
final String offset = offset_example; // String | 

try {
    api.dreamJarControllerGetContributions(id, limit, offset);
} on DioException catch (e) {
    print('Exception when calling Epic5DreamJarApi->dreamJarControllerGetContributions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
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

# **dreamJarControllerRemove**
> dreamJarControllerRemove(id)

Delete a Dream Jar

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5DreamJarApi();
final String id = id_example; // String | 

try {
    api.dreamJarControllerRemove(id);
} on DioException catch (e) {
    print('Exception when calling Epic5DreamJarApi->dreamJarControllerRemove: $e\n');
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

# **dreamJarControllerUpdate**
> dreamJarControllerUpdate(id, updateDreamJarDto)

Update a Dream Jar

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5DreamJarApi();
final String id = id_example; // String | 
final UpdateDreamJarDto updateDreamJarDto = ; // UpdateDreamJarDto | 

try {
    api.dreamJarControllerUpdate(id, updateDreamJarDto);
} on DioException catch (e) {
    print('Exception when calling Epic5DreamJarApi->dreamJarControllerUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateDreamJarDto** | [**UpdateDreamJarDto**](UpdateDreamJarDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

