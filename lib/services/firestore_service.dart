import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vow_model.dart';
import 'auth_service.dart';

final firestoreServiceProvider = Provider((ref) {
  return FirestoreService(FirebaseFirestore.instance, ref.watch(authServiceProvider));
});

class FirestoreService {
  final FirebaseFirestore _db;
  final AuthService _auth;

  FirestoreService(this._db, this._auth);

  String? get currentUserId => _auth.currentUser?.uid;

  // Vows
  Stream<List<VowModel>> getVows() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();
    
    return _db.collection('vows')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => VowModel.fromFirestore(doc)).toList());
  }

  Future<void> addVow(VowModel vow) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _db.collection('vows').add(vow.toMap());
  }

  Future<void> updateVowStatus(String vowId, VowStatus newStatus) async {
    await _db.collection('vows').doc(vowId).update({
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Users
  Future<void> createUserProfile(String name, DateTime birthDate, List<String> goals) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _db.collection('users').doc(userId).set({
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'goals': goals,
      'streakDays': 1,
      'lastCheckin': FieldValue.serverTimestamp(),
      'subscriptionTier': 'free',
    });
  }

  // Checkins
  Future<void> addCheckin(String mood, Map<String, dynamic> prayerRecommended) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _db.collection('checkins').add({
      'userId': userId,
      'date': FieldValue.serverTimestamp(),
      'mood': mood,
      'prayerRecommended': prayerRecommended,
    });
  }

  // Donations
  Future<void> recordDonation(String orgName, double amount, String type) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _db.collection('donations').add({
      'userId': userId,
      'orgName': orgName,
      'amount': amount,
      'date': FieldValue.serverTimestamp(),
      'type': type,
    });
  }
}
