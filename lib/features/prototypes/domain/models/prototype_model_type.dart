import 'package:flutter/material.dart';

/// Defines the three candidate interaction paradigms evaluated in the prototype sandbox.
enum PrototypeModelType {
  /// Flagship: Streamlined single-page clone of the served app with photography-first Apple design and collapsible modules.
  unifiedServedClone,

  /// Model 1: Progressive 3-step linear wizard (Vehicle -> Package -> Details -> Ticket).
  stepper,

  /// Model 2: Modern responsive dual-card portal (Station Pulse Telemetry + Express Booking).
  saasPortal,

  /// Model 3: High-density single-screen form (<15s booking).
  expressKiosk,
}

extension PrototypeModelTypeExt on PrototypeModelType {
  String get title {
    switch (this) {
      case PrototypeModelType.unifiedServedClone:
        return 'Flagship: Served Clone';
      case PrototypeModelType.stepper:
        return 'Model 1: Stepper';
      case PrototypeModelType.saasPortal:
        return 'Model 2: SaaS Portal';
      case PrototypeModelType.expressKiosk:
        return 'Model 3: Express Kiosk';
    }
  }

  String get targetCompletionTime {
    switch (this) {
      case PrototypeModelType.unifiedServedClone:
        return '<15 sec';
      case PrototypeModelType.stepper:
        return '~25–35 sec';
      case PrototypeModelType.saasPortal:
        return '~20–30 sec';
      case PrototypeModelType.expressKiosk:
        return '<15 sec';
    }
  }

  String get description {
    switch (this) {
      case PrototypeModelType.unifiedServedClone:
        return 'Full served app clone redesigned with photography-first Apple styling, 1-page booking, and collapsible media/amenity modules.';
      case PrototypeModelType.stepper:
        return 'Step-by-step consumer wizard with tactile cards. Lowest cognitive load for first-time private car owners.';
      case PrototypeModelType.saasPortal:
        return 'Dual-card layout with live bay capacity overview and instant dynamic price computation.';
      case PrototypeModelType.expressKiosk:
        return 'High-velocity single-screen form with 2x2 vehicle grid and 48dp tactile cards for taxis and fleet drivers.';
    }
  }

  IconData get icon {
    switch (this) {
      case PrototypeModelType.unifiedServedClone:
        return Icons.auto_awesome_rounded;
      case PrototypeModelType.stepper:
        return Icons.linear_scale_rounded;
      case PrototypeModelType.saasPortal:
        return Icons.dashboard_customize_rounded;
      case PrototypeModelType.expressKiosk:
        return Icons.bolt_rounded;
    }
  }
}

/// Simulated live station telemetry snapshot used for Prototype 2 without database hits.
class StationTelemetrySnapshot {
  final int totalBays;
  final int availableBays;
  final int activeQueueCount;
  final int estimatedWaitMinutes;
  final int activeWashersCount;

  const StationTelemetrySnapshot({
    required this.totalBays,
    required this.availableBays,
    required this.activeQueueCount,
    required this.estimatedWaitMinutes,
    required this.activeWashersCount,
  });
}
