import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/report_model.dart';
import 'auth_service.dart';

class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  static final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory ReportsService() {
    return _instance;
  }

  ReportsService._internal();

  Future<String> submitReport(Report report) async {
    try {
      final docRef =
          await _firestore.collection('reports').add(report.toFirestore());
      developer.log('Report submitted successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('Error submitting report: $e');
      throw Exception('Failed to submit your report. Please try again.');
    }
  }

  Stream<List<Report>> getUserReports() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      // Return empty stream for unauthenticated users instead of throwing
      return Stream.value([]);
    }

    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      // Sort in memory instead of requiring composite index
      final reports =
          snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      reports.sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
      return reports;
    }).handleError((error) {
      developer.log('Error fetching reports: $error');
      if (error.toString().contains('FAILED_PRECONDITION') ||
          error.toString().contains('index')) {
        developer.log('Index not available, attempting fallback query');
        return <Report>[];
      }
      throw Exception('Failed to load reports. Please try again.');
    });
  }

  Future<Report?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      return doc.exists ? Report.fromFirestore(doc) : null;
    } catch (e) {
      developer.log('Error fetching report: $e');
      throw Exception('Failed to load report details.');
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
      developer.log('Report status updated: $reportId -> ${newStatus.name}');
    } catch (e) {
      developer.log('Error updating status: $e');
      throw Exception('Failed to update report status.');
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
      developer.log('Report resolved: $reportId');
    } catch (e) {
      developer.log('Error resolving report: $e');
      throw Exception('Failed to resolve report.');
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
      developer.log('Report deleted: $reportId');
    } catch (e) {
      developer.log('Error deleting report: $e');
      throw Exception('Failed to delete report.');
    }
  }

  Stream<Report?> watchReport(String reportId) {
    return _firestore
        .collection('reports')
        .doc(reportId)
        .snapshots()
        .map((doc) => doc.exists ? Report.fromFirestore(doc) : null)
        .handleError((error) {
      developer.log('Error watching report: $error');
    });
  }
}
