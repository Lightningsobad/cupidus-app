# cupid_api.api.Epic1AuthApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authControllerLogin**](Epic1AuthApi.md#authcontrollerlogin) | **POST** /auth/login | Login user
[**authControllerRegister**](Epic1AuthApi.md#authcontrollerregister) | **POST** /auth/register | Register a new authenticated Firebase user


# **authControllerLogin**
> authControllerLogin()

Login user

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1AuthApi();

try {
    api.authControllerLogin();
} on DioException catch (e) {
    print('Exception when calling Epic1AuthApi->authControllerLogin: $e\n');
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

# **authControllerRegister**
> authControllerRegister()

Register a new authenticated Firebase user

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1AuthApi();

try {
    api.authControllerRegister();
} on DioException catch (e) {
    print('Exception when calling Epic1AuthApi->authControllerRegister: $e\n');
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

