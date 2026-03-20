import 'package:cloud_firestore/cloud_firestore.dart';

class CheckinModel {
  final String id;
  final String userId;
  final DateTime date;
  final String mood;
  final Map<String, String> prayerRecommended;

  const CheckinModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.prayerRecommended,
  });

  factory CheckinModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    final rawPrayer = map['prayerRecommended'];
    final prayer = rawPrayer is Map<String, dynamic>
        ? rawPrayer.map((k, v) => MapEntry(k, v.toString()))
        : <String, String>{};

    return CheckinModel(
      id: doc.id,
      userId: map['userId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mood: map['mood'] as String? ?? 'normal',
      prayerRecommended: prayer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'mood': mood,
      'prayerRecommended': prayerRecommended,
    };
  }
}
