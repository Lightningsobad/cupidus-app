# cupid_api.api.Epic4PrivateGalleryApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**galleryControllerCreate**](Epic4PrivateGalleryApi.md#gallerycontrollercreate) | **POST** /gallery | Add a new encrypted photo reference to Gallery
[**galleryControllerFindAll**](Epic4PrivateGalleryApi.md#gallerycontrollerfindall) | **GET** /gallery | Get gallery photos list
[**galleryControllerRemove**](Epic4PrivateGalleryApi.md#gallerycontrollerremove) | **DELETE** /gallery/{id} | Delete a photo from Gallery


# **galleryControllerCreate**
> galleryControllerCreate(createGalleryItemDto)

Add a new encrypted photo reference to Gallery

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4PrivateGalleryApi();
final CreateGalleryItemDto createGalleryItemDto = ; // CreateGalleryItemDto | 

try {
    api.galleryControllerCreate(createGalleryItemDto);
} on DioException catch (e) {
    print('Exception when calling Epic4PrivateGalleryApi->galleryControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createGalleryItemDto** | [**CreateGalleryItemDto**](CreateGalleryItemDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **galleryControllerFindAll**
> galleryControllerFindAll(limit, offset)

Get gallery photos list

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4PrivateGalleryApi();
final String limit = limit_example; // String | 
final String offset = offset_example; // String | 

try {
    api.galleryControllerFindAll(limit, offset);
} on DioException catch (e) {
    print('Exception when calling Epic4PrivateGalleryApi->galleryControllerFindAll: $e\n');
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

# **galleryControllerRemove**
> galleryControllerRemove(id)

Delete a photo from Gallery

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic4PrivateGalleryApi();
final String id = id_example; // String | 

try {
    api.galleryControllerRemove(id);
} on DioException catch (e) {
    print('Exception when calling Epic4PrivateGalleryApi->galleryControllerRemove: $e\n');
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

