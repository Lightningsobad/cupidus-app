# cupid_api.api.Epic1UsersApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**usersControllerGetProfile**](Epic1UsersApi.md#userscontrollergetprofile) | **GET** /users/me | Get current user profile
[**usersControllerMarkVowTaken**](Epic1UsersApi.md#userscontrollermarkvowtaken) | **POST** /users/vow | Mark biometric vow as taken
[**usersControllerUpdateProfile**](Epic1UsersApi.md#userscontrollerupdateprofile) | **PATCH** /users/me | Update current user profile


# **usersControllerGetProfile**
> usersControllerGetProfile()

Get current user profile

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1UsersApi();

try {
    api.usersControllerGetProfile();
} on DioException catch (e) {
    print('Exception when calling Epic1UsersApi->usersControllerGetProfile: $e\n');
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

# **usersControllerMarkVowTaken**
> usersControllerMarkVowTaken()

Mark biometric vow as taken

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1UsersApi();

try {
    api.usersControllerMarkVowTaken();
} on DioException catch (e) {
    print('Exception when calling Epic1UsersApi->usersControllerMarkVowTaken: $e\n');
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

# **usersControllerUpdateProfile**
> usersControllerUpdateProfile(updateProfileDto)

Update current user profile

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1UsersApi();
final UpdateProfileDto updateProfileDto = ; // UpdateProfileDto | 

try {
    api.usersControllerUpdateProfile(updateProfileDto);
} on DioException catch (e) {
    print('Exception when calling Epic1UsersApi->usersControllerUpdateProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateProfileDto** | [**UpdateProfileDto**](UpdateProfileDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

