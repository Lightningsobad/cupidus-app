# cupid_api.api.Epic5ExpensesApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**expensesControllerCreate**](Epic5ExpensesApi.md#expensescontrollercreate) | **POST** /expenses | Log a new shared expense
[**expensesControllerFindAll**](Epic5ExpensesApi.md#expensescontrollerfindall) | **GET** /expenses | Get all expenses
[**expensesControllerGetReport**](Epic5ExpensesApi.md#expensescontrollergetreport) | **GET** /expenses/report | Get expense summary report (week/month)
[**expensesControllerRemove**](Epic5ExpensesApi.md#expensescontrollerremove) | **DELETE** /expenses/{id} | Delete an expense log


# **expensesControllerCreate**
> expensesControllerCreate(createExpenseDto)

Log a new shared expense

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5ExpensesApi();
final CreateExpenseDto createExpenseDto = ; // CreateExpenseDto | 

try {
    api.expensesControllerCreate(createExpenseDto);
} on DioException catch (e) {
    print('Exception when calling Epic5ExpensesApi->expensesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createExpenseDto** | [**CreateExpenseDto**](CreateExpenseDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **expensesControllerFindAll**
> expensesControllerFindAll(limit, offset)

Get all expenses

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5ExpensesApi();
final String limit = limit_example; // String | 
final String offset = offset_example; // String | 

try {
    api.expensesControllerFindAll(limit, offset);
} on DioException catch (e) {
    print('Exception when calling Epic5ExpensesApi->expensesControllerFindAll: $e\n');
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

# **expensesControllerGetReport**
> expensesControllerGetReport(period)

Get expense summary report (week/month)

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5ExpensesApi();
final String period = period_example; // String | 

try {
    api.expensesControllerGetReport(period);
} on DioException catch (e) {
    print('Exception when calling Epic5ExpensesApi->expensesControllerGetReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **period** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **expensesControllerRemove**
> expensesControllerRemove(id)

Delete an expense log

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic5ExpensesApi();
final String id = id_example; // String | 

try {
    api.expensesControllerRemove(id);
} on DioException catch (e) {
    print('Exception when calling Epic5ExpensesApi->expensesControllerRemove: $e\n');
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

