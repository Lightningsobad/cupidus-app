# cupid_api.api.Epic1InvitationsApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**invitationsControllerAccept**](Epic1InvitationsApi.md#invitationscontrolleraccept) | **POST** /invitations/accept | Accept an invitation using a code
[**invitationsControllerGenerate**](Epic1InvitationsApi.md#invitationscontrollergenerate) | **POST** /invitations/generate | Generate a pairing invitation code
[**invitationsControllerTestGenerate**](Epic1InvitationsApi.md#invitationscontrollertestgenerate) | **GET** /invitations/test-generate-debug | Debug: Test generating code
[**invitationsControllerTestValidate**](Epic1InvitationsApi.md#invitationscontrollertestvalidate) | **GET** /invitations/test-validate-debug | Debug: Test validating code
[**invitationsControllerValidate**](Epic1InvitationsApi.md#invitationscontrollervalidate) | **POST** /invitations/validate | Validate an invitation code


# **invitationsControllerAccept**
> invitationsControllerAccept()

Accept an invitation using a code

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1InvitationsApi();

try {
    api.invitationsControllerAccept();
} on DioException catch (e) {
    print('Exception when calling Epic1InvitationsApi->invitationsControllerAccept: $e\n');
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

# **invitationsControllerGenerate**
> invitationsControllerGenerate()

Generate a pairing invitation code

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1InvitationsApi();

try {
    api.invitationsControllerGenerate();
} on DioException catch (e) {
    print('Exception when calling Epic1InvitationsApi->invitationsControllerGenerate: $e\n');
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

# **invitationsControllerTestGenerate**
> invitationsControllerTestGenerate(uid)

Debug: Test generating code

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1InvitationsApi();
final String uid = uid_example; // String | 

try {
    api.invitationsControllerTestGenerate(uid);
} on DioException catch (e) {
    print('Exception when calling Epic1InvitationsApi->invitationsControllerTestGenerate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **uid** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **invitationsControllerTestValidate**
> invitationsControllerTestValidate(code)

Debug: Test validating code

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1InvitationsApi();
final String code = code_example; // String | 

try {
    api.invitationsControllerTestValidate(code);
} on DioException catch (e) {
    print('Exception when calling Epic1InvitationsApi->invitationsControllerTestValidate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **invitationsControllerValidate**
> invitationsControllerValidate()

Validate an invitation code

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1InvitationsApi();

try {
    api.invitationsControllerValidate();
} on DioException catch (e) {
    print('Exception when calling Epic1InvitationsApi->invitationsControllerValidate: $e\n');
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

