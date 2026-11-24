# Tools > Bishe_Sentinel > App > Src > Main > Java > Com > Bishe > Sentinel

## Overview
Native Android background services, boot receivers, and SMS receivers capturing incoming Telebirr and CBE transactions.

## Interface
- [BootReceiver.kt:BootReceiver] Class `BootReceiver`
- [BootReceiver.kt:onReceive] Function `onReceive()`
- [MainActivity.kt:MainActivity] Class `MainActivity`
- [MainActivity.kt:onCreate] Function `onCreate()`
- [MainActivity.kt:checkAndRequestPermissions] Function `checkAndRequestPermissions()`
- [MainActivity.kt:onRequestPermissionsResult] Function `onRequestPermissionsResult()`
- [MainActivity.kt:startSentinelService] Function `startSentinelService()`
- [MainActivity.kt:requestIgnoreBatteryOptimizations] Function `requestIgnoreBatteryOptimizations()`
- [MainActivity.kt:isNetworkConnected] Function `isNetworkConnected()`
- [MainActivity.kt:updateUiStatus] Function `updateUiStatus()`
- [SentinelService.kt:SentinelService] Class `SentinelService`
- [SentinelService.kt:onCreate] Function `onCreate()`
- [SentinelService.kt:onStartCommand] Function `onStartCommand()`
- [SentinelService.kt:onBind] Function `onBind()`
- [SentinelService.kt:onDestroy] Function `onDestroy()`
- [SentinelService.kt:acquireWakeLock] Function `acquireWakeLock()`
- [SentinelService.kt:releaseWakeLock] Function `releaseWakeLock()`
- [SentinelService.kt:startHeartbeatLoop] Function `startHeartbeatLoop()`
- [SentinelService.kt:getBatteryLevel] Function `getBatteryLevel()`
- [SentinelService.kt:createNotificationChannel] Function `createNotificationChannel()`
- [SentinelService.kt:buildForegroundNotification] Function `buildForegroundNotification()`
- [SmsReceiver.kt:SmsReceiver] Class `SmsReceiver`
- [SmsReceiver.kt:onReceive] Function `onReceive()`
- [SupabaseClient.kt:ingestBankSms] Function `ingestBankSms()`
- [SupabaseClient.kt:onFailure] Function `onFailure()`
- [SupabaseClient.kt:onResponse] Function `onResponse()`
- [SupabaseClient.kt:sendHeartbeat] Function `sendHeartbeat()`

## Invariants
- [BootReceiver.kt:lifecycle] Receiver executes within Android OS broadcast delivery window
- [SmsReceiver.kt:lifecycle] Receiver executes within Android OS broadcast delivery window

## Side Effects
- [BootReceiver.kt:service] OS Process: Runs Android foreground service and renders persistent notification
- [MainActivity.kt:service] OS Process: Runs Android foreground service and renders persistent notification
- [SentinelService.kt:service] OS Process: Runs Android foreground service and renders persistent notification
- [SmsReceiver.kt:sms] Hardware/OS Event: Intercepts inbound telephony SMS broadcast intents
- [SupabaseClient.kt:network] Network I/O: Dispatches HTTPS POST payloads to Supabase ingest endpoint

## Verification
- Run: `./gradlew test`
