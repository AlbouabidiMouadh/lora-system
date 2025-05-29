enum PumpStatus { on, off, unknown }

extension PumpStatusExtension on PumpStatus {
  bool get isOnline => this == PumpStatus.on || this == PumpStatus.off;
  bool get isOn => this == PumpStatus.on;
  bool get isOff => this == PumpStatus.off;
  bool get isUnknown => this == PumpStatus.unknown;
}
