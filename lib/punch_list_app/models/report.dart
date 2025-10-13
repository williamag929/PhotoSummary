class Report {
  final String id;
  final String issue;
  final String location;
  final String details;
  final String assignedTo;
  final DateTime createdDate;

  Report({
    required this.id,
    required this.issue,
    required this.location,
    required this.details,
    required this.assignedTo,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'issue': issue,
      'location': location,
      'details': details,
      'assignedTo': assignedTo,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      issue: map['issue'] ?? '',
      location: map['location'] ?? '',
      details: map['details'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      createdDate: DateTime.parse(map['createdDate']),
    );
  }
}
