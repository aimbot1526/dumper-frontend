import 'package:dumper/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_login/twitter_login.dart';

class LoginService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final TwitterLogin twitterLogin = TwitterLogin(
    apiKey: DefaultFirebaseOptions.twitterApiKey,
    apiSecretKey: DefaultFirebaseOptions.twitterApiSecret,
    redirectURI: DefaultFirebaseOptions.twitterCallbackUrl,
  );

  // Google Sign-in
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Google Sign-out
  Future<void> authSignOut() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('USERNAMEKEY');
    preferences.remove('USEREMAILKEY');
    await googleSignIn.signOut();
    await auth.signOut();
  }

  // Twitter Login
  Future<void> singInWithTwitter() async {
    final authResult = await twitterLogin.loginV2();
    if (authResult.status == TwitterLoginStatus.loggedIn) {
      final AuthCredential credential = TwitterAuthProvider.credential(
        accessToken: DefaultFirebaseOptions.twitterApiKey,
        secret: DefaultFirebaseOptions.twitterApiSecret,
      );
      await auth.signInWithCredential(credential);
    }
  }
}
