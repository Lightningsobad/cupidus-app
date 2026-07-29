# cupid_api.api.Epic6DataExportApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**dataExportControllerDownloadExport**](Epic6DataExportApi.md#dataexportcontrollerdownloadexport) | **GET** /data-export/{id}/download | Download a completed data export zip file
[**dataExportControllerGetExports**](Epic6DataExportApi.md#dataexportcontrollergetexports) | **GET** /data-export | Get list of personal data exports
[**dataExportControllerRequestExport**](Epic6DataExportApi.md#dataexportcontrollerrequestexport) | **POST** /data-export | Request a new personal data export


# **dataExportControllerDownloadExport**
> dataExportControllerDownloadExport(id)

Download a completed data export zip file

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic6DataExportApi();
final String id = id_example; // String | 

try {
    api.dataExportControllerDownloadExport(id);
} on DioException catch (e) {
    print('Exception when calling Epic6DataExportApi->dataExportControllerDownloadExport: $e\n');
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

# **dataExportControllerGetExports**
> dataExportControllerGetExports()

Get list of personal data exports

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic6DataExportApi();

try {
    api.dataExportControllerGetExports();
} on DioException catch (e) {
    print('Exception when calling Epic6DataExportApi->dataExportControllerGetExports: $e\n');
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

# **dataExportControllerRequestExport**
> dataExportControllerRequestExport()

Request a new personal data export

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic6DataExportApi();

try {
    api.dataExportControllerRequestExport();
} on DioException catch (e) {
    print('Exception when calling Epic6DataExportApi->dataExportControllerRequestExport: $e\n');
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

