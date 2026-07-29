# cupid_api.api.Epic1LoveContractsApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**loveContractsControllerCreate**](Epic1LoveContractsApi.md#lovecontractscontrollercreate) | **POST** /love-contracts | Create a new love contract
[**loveContractsControllerGetMyPending**](Epic1LoveContractsApi.md#lovecontractscontrollergetmypending) | **GET** /love-contracts/my-pending | Get current pending love contract
[**loveContractsControllerSign**](Epic1LoveContractsApi.md#lovecontractscontrollersign) | **PATCH** /love-contracts/sign | Sign the pending love contract


# **loveContractsControllerCreate**
> loveContractsControllerCreate(createContractDto)

Create a new love contract

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1LoveContractsApi();
final CreateContractDto createContractDto = ; // CreateContractDto | 

try {
    api.loveContractsControllerCreate(createContractDto);
} on DioException catch (e) {
    print('Exception when calling Epic1LoveContractsApi->loveContractsControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createContractDto** | [**CreateContractDto**](CreateContractDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loveContractsControllerGetMyPending**
> loveContractsControllerGetMyPending()

Get current pending love contract

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1LoveContractsApi();

try {
    api.loveContractsControllerGetMyPending();
} on DioException catch (e) {
    print('Exception when calling Epic1LoveContractsApi->loveContractsControllerGetMyPending: $e\n');
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

# **loveContractsControllerSign**
> loveContractsControllerSign()

Sign the pending love contract

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic1LoveContractsApi();

try {
    api.loveContractsControllerSign();
} on DioException catch (e) {
    print('Exception when calling Epic1LoveContractsApi->loveContractsControllerSign: $e\n');
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

