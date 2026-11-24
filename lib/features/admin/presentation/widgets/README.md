# Lib > Features > Admin > Presentation > Widgets

## Overview
Specialized administrative UI widgets including revenue KPI cards, pricing matrix editors, audit log tiles, and AI executive sheets.

## Interface
- [admin_feedback_moderation_card.dart:AdminFeedbackModerationCard] Class `AdminFeedbackModerationCard`
- [admin_feedback_moderation_card.dart:_AdminFeedbackModerationCardState] Class `_AdminFeedbackModerationCardState`
- [bishe_ai_executive_sheet.dart:BisheAiExecutiveSheet] Class `BisheAiExecutiveSheet`
- [bishe_ai_executive_sheet.dart:_ChatMessage] Class `_ChatMessage`
- [bishe_ai_executive_sheet.dart:_AiBlock] Class `_AiBlock`
- [bishe_ai_executive_sheet.dart:_HeaderBlock] Class `_HeaderBlock`
- [bishe_ai_executive_sheet.dart:_KpiStripBlock] Class `_KpiStripBlock`
- [bishe_ai_executive_sheet.dart:_TableBlock] Class `_TableBlock`
- [bishe_ai_executive_sheet.dart:_BulletBlock] Class `_BulletBlock`
- [bishe_ai_executive_sheet.dart:_CalloutBlock] Class `_CalloutBlock`
- [bishe_ai_executive_sheet.dart:_ParagraphBlock] Class `_ParagraphBlock`
- [bishe_ai_executive_sheet.dart:_ActionBlock] Class `_ActionBlock`
- [bishe_ai_executive_sheet.dart:_BisheAiExecutiveSheetState] Class `_BisheAiExecutiveSheetState`
- [commission_item_card.dart:CommissionItemCard] Class `CommissionItemCard`
- [pricing_matrix_editor.dart:PricingMatrixEditor] Class `PricingMatrixEditor`
- [pricing_matrix_editor.dart:_PricingMatrixEditorState] Class `_PricingMatrixEditorState`
- [revenue_kpi_card.dart:RevenueKPICard] Class `RevenueKPICard`
- [sentinel_cross_ref_card.dart:SentinelCrossRefCard] Class `SentinelCrossRefCard`
- [sentinel_cross_ref_card.dart:_SentinelCrossRefCardState] Class `_SentinelCrossRefCardState`

## Invariants
- [admin_feedback_moderation_card.dart:immutability] Immutable value contract enforced via const constructors
- [bishe_ai_executive_sheet.dart:immutability] Immutable value contract enforced via const constructors
- [commission_item_card.dart:immutability] Immutable value contract enforced via const constructors
- [pricing_matrix_editor.dart:immutability] Immutable value contract enforced via const constructors
- [revenue_kpi_card.dart:immutability] Immutable value contract enforced via const constructors
- [sentinel_cross_ref_card.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [bishe_ai_executive_sheet.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [pricing_matrix_editor.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [sentinel_cross_ref_card.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
