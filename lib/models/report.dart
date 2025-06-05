//import 'package:uuid/uuid.dart';

class Report {
  final String id;
  final DateTime date;
  final String note;
  final String photoPath;
  final String? aiAnalysis;

  Report({
    required this.id,
    required this.date,
    required this.note,
    required this.photoPath,
    this.aiAnalysis,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'note': note,
      'photoPath': photoPath,
      'aiAnalysis': aiAnalysis,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      photoPath: map['photoPath'],
      aiAnalysis: map['aiAnalysis'],
    );
  }
}
