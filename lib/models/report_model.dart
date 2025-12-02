import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String title;
  final String category;
  final String status;
  final String description;
  final String submittedBy;
  final String submittedByUid;
  final String submittedDate;
  final bool archived;
  final List<String> replies;

  ReportModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.description,
    required this.submittedBy,
    required this.submittedByUid,
    required this.submittedDate,
    this.archived = false,
    this.replies = const [],
  });

  factory ReportModel.fromJson(Map<String, dynamic> json, String id) {
    return ReportModel(
      id: id,
      title: json['title'] ?? '',
      category: json['category'] ?? 'bug',
      status: json['status'] ?? 'Open',
      description: json['description'] ?? '',
      submittedBy: json['submittedBy'] ?? 'User',
      submittedByUid: json['submittedByUid'] ?? '',
      submittedDate: json['submittedDate'] ?? '',
      archived: json['archived'] ?? false,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory ReportModel.fromDoc(DocumentSnapshot doc) {
    return ReportModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'status': status,
      'description': description,
      'submittedBy': submittedBy,
      'submittedByUid': submittedByUid,
      'submittedDate': submittedDate,
      'archived': archived,
      'replies': replies,
    };
  }

  ReportModel copyWith({
    String? title,
    String? category,
    String? status,
    String? description,
    bool? archived,
    List<String>? replies,
  }) {
    return ReportModel(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      description: description ?? this.description,
      submittedBy: submittedBy,
      submittedByUid: submittedByUid,
      submittedDate: submittedDate,
      archived: archived ?? this.archived,
      replies: replies ?? this.replies,
    );
  }
}
