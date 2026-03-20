import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'log_service.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(FirebaseAuth.instance));

/// Result of an auth operation — carries the user on success or a
/// localised Thai error message on failure.
class AuthResult {
  final User? user;
  final String? errorMessage;

  const AuthResult.success(this.user) : errorMessage = null;
  const AuthResult.failure(this.errorMessage) : user = null;

  bool get isSuccess => user != null;
}

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._auth);

  // ── State ────────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  // ── Email / Password ─────────────────────────────────────────────

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await LogService.logSignIn('email');
      return AuthResult.success(result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_translateError(e.code));
    } catch (e, s) {
      await LogService.error(e, s, context: 'signInWithEmail');
      return const AuthResult.failure('เกิดข้อผิดพลาด กรุณาลองใหม่');
    }
  }

  Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // If currently anonymous, link the email credential to preserve data
      final current = _auth.currentUser;
      UserCredential result;

      if (current != null && current.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email.trim(),
          password: password,
        );
        try {
          result = await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use' ||
              e.code == 'credential-already-in-use') {
            result = await _auth.createUserWithEmailAndPassword(
              email: email.trim(),
              password: password,
            );
          } else {
            return AuthResult.failure(_translateError(e.code));
          }
        }
      } else {
        result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      }

      // Set the display name so onboarding screen can pre-populate it
      await result.user?.updateDisplayName(name.trim());
      await LogService.logSignUp('email');
      return AuthResult.success(result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_translateError(e.code));
    } catch (e, s) {
      await LogService.error(e, s, context: 'registerWithEmail');
      return const AuthResult.failure('เกิดข้อผิดพลาด กรุณาลองใหม่');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      await LogService.logEvent(LogEvent.passwordReset);
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_translateError(e.code));
    } catch (e, s) {
      await LogService.error(e, s, context: 'sendPasswordResetEmail');
      return const AuthResult.failure('เกิดข้อผิดพลาด กรุณาลองใหม่');
    }
  }

  // ── Anonymous Sign-In ────────────────────────────────────────────
  Future<AuthResult> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      await LogService.logSignIn('anonymous');
      return AuthResult.success(result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_translateError(e.code));
    }
  }

  // ── Google Sign-In ───────────────────────────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult.failure(null); // user cancelled, no message
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = await _linkOrSignIn(credential);
      if (user != null) await LogService.logSignIn('google');
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_translateError(e.code));
    } catch (e, s) {
      await LogService.error(e, s, context: 'signInWithGoogle');
      return const AuthResult.failure('ไม่สามารถเข้าสู่ระบบด้วย Google ได้');
    }
  }

  // ── Apple Sign-In ────────────────────────────────────────────────
  Future<AuthResult> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final user = await _linkOrSignIn(credential);

      if (user != null) {
        final givenName = appleCredential.givenName;
        final familyName = appleCredential.familyName;
        if (givenName != null || familyName != null) {
          await user.updateDisplayName(
              '${givenName ?? ''} ${familyName ?? ''}'.trim());
        }
        await LogService.logSignIn('apple');
      }
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_translateError(e.code));
    } catch (e, s) {
      await LogService.error(e, s, context: 'signInWithApple');
      return const AuthResult.failure('ไม่สามารถเข้าสู่ระบบด้วย Apple ได้');
    }
  }

  // ── Account Linking helper ───────────────────────────────────────
  Future<User?> _linkOrSignIn(AuthCredential credential) async {
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      try {
        final result = await current.linkWithCredential(credential);
        return result.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          final result = await _auth.signInWithCredential(credential);
          return result.user;
        }
        rethrow;
      }
    }
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  // ── Availability helpers ─────────────────────────────────────────
  static bool get isAppleSignInAvailable =>
      !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  // ── Sign Out ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    await LogService.logSignOut();
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Thai error translation ───────────────────────────────────────
  static String _translateError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ไม่พบบัญชีนี้ กรุณาสมัครสมาชิก';
      case 'wrong-password':
      case 'invalid-credential':
        return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      case 'email-already-in-use':
        return 'อีเมลนี้มีบัญชีอยู่แล้ว';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'weak-password':
        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
      case 'too-many-requests':
        return 'ลองใหม่อีกครั้งในภายหลัง (คำขอมากเกินไป)';
      case 'network-request-failed':
        return 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
      case 'user-disabled':
        return 'บัญชีนี้ถูกระงับการใช้งาน กรุณาติดต่อผู้ดูแลระบบ';
      case 'operation-not-allowed':
        return 'วิธีการเข้าสู่ระบบนี้ยังไม่เปิดใช้งาน';
      default:
        return 'เกิดข้อผิดพลาด ($code) กรุณาลองใหม่';
    }
  }
}
