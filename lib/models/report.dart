class Report {
  final String id;
  final DateTime date;
  final String? photoPath;
  final String section;
  final String issue;
  final String location;
  final String details;
  final String actionRequired;
  final String assignedTo;
  final int? projectId;

  Report({
    required this.id,
    required this.date,
    this.photoPath,
    required this.section,
    required this.issue,
    required this.location,
    required this.details,
    required this.actionRequired,
    required this.assignedTo,
    this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'photoPath': photoPath,
      'section': section,
      'issue': issue,
      'location': location,
      'details': details,
      'actionRequired': actionRequired,
      'assignedTo': assignedTo,
      'projectId': projectId,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      date: DateTime.parse(map['date']),
      photoPath: map['photoPath'],
      section: map['section'],
      issue: map['issue'],
      location: map['location'],
      details: map['details'],
      actionRequired: map['actionRequired'],
      assignedTo: map['assignedTo'],
      projectId: map['projectId'],
    );
  }
}
