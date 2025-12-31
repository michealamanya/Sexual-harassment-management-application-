import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { pending, underReview, resolved, closed }

class Report {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final DateTime submittedDate;
  final ReportStatus status;
  final String? resolution;
  final DateTime? resolvedDate;
  final List<String> attachments;
  final bool isAnonymous;
  final String? respondentName;
  final String? location;
  final DateTime? incidentDate;

  Report({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.submittedDate,
    required this.status,
    this.resolution,
    this.resolvedDate,
    this.attachments = const [],
    this.isAnonymous = false,
    this.respondentName,
    this.location,
    this.incidentDate,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      submittedDate: (data['submittedDate'] as Timestamp).toDate(),
      status: ReportStatus.values.byName(data['status'] ?? 'pending'),
      resolution: data['resolution'],
      resolvedDate:
          data['resolvedDate'] != null
              ? (data['resolvedDate'] as Timestamp).toDate()
              : null,
      attachments: List<String>.from(data['attachments'] ?? []),
      isAnonymous: data['isAnonymous'] ?? false,
      respondentName: data['respondentName'],
      location: data['location'],
      incidentDate:
          data['incidentDate'] != null
              ? (data['incidentDate'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'submittedDate': Timestamp.fromDate(submittedDate),
      'status': status.name,
      'resolution': resolution,
      'resolvedDate':
          resolvedDate != null ? Timestamp.fromDate(resolvedDate!) : null,
      'attachments': attachments,
      'isAnonymous': isAnonymous,
      'respondentName': respondentName,
      'location': location,
      'incidentDate':
          incidentDate != null ? Timestamp.fromDate(incidentDate!) : null,
    };
  }
}
