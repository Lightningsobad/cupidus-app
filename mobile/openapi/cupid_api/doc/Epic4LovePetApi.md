# cupid_api.api.Epic4LovePetApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**petsControllerAdopt**](Epic4LovePetApi.md#petscontrolleradopt) | **POST** /pets/adopt | Adopt a new Love Pet
[**petsControllerGetPet**](Epic4LovePetApi.md#petscontrollergetpet) | **GET** /pets | Get current Love Pet details
[**petsControllerGetStatus**](Epic4LovePetApi.md#petscontrollergetstatus) | **GET** /pets/status | Get Love Pet dynamic status
[**petsControllerInteract**](Epic4LovePetApi.md#petscontrollerinteract) | **PATCH** /pets/interact | Interact with the Love Pet (feed/play) to increase happiness


# **petsControllerAdopt**
> petsControllerAdopt(adoptPetDto)

Adopt a new Love Pet

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4LovePetApi();
final AdoptPetDto adoptPetDto = ; // AdoptPetDto | 

try {
    api.petsControllerAdopt(adoptPetDto);
} on DioException catch (e) {
    print('Exception when calling Epic4LovePetApi->petsControllerAdopt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adoptPetDto** | [**AdoptPetDto**](AdoptPetDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **petsControllerGetPet**
> petsControllerGetPet()

Get current Love Pet details

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4LovePetApi();

try {
    api.petsControllerGetPet();
} on DioException catch (e) {
    print('Exception when calling Epic4LovePetApi->petsControllerGetPet: $e\n');
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

# **petsControllerGetStatus**
> petsControllerGetStatus()

Get Love Pet dynamic status

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4LovePetApi();

try {
    api.petsControllerGetStatus();
} on DioException catch (e) {
    print('Exception when calling Epic4LovePetApi->petsControllerGetStatus: $e\n');
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

# **petsControllerInteract**
> petsControllerInteract()

Interact with the Love Pet (feed/play) to increase happiness

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4LovePetApi();

try {
    api.petsControllerInteract();
} on DioException catch (e) {
    print('Exception when calling Epic4LovePetApi->petsControllerInteract: $e\n');
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

