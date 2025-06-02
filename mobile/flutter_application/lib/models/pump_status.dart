enum PumpStatus { on, off, maintenance, unknown }

extension PumpStatusExtension on PumpStatus {
  bool get isOnline => this == PumpStatus.on || this == PumpStatus.off;
  bool get isOn => this == PumpStatus.on;
  bool get isOff => this == PumpStatus.off;
  bool get isUnknown => this == PumpStatus.unknown;
}

extension PumpStatusString on PumpStatus {
  String get name {
    switch (this) {
      case PumpStatus.on:
        return 'on';
      case PumpStatus.off:
        return 'off';
      case PumpStatus.maintenance:
        return 'maintenance';
      case PumpStatus.unknown:
        return 'unknown';
    }
  }

  static PumpStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'on':
        return PumpStatus.on;
      case 'off':
        return PumpStatus.off;
      case 'maintenance':
        return PumpStatus.maintenance;
      default:
        return PumpStatus.unknown;
    }
  }

    Map<String,dynamic> toJson() {
    return {'status': name};
  }
}
