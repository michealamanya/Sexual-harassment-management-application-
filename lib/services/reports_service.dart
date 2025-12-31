import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import 'auth_service.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String> submitReport(Report report) async {
    try {
      final docRef = await _firestore
          .collection('reports')
          .add(report.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  Stream<List<Report>> getUserReports() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('submittedDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList(),
        );
  }

  Future<Report?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      return doc.exists ? Report.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  Future<void> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
  ) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': newStatus.name,
      });
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  Future<void> updateReportWithResolution(
    String reportId,
    ReportStatus status,
    String resolution,
  ) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status.name,
        'resolution': resolution,
        'resolvedDate': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  Stream<Report?> watchReport(String reportId) {
    return _firestore
        .collection('reports')
        .doc(reportId)
        .snapshots()
        .map((doc) => doc.exists ? Report.fromFirestore(doc) : null);
  }
}
