class PunchListItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String priority;
  final String status;
  final String? assignedTo;
  final DateTime createdDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final List<String> photoPaths;
  final double? estimatedHours;
  final String? notes;

  PunchListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.category = 'Other',
    this.priority = 'Medium',
    this.status = 'Pending',
    this.assignedTo,
    DateTime? createdDate,
    this.dueDate,
    this.completedDate,
    List<String>? photoPaths,
    this.estimatedHours,
    this.notes,
  })  : createdDate = createdDate ?? DateTime.now(),
        photoPaths = photoPaths ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'photoPaths': photoPaths.join(','),
      'estimatedHours': estimatedHours,
      'notes': notes,
    };
  }

  factory PunchListItem.fromMap(Map<String, dynamic> map) {
    return PunchListItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] ?? 'Other',
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? 'Pending',
      assignedTo: map['assignedTo'],
      createdDate: DateTime.parse(map['createdDate']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'])
          : null,
      photoPaths: map['photoPaths'] != null && map['photoPaths'].isNotEmpty
          ? map['photoPaths'].split(',')
          : [],
      estimatedHours: map['estimatedHours']?.toDouble(),
      notes: map['notes'],
    );
  }

  PunchListItem copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? createdDate,
    DateTime? dueDate,
    DateTime? completedDate,
    List<String>? photoPaths,
    double? estimatedHours,
    String? notes,
  }) {
    return PunchListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      photoPaths: photoPaths ?? this.photoPaths,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue {
    if (status == 'Completed' || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}
