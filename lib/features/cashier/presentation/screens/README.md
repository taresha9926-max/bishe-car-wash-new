# Lib > Features > Cashier > Presentation > Screens

## Overview
Cashier desk screens for dashboard monitoring, walk-in check-in, bay assignment modals, payment processing, bank deposits, and daily shift closings.

## Interface
- [bank_deposit_dialog.dart:BankDepositDialog] Class `BankDepositDialog`
- [bank_deposit_dialog.dart:_BankDepositDialogState] Class `_BankDepositDialogState`
- [bay_assignment_modal.dart:BayAssignmentModal] Class `BayAssignmentModal`
- [bay_assignment_modal.dart:_BayAssignmentModalState] Class `_BayAssignmentModalState`
- [cashier_dashboard_screen.dart:CashierDashboardScreen] Class `CashierDashboardScreen`
- [cashier_dashboard_screen.dart:_CashierDashboardScreenState] Class `_CashierDashboardScreenState`
- [daily_closing_dialog.dart:DailyClosingDialog] Class `DailyClosingDialog`
- [daily_closing_dialog.dart:_DailyClosingDialogState] Class `_DailyClosingDialogState`
- [edit_booking_dialog.dart:EditBookingDialog] Class `EditBookingDialog`
- [edit_booking_dialog.dart:_EditBookingDialogState] Class `_EditBookingDialogState`
- [payment_process_dialog.dart:PaymentProcessDialog] Class `PaymentProcessDialog`
- [payment_process_dialog.dart:_PaymentProcessDialogState] Class `_PaymentProcessDialogState`
- [petty_cash_dialog.dart:PettyCashDialog] Class `PettyCashDialog`
- [petty_cash_dialog.dart:_PettyCashDialogState] Class `_PettyCashDialogState`
- [phone_booking_dialog.dart:PhoneBookingDialog] Class `PhoneBookingDialog`
- [phone_booking_dialog.dart:_PhoneBookingDialogState] Class `_PhoneBookingDialogState`
- [walk_in_registration_screen.dart:WalkInRegistrationScreen] Class `WalkInRegistrationScreen`
- [walk_in_registration_screen.dart:_WalkInRegistrationScreenState] Class `_WalkInRegistrationScreenState`
- [weekly_commission_report_dialog.dart:WeeklyCommissionReportDialog] Class `WeeklyCommissionReportDialog`
- [weekly_commission_report_dialog.dart:_WeeklyCommissionReportDialogState] Class `_WeeklyCommissionReportDialogState`

## Invariants
- [bank_deposit_dialog.dart:immutability] Immutable value contract enforced via const constructors
- [bay_assignment_modal.dart:immutability] Immutable value contract enforced via const constructors
- [cashier_dashboard_screen.dart:immutability] Immutable value contract enforced via const constructors
- [daily_closing_dialog.dart:immutability] Immutable value contract enforced via const constructors
- [edit_booking_dialog.dart:immutability] Immutable value contract enforced via const constructors
- [payment_process_dialog.dart:immutability] Immutable value contract enforced via const constructors
- [petty_cash_dialog.dart:immutability] Immutable value contract enforced via const constructors
- [phone_booking_dialog.dart:immutability] Immutable value contract enforced via const constructors
- [walk_in_registration_screen.dart:immutability] Immutable value contract enforced via const constructors
- [weekly_commission_report_dialog.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [bank_deposit_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [bay_assignment_modal.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [cashier_dashboard_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [daily_closing_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [edit_booking_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [payment_process_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [petty_cash_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [phone_booking_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [weekly_commission_report_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
