enum Reason { temp, water, pump }

extension ReasonExtension on Reason {
  String get name {
    switch (this) {
      case Reason.temp:
        return 'temp';
      case Reason.water:
        return 'water';
      case Reason.pump:
        return 'pump';
    }
  }

  static Reason fromString(String value) {
    switch (value.toLowerCase()) {
      case 'temp':
        return Reason.temp;
      case 'water':
        return Reason.water;
      case 'pump':
        return Reason.pump;
      default:
        return Reason.pump;
    }
  }

  Map<String, dynamic> toJson() {
    return {'reason': name};
  }
}
