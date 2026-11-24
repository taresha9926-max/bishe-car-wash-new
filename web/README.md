# Web

## Overview
Flutter web platform bootstrap hosting HTML shell, CanvasKit/Wasm rendering initialization, and service worker registration.

## Interface
- [flutter_bootstrap.js:bootstrap] Web Application Bootstrap Entrypoint
- [umami.js:tracker] Umami Privacy Analytics Tracking Script Client Entrypoint

## Invariants
- [flutter_bootstrap.js:dom] Expects valid browser DOM and WebGL/Canvas rendering support

## Side Effects
- [flutter_bootstrap.js:wasm_canvas] Web Runtime: Initializes Flutter engine, service workers, and CanvasKit/Wasm rendering

## Verification
- Run: `flutter test`
