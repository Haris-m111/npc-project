import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase authentication ka instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore database ka instance

  // Abhi jo user login hai uski ID lene ke liye
  User? get currentUser => _auth.currentUser;

  // Agar true ho to bina email ke (111111) OTP se login ho jayega
  bool testMode = false;

  // Naye user ya login ke liye Email par OTP bhejta hai
  Future<bool> sendOtp(String email) async {
    debugPrint("Attempting to send OTP to: $email");
    if (testMode) {
      debugPrint("Test mode is ON. Simulating success.");
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      EmailOTP.config(
        appName: 'NPC App',
        otpType: OTPType.numeric,
        expiry: 60000,
        emailTheme: EmailTheme.v1,
        appEmail: 'ranaharis214@gmail.com',
        otpLength: 6,
      );

      bool result = await EmailOTP.sendOTP(email: email);
      debugPrint("OTP Send Result for $email: $result");
      return result;
    } catch (e, stack) {
      debugPrint("OTP Send Error for $email: $e");
      debugPrint(stack.toString());
      // Rethrow if it's a network error
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        rethrow;
      }
      return false;
    }
  }

  // User ka enter kiya hua OTP code check karta hai
  bool verifyOTP(String otp) {
    if (testMode && otp == "111111") {
      return true;
    }
    return EmailOTP.verifyOTP(otp: otp);
  }

  // Bhoolay huay password ko reset karne ke liye email bhejta hai
  Future<void> updatePassword(String email, String newPassword) async {
    // Note: In real Firebase, you'd usually use sendPasswordResetEmail.
    // However, if we are doing a manual flow, we might need a custom solution
    // or just handle it via re-authentication if logged in.
    // For this flow, we will simulate or use the reset email if possible.
    await _auth.sendPasswordResetEmail(email: email);
  }

  // User ka naam aur profile picture update karta hai
  Future<void> updateUserProfile({
    required String name,
    File? imageFile,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> updateData = {
      'uid': user.uid,
      'name': name,
      'email': user.email ?? "",
    };

    if (imageFile != null) {
      try {
        final bytes = await imageFile.readAsBytes();
        String imageBase64 = base64Encode(bytes);
        updateData['imageUrl'] = imageBase64;
      } catch (e) {
        debugPrint("Image processing error: $e");
      }
    }

    // Use set with merge true to be robust (works for create and update)
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(updateData, SetOptions(merge: true));
  }

  // Puraani password verify karke naya password set karta hai
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("No user is currently logged in");
    }

    // Re-authenticate with old password
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      // If re-authentication succeeds, update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception("Old password is incorrect");
      } else if (e.code == 'weak-password') {
        throw Exception("New password is too weak");
      } else {
        throw Exception("Failed to update password: ${e.message}");
      }
    }
  }

  // Login user ka email address return karta hai
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  // Security ke liye user ka password dobara check karta hai
  Future<void> reauthenticateUser(String password) async {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("No user is currently logged in");
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception("Password is incorrect");
      } else {
        throw Exception("Authentication failed: ${e.message}");
      }
    }
  }

  // User ka account aur saara data hamesha ke liye delete karta hai
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user is currently logged in");
    }

    String uid = user.uid;

    try {
      // Delete Firestore document first
      await _firestore.collection('users').doc(uid).delete();

      // Then delete the Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception("Please re-authenticate before deleting your account");
      } else {
        throw Exception("Failed to delete account: ${e.message}");
      }
    }
  }

  // User ke data mein honay wali tabdeeliyaan real-time mein dekhta hai
  Stream<DocumentSnapshot> getUserStream() {
    String uid = _auth.currentUser?.uid ?? '';
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Naya user account banata hai (Signup ka pehla step)
  Future<UserCredential> createAuthUser({
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Immediately create Firestore placeholder so 'isEmailRegistered' works
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email.toLowerCase(), // Normalize email to lowercase
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  // User ki profile maloomat Firestore mein save karta hai
  Future<void> saveUserProfile({required String name, File? imageFile}) async {
    // Simply delegate to updateUserProfile now that it's robust (handles create/merge)
    await updateUserProfile(name: name, imageFile: imageFile);
  }

  // DEPRECATED: Old signUp method (kept/modified if needed, but we represent it as split now)
  // For backward compatibility if needed, or we can just remove it.
  // Given we are refactoring, we will remove the old unified signUp to avoid confusion.

  // Email aur Password ke zariye login karta hai
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Firestore se login user ka saara data lata hai
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  // Task assign karne ke liye saaray users ki list lata hai
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint("Error fetching users: $e");
      return [];
    }
  }

  // Check karta hai ke ye email pehle se register hai ya nahi
  Future<bool> isEmailRegistered(String emailInput) async {
    final email = emailInput.trim();
    if (email.isEmpty) return false;

    try {
      // Priority 1: Check Auth Methods directly (The Hack for Legacy Accounts)
      // Since fetchSignInMethodsForEmail is removed, we attempt to CREATE a user.
      try {
        UserCredential temp = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: "DUMMY_PASSWORD_CHECK_123!",
        );
        // If we succeeded, it means the user DID NOT EXIST.
        await temp.user?.delete();
        // Continue to Firestore check just in case Auth is in a weird state
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use' ||
            e.code == 'credential-already-in-use') {
          return true; // Email EXISTS in Auth!
        }
        // If invalid-email, definitely false
        if (e.code == 'invalid-email') return false;
      }

      // Priority 2: Firestore Check (Fallback)
      // Check exact provided case
      var query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (query.docs.isNotEmpty) return true;

      // Check lowercase normalization (Our new standard)
      var queryLower = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();
      if (queryLower.docs.isNotEmpty) return true;

      // Check title case normalization (Common legacy format)
      String titleCase =
          email[0].toUpperCase() + email.substring(1).toLowerCase();
      var queryTitle = await _firestore
          .collection('users')
          .where('email', isEqualTo: titleCase)
          .get();
      if (queryTitle.docs.isNotEmpty) return true;

      return false;
    } catch (e) {
      debugPrint("Error checking email: $e");
      // Rethrow if it's a network error so the UI can handle it specifically
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        rethrow;
      }
      return false;
    }
  }

  // App se logout karta hai
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // Google account ke zariye login ya signup karta hai
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;
      bool isNewUser = false;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          isNewUser = true;
          // If not, create a new user document (Sign Up)
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? "No Name",
            'email': user.email ?? "",
            'imageUrl': user.photoURL ?? "",
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return {'user': user, 'isNewUser': isNewUser};
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      return null;
    }
  }

  // Check karta hai ke mobile mein internet chal raha hai ya nahi
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Check karta hai ke ye username pehle se kisi ne liya to nahi
  Future<bool> isNameTaken(String name, {String? excludeUid}) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('name', isEqualTo: name.trim())
          .get();

      if (query.docs.isEmpty) return false;

      if (excludeUid != null) {
        // Check if the only person taking the name is the current user (for updates)
        return query.docs.any((doc) => doc.id != excludeUid);
      }

      return true;
    } catch (e) {
      debugPrint("Error checking name uniqueness: $e");
      return false;
    }
  }
}
