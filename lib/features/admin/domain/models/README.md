# Lib > Features > Admin > Domain > Models

## Overview
Domain entities representing bank deposit records, commission audit logs, daily financial closings, staff credentials, and staff salaries.

## Interface
- [bank_deposit_record.dart:BankDepositRecord] Class `BankDepositRecord`
- [commission_log.dart:CommissionLog] Class `CommissionLog`
- [daily_financial_closing.dart:DailyFinancialClosing] Class `DailyFinancialClosing`
- [monthly_overhead_expense.dart:MonthlyOverheadExpense] Class `MonthlyOverheadExpense`
- [pending_approval_request.dart:PendingApprovalRequest] Class `PendingApprovalRequest`
- [pending_approval_request.dart:ApprovalActionType] Enum `ApprovalActionType`
- [petty_cash_expense.dart:PettyCashExpense] Class `PettyCashExpense`
- [staff_credential.dart:StaffCredential] Class `StaffCredential`
- [staff_member.dart:StaffMember] Class `StaffMember`
- [staff_member.dart:StaffRole] Enum `StaffRole`
- [washer_daily_attendance.dart:WasherDailyAttendance] Class `WasherDailyAttendance`
- [washer_dividend.dart:WasherDividend] Class `WasherDividend`
- [weekly_commission_report.dart:WeeklyCommissionReport] Class `WeeklyCommissionReport`

## Invariants
- [bank_deposit_record.dart:immutability] Immutable value contract enforced via const constructors
- [commission_log.dart:immutability] Immutable value contract enforced via const constructors
- [daily_financial_closing.dart:immutability] Immutable value contract enforced via const constructors
- [monthly_overhead_expense.dart:immutability] Immutable value contract enforced via const constructors
- [pending_approval_request.dart:immutability] Immutable value contract enforced via const constructors
- [petty_cash_expense.dart:immutability] Immutable value contract enforced via const constructors
- [staff_credential.dart:immutability] Immutable value contract enforced via const constructors
- [staff_member.dart:immutability] Immutable value contract enforced via const constructors
- [washer_daily_attendance.dart:immutability] Immutable value contract enforced via const constructors
- [washer_dividend.dart:immutability] Immutable value contract enforced via const constructors
- [weekly_commission_report.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- None

## Verification
- Run: `flutter test`
