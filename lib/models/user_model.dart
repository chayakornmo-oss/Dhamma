import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionTier { free, premium }

class UserModel {
  final String uid;
  final String name;
  final DateTime? birthDate;
  final List<String> goals;
  final int streakDays;
  final DateTime? lastCheckin;
  final SubscriptionTier subscriptionTier;
  final String? photoUrl;

  const UserModel({
    required this.uid,
    required this.name,
    this.birthDate,
    this.goals = const [],
    this.streakDays = 0,
    this.lastCheckin,
    this.subscriptionTier = SubscriptionTier.free,
    this.photoUrl,
  });

  bool get isPremium => subscriptionTier == SubscriptionTier.premium;

  /// Returns the first initial of the display name, upper-cased.
  String get initial =>
      name.isNotEmpty ? name.trim()[0].toUpperCase() : 'ก';

  /// Birth year, used for element calculation.
  int? get birthYear => birthDate?.year;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: map['name'] as String? ?? 'ผู้ใช้',
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      goals: List<String>.from(map['goals'] as List? ?? []),
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      lastCheckin: (map['lastCheckin'] as Timestamp?)?.toDate(),
      subscriptionTier: (map['subscriptionTier'] as String?) == 'premium'
          ? SubscriptionTier.premium
          : SubscriptionTier.free,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDate':
          birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'goals': goals,
      'streakDays': streakDays,
      'lastCheckin':
          lastCheckin != null ? Timestamp.fromDate(lastCheckin!) : null,
      'subscriptionTier': subscriptionTier.name,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? name,
    DateTime? birthDate,
    List<String>? goals,
    int? streakDays,
    DateTime? lastCheckin,
    SubscriptionTier? subscriptionTier,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      goals: goals ?? this.goals,
      streakDays: streakDays ?? this.streakDays,
      lastCheckin: lastCheckin ?? this.lastCheckin,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
