import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> registerUser({
    required String name,
    required String email,
    required String password
  }) async {
    try {
      await Firebase.initializeApp();
      
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        return null;
      }
      return "Erro ao criar usuário";
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Email já cadastrado";
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  loginUser({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  logoutUser() {
    return _firebaseAuth.signOut();
  }
}
