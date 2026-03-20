import 'package:cloud_firestore/cloud_firestore.dart';

enum VowStatus { pending, urgent, done }

class VowModel {
  final String id;
  final String userId;
  final String templeName;
  final String prayerText;
  final String fulfillment;
  final VowStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderDate;

  VowModel({
    required this.id,
    required this.userId,
    required this.templeName,
    required this.prayerText,
    required this.fulfillment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reminderDate,
  });

  factory VowModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    final statusStr = map['status'] as String? ?? 'pending';

    return VowModel(
      id: doc.id,
      userId: map['userId'] ?? '',
      templeName: map['templeName'] ?? '',
      prayerText: map['prayerText'] ?? '',
      fulfillment: map['fulfillment'] ?? '',
      status: statusStr == 'done' ? VowStatus.done : (statusStr == 'urgent' ? VowStatus.urgent : VowStatus.pending),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reminderDate: (map['reminderDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'templeName': templeName,
      'prayerText': prayerText,
      'fulfillment': fulfillment,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reminderDate': reminderDate != null ? Timestamp.fromDate(reminderDate!) : null,
    };
  }
}
