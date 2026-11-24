# Lib > Features > Welcome > Presentation > Widgets

## Overview
Promotional carousel banners, TikTok video player cards, and customer feedback bottom sheet forms.

## Interface
- [ad_video_showcase_card.dart:AdVideoShowcaseCard] Class `AdVideoShowcaseCard`
- [ad_video_showcase_card.dart:_AdVideoShowcaseCardState] Class `_AdVideoShowcaseCardState`
- [customer_feedback_sheet.dart:CustomerFeedbackSheet] Class `CustomerFeedbackSheet`
- [customer_feedback_sheet.dart:_CustomerFeedbackSheetState] Class `_CustomerFeedbackSheetState`
- [welcome_service_carousel_banner.dart:WelcomeServiceCarouselBanner] Class `WelcomeServiceCarouselBanner`
- [welcome_service_carousel_banner.dart:_CarouselSlideData] Class `_CarouselSlideData`
- [welcome_service_carousel_banner.dart:_WelcomeServiceCarouselBannerState] Class `_WelcomeServiceCarouselBannerState`

## Invariants
- [ad_video_showcase_card.dart:immutability] Immutable value contract enforced via const constructors
- [customer_feedback_sheet.dart:immutability] Immutable value contract enforced via const constructors
- [welcome_service_carousel_banner.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [ad_video_showcase_card.dart:Timer] Background Task: Spawns recurring periodic background timer
- [customer_feedback_sheet.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [welcome_service_carousel_banner.dart:Timer] Background Task: Spawns recurring periodic background timer

## Verification
- Run: `flutter test`
