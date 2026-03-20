import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/vow_model.dart';
import '../models/checkin_model.dart';
import '../models/donation_model.dart';
import 'auth_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(
    FirebaseFirestore.instance,
    ref.watch(authServiceProvider),
  );
});

class FirestoreService {
  final FirebaseFirestore _db;
  final AuthService _auth;

  FirestoreService(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  // ── Users ────────────────────────────────────────────────────────

  Stream<UserModel?> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<UserModel?> getUserProfileOnce(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUserProfile({
    required String name,
    required DateTime birthDate,
    required List<String> goals,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).set({
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'goals': goals,
      'streakDays': 1,
      'lastCheckin': FieldValue.serverTimestamp(),
      'subscriptionTier': 'free',
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile(UserModel user) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update(user.toMap());
  }

  Future<void> updateUserName(String name) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'name': name});
  }

  Future<void> upgradeToPremiun() async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'subscriptionTier': 'premium',
    });
  }

  // ── Streak Logic ─────────────────────────────────────────────────

  Future<void> recordCheckinAndUpdateStreak() async {
    final uid = _uid;
    if (uid == null) return;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;

    final user = UserModel.fromFirestore(doc);
    final now = DateTime.now();
    final lastCheckin = user.lastCheckin;

    int newStreak = user.streakDays;

    if (lastCheckin != null) {
      final diff = now.difference(lastCheckin).inDays;
      if (diff == 1) {
        // Consecutive day
        newStreak = user.streakDays + 1;
      } else if (diff > 1) {
        // Streak broken
        newStreak = 1;
      }
      // diff == 0 means same day, don't change streak
    } else {
      newStreak = 1;
    }

    await _db.collection('users').doc(uid).update({
      'streakDays': newStreak,
      'lastCheckin': FieldValue.serverTimestamp(),
    });
  }

  // ── Vows ─────────────────────────────────────────────────────────

  Stream<List<VowModel>> getVows() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('vows')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => VowModel.fromFirestore(d)).toList());
  }

  Future<String> addVow(VowModel vow) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final ref = await _db.collection('vows').add(vow.toMap());
    return ref.id;
  }

  Future<void> updateVowStatus(String vowId, VowStatus newStatus) async {
    await _db.collection('vows').doc(vowId).update({
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteVow(String vowId) async {
    await _db.collection('vows').doc(vowId).delete();
  }

  // ── Checkins ─────────────────────────────────────────────────────

  Future<void> addCheckin({
    required String mood,
    required Map<String, String> prayerRecommended,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final batch = _db.batch();

    final checkinRef = _db.collection('checkins').doc();
    batch.set(checkinRef, {
      'userId': uid,
      'date': FieldValue.serverTimestamp(),
      'mood': mood,
      'prayerRecommended': prayerRecommended,
    });

    batch.commit();
    await recordCheckinAndUpdateStreak();
  }

  Stream<List<CheckinModel>> getCheckins({int limit = 30}) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('checkins')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CheckinModel.fromFirestore(d)).toList());
  }

  // ── Donations ─────────────────────────────────────────────────────

  Future<void> recordDonation({
    required String orgName,
    required double amount,
    required String type,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('donations').add({
      'userId': uid,
      'orgName': orgName,
      'amount': amount,
      'date': FieldValue.serverTimestamp(),
      'type': type,
    });
  }

  Stream<List<DonationModel>> getDonations() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('donations')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Future<double> getTotalDonations() async {
    final uid = _uid;
    if (uid == null) return 0;

    final snap = await _db
        .collection('donations')
        .where('userId', isEqualTo: uid)
        .get();

    return snap.docs.fold<double>(
      0,
      (total, d) => total + ((d.data()['amount'] as num?)?.toDouble() ?? 0),
    );
  }
}
