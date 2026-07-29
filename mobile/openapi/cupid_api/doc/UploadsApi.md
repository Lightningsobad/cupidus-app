# cupid_api.api.UploadsApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**uploadsControllerUploadFile**](UploadsApi.md#uploadscontrolleruploadfile) | **POST** /uploads | 


# **uploadsControllerUploadFile**
> uploadsControllerUploadFile()



### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getUploadsApi();

try {
    api.uploadsControllerUploadFile();
} on DioException catch (e) {
    print('Exception when calling UploadsApi->uploadsControllerUploadFile: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

