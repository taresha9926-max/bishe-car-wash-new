# Lib > Core > Widgets

## Overview
Universal reusable UI components including buttons, text fields, glass containers, circular progress rings, video players, and header controls.

## Interface
- [video_player_stub.dart:createPlatformVideoPlayer] Platform conditional video player fallback
- [video_player_web.dart:createPlatformVideoPlayer] Web video player with HTML/Canvas video element integration
- [ad_video_player.dart:AdVideoPlayer] Class `AdVideoPlayer`
- [animated_circular_ring.dart:AnimatedCircularRing] Class `AnimatedCircularRing`
- [animated_circular_ring.dart:_CircularRingPainter] Class `_CircularRingPainter`
- [app_glass.dart:AppGlass] Class `AppGlass`
- [app_glass.dart:AppGlassCard] Class `AppGlassCard`
- [app_role_header.dart:AppRoleHeader] Class `AppRoleHeader`
- [automotive_3d_car_view.dart:Automotive3DCarView] Class `Automotive3DCarView`
- [automotive_3d_car_view.dart:_Automotive3DCarViewState] Class `_Automotive3DCarViewState`
- [automotive_3d_car_view.dart:_LaserFloorPainter] Class `_LaserFloorPainter`
- [closing_sync_warning_banner.dart:ClosingSyncWarningBanner] Class `ClosingSyncWarningBanner`
- [closing_sync_warning_banner.dart:resolveClosingSyncWarningMessage] Top-level function `resolveClosingSyncWarningMessage()`
- [closing_sync_warning_banner.dart:showClosingSyncResultSnackBar] Top-level function `showClosingSyncResultSnackBar()`
- [combined_service_header_banner.dart:CombinedServiceHeaderBanner] Class `CombinedServiceHeaderBanner`
- [custom_button.dart:CustomButton] Class `CustomButton`
- [custom_text_field.dart:CustomTextField] Class `CustomTextField`
- [dual_service_entrance_tab_bar.dart:DualServiceEntranceTabBar] Class `DualServiceEntranceTabBar`
- [expandable_action_card.dart:ExpandableActionCard] Class `ExpandableActionCard`
- [expandable_action_card.dart:_ExpandableActionCardState] Class `_ExpandableActionCardState`
- [financial_balance_sheet_card.dart:FinancialBalanceSheetCard] Class `FinancialBalanceSheetCard`
- [financial_cash_flow_card.dart:FinancialCashFlowCard] Class `FinancialCashFlowCard`
- [financial_pnl_statement_card.dart:FinancialPnlStatementCard] Class `FinancialPnlStatementCard`
- [language_switcher_action.dart:LanguageSwitcherAction] Class `LanguageSwitcherAction`
- [liquid_level_gauge.dart:LiquidLevelGauge] Class `LiquidLevelGauge`
- [modern_expandable_card.dart:ModernExpandableCard] Class `ModernExpandableCard`
- [modern_expandable_card.dart:_ModernExpandableCardState] Class `_ModernExpandableCardState`
- [online_booking_alert_banner.dart:OnlineBookingAlertBanner] Class `OnlineBookingAlertBanner`
- [online_booking_alert_banner.dart:_OnlineBookingAlertBannerState] Class `_OnlineBookingAlertBannerState`
- [responsive_layout.dart:ResponsiveLayout] Class `ResponsiveLayout`
- [rounded_meter_bar.dart:RoundedMeterBar] Class `RoundedMeterBar`
- [service_location_picker_card.dart:ServiceLocationPickerCard] Class `ServiceLocationPickerCard`
- [service_location_picker_card.dart:_ServiceLocationPickerCardState] Class `_ServiceLocationPickerCardState`
- [service_promo_banner.dart:ServicePromoBanner] Class `ServicePromoBanner`
- [service_promo_banner.dart:_ServicePromoBannerState] Class `_ServicePromoBannerState`
- [service_promo_banner.dart:_PromoItem] Class `_PromoItem`
- [shared_washer_commission_hub.dart:SharedWasherCommissionHub] Class `SharedWasherCommissionHub`
- [shared_washer_commission_hub.dart:_SharedWasherCommissionHubState] Class `_SharedWasherCommissionHubState`
- [shared_washer_commission_hub.dart:WasherHubRole] Enum `WasherHubRole`
- [status_badge.dart:StatusBadge] Class `StatusBadge`
- [storekeeper_chemical_reconciliation_card.dart:StorekeeperChemicalReconciliationCard] Class `StorekeeperChemicalReconciliationCard`
- [tactile_bounce.dart:BounceTappable] Class `BounceTappable`
- *(... and 3 additional public symbols)*

## Invariants
- [ad_video_player.dart:immutability] Immutable value contract enforced via const constructors
- [animated_circular_ring.dart:immutability] Immutable value contract enforced via const constructors
- [app_glass.dart:immutability] Immutable value contract enforced via const constructors
- [app_role_header.dart:immutability] Immutable value contract enforced via const constructors
- [automotive_3d_car_view.dart:immutability] Immutable value contract enforced via const constructors
- [closing_sync_warning_banner.dart:immutability] Immutable value contract enforced via const constructors
- [combined_service_header_banner.dart:immutability] Immutable value contract enforced via const constructors
- [custom_button.dart:immutability] Immutable value contract enforced via const constructors
- [custom_text_field.dart:immutability] Immutable value contract enforced via const constructors
- [dual_service_entrance_tab_bar.dart:immutability] Immutable value contract enforced via const constructors
- [expandable_action_card.dart:immutability] Immutable value contract enforced via const constructors
- [financial_balance_sheet_card.dart:immutability] Immutable value contract enforced via const constructors
- [financial_cash_flow_card.dart:immutability] Immutable value contract enforced via const constructors
- [financial_pnl_statement_card.dart:immutability] Immutable value contract enforced via const constructors
- [language_switcher_action.dart:immutability] Immutable value contract enforced via const constructors
- [liquid_level_gauge.dart:immutability] Immutable value contract enforced via const constructors
- [modern_expandable_card.dart:immutability] Immutable value contract enforced via const constructors
- [online_booking_alert_banner.dart:immutability] Immutable value contract enforced via const constructors
- [responsive_layout.dart:immutability] Immutable value contract enforced via const constructors
- [rounded_meter_bar.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [app_role_header.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [online_booking_alert_banner.dart:Timer] Background Task: Spawns recurring periodic background timer
- [service_promo_banner.dart:Timer] Background Task: Spawns recurring periodic background timer
- [shared_washer_commission_hub.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
