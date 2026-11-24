# Lib > Core > Utils

## Overview
Utility helpers for currency formatting, date manipulation, image compression, asset paths, and audio/haptic feedback.

## Interface
- [sound_notifier.dart:export] Conditional platform export for `SoundNotifier` (HTML audio on web vs stub)
- [auto_care_assets.dart:AutoCareAssets] Class `AutoCareAssets`
- [currency_formatter.dart:CurrencyFormatter] Class `CurrencyFormatter`
- [date_formatter.dart:DateFormatter] Class `DateFormatter`
- [image_picker_helper.dart:PickedReceiptImage] Class `PickedReceiptImage`
- [image_picker_helper.dart:ImagePickerHelper] Class `ImagePickerHelper`
- [image_picker_stub.dart:pickImagePlatform] Top-level function `pickImagePlatform()`
- [image_picker_stub.dart:takePhotoPlatform] Top-level function `takePhotoPlatform()`
- [image_picker_web.dart:pickImagePlatform] Top-level function `pickImagePlatform()`
- [image_picker_web.dart:takePhotoPlatform] Top-level function `takePhotoPlatform()`
- [live_gps_helper.dart:LiveGpsHelper] Class `LiveGpsHelper`
- [live_gps_stub.dart:getCurrentCoordinatesPlatform] Top-level function `getCurrentCoordinatesPlatform()`
- [live_gps_web.dart:getCurrentCoordinatesPlatform] Top-level function `getCurrentCoordinatesPlatform()`
- [local_storage_helper.dart:LocalStorageHelper] Class `LocalStorageHelper`
- [local_storage_stub.dart:setLocalStorageItem] Top-level function `setLocalStorageItem()`
- [local_storage_web.dart:setLocalStorageItem] Top-level function `setLocalStorageItem()`
- [print_export_helper.dart:PrintExportHelper] Class `PrintExportHelper`
- [print_export_stub.dart:downloadFile] Top-level function `downloadFile()`
- [print_export_stub.dart:printDocument] Top-level function `printDocument()`
- [print_export_web.dart:downloadFile] Top-level function `downloadFile()`
- [print_export_web.dart:printDocument] Top-level function `printDocument()`
- [receipt_image_helper.dart:ReceiptImageHelper] Class `ReceiptImageHelper`
- [sound_helper.dart:SoundHelper] Class `SoundHelper`
- [sound_helper_stub.dart:SoundPlatform] Class `SoundPlatform`
- [sound_helper_web.dart:SoundPlatform] Class `SoundPlatform`
- [sound_notifier_stub.dart:playOnlineBookingBeep] Top-level function `playOnlineBookingBeep()`
- [sound_notifier_web.dart:playOnlineBookingBeep] Top-level function `playOnlineBookingBeep()`
- [url_launcher_helper.dart:UrlLauncherHelper] Class `UrlLauncherHelper`
- [video_picker_helper.dart:VideoPickerHelper] Class `VideoPickerHelper`
- [video_picker_stub.dart:pickVideoPlatform] Top-level function `pickVideoPlatform()`
- [video_picker_web.dart:pickVideoPlatform] Top-level function `pickVideoPlatform()`

## Invariants
- [auto_care_assets.dart:immutability] Immutable value contract enforced via const constructors
- [date_formatter.dart:immutability] Immutable value contract enforced via const constructors
- [image_picker_helper.dart:immutability] Immutable value contract enforced via const constructors
- [local_storage_helper.dart:immutability] Immutable value contract enforced via const constructors
- [print_export_helper.dart:immutability] Immutable value contract enforced via const constructors
- [receipt_image_helper.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [print_export_helper.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [receipt_image_helper.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
