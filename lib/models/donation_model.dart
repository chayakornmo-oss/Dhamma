import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String userId;
  final String orgName;
  final double amount;
  final DateTime date;
  final String type;

  const DonationModel({
    required this.id,
    required this.userId,
    required this.orgName,
    required this.amount,
    required this.date,
    required this.type,
  });

  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return DonationModel(
      id: doc.id,
      userId: map['userId'] as String? ?? '',
      orgName: map['orgName'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: map['type'] as String? ?? 'cash',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'orgName': orgName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type,
    };
  }
}
