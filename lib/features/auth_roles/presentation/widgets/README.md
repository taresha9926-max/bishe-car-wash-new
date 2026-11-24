# Lib > Features > Auth_Roles > Presentation > Widgets

## Overview
Modal security dialog prompting for staff PIN credentials before granting privileged role switches.

## Interface
- [role_auth_dialog.dart:RoleAuthDialog] Class `RoleAuthDialog`
- [role_auth_dialog.dart:_RoleAuthDialogState] Class `_RoleAuthDialogState`

## Invariants
- [role_auth_dialog.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [role_auth_dialog.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
