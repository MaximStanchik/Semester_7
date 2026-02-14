import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  static Future<void>? _googleSignInInitializeFuture;

  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<void> _ensureGoogleSignInInitialized() {
    _googleSignInInitializeFuture ??= _googleSignIn.initialize();
    return _googleSignInInitializeFuture!;
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    final account = await _googleSignIn.authenticate();

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _ensureGoogleSignInInitialized();
    await _googleSignIn.signOut();
  }
}
