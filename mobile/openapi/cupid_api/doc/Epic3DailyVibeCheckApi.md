# cupid_api.api.Epic3DailyVibeCheckApi

## Load the API package
```dart
import 'package:cupid_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**vibesControllerCreate**](Epic3DailyVibeCheckApi.md#vibescontrollercreate) | **POST** /vibes | Post daily mood / vibe
[**vibesControllerGetHistory**](Epic3DailyVibeCheckApi.md#vibescontrollergethistory) | **GET** /vibes/history | Get user&#39;s vibe history
[**vibesControllerGetPartnerHistory**](Epic3DailyVibeCheckApi.md#vibescontrollergetpartnerhistory) | **GET** /vibes/partner | Get partner&#39;s vibe history
[**vibesControllerGetToday**](Epic3DailyVibeCheckApi.md#vibescontrollergettoday) | **GET** /vibes/today | Get current user&#39;s vibe for today


# **vibesControllerCreate**
> vibesControllerCreate(createVibeDto)

Post daily mood / vibe

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3DailyVibeCheckApi();
final CreateVibeDto createVibeDto = ; // CreateVibeDto | 

try {
    api.vibesControllerCreate(createVibeDto);
} on DioException catch (e) {
    print('Exception when calling Epic3DailyVibeCheckApi->vibesControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createVibeDto** | [**CreateVibeDto**](CreateVibeDto.md)|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **vibesControllerGetHistory**
> vibesControllerGetHistory(days)

Get user's vibe history

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3DailyVibeCheckApi();
final String days = days_example; // String | 

try {
    api.vibesControllerGetHistory(days);
} on DioException catch (e) {
    print('Exception when calling Epic3DailyVibeCheckApi->vibesControllerGetHistory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **vibesControllerGetPartnerHistory**
> vibesControllerGetPartnerHistory(days)

Get partner's vibe history

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3DailyVibeCheckApi();
final String days = days_example; // String | 

try {
    api.vibesControllerGetPartnerHistory(days);
} on DioException catch (e) {
    print('Exception when calling Epic3DailyVibeCheckApi->vibesControllerGetPartnerHistory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[firebase-jwt](../README.md#firebase-jwt)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **vibesControllerGetToday**
> vibesControllerGetToday()

Get current user's vibe for today

### Example
```dart
import 'package:cupid_api/api.dart';

final api = CupidApi().getEpic3DailyVibeCheckApi();

try {
    api.vibesControllerGetToday();
} on DioException catch (e) {
    print('Exception when calling Epic3DailyVibeCheckApi->vibesControllerGetToday: $e\n');
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

