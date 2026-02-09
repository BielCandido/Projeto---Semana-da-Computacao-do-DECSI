class Participant {
  final String id;
  final String name;
  final String email;
  final String institution;
  final DateTime checkInTime;
  final String? qrCode;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    required this.institution,
    required this.checkInTime,
    this.qrCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'institution': institution,
      'checkInTime': checkInTime.toIso8601String(),
      'qrCode': qrCode,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      institution: json['institution'],
      checkInTime: DateTime.parse(json['checkInTime']),
      qrCode: json['qrCode'],
    );
  }
}
