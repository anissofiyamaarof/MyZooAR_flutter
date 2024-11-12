import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async{
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            print("No user found for that email.");
            break;
          case 'wrong-password':
            print("Wrong password provided for that user.");
            break;
          default:
            print("An error occurred. Please try again.");
        }
      } else {
        print("Some error occurred");
      }
    }
    return null;
  }

}

