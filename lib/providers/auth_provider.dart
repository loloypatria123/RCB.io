import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/email_service.dart';
import '../services/fallback_email_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  BuildContext? _context;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationCode;
  String? _pendingEmail;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  UserRole? get userRole => _userModel?.role;
  bool get isAdmin => _userModel?.role == UserRole.admin;
  bool get isEmailVerified => _userModel?.isEmailVerified ?? false;
  String? get verificationCode => _verificationCode;
  String? get pendingEmail => _pendingEmail;

  AuthProvider({BuildContext? context}) {
    _context = context;
    _initializeUser();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void _initializeUser() {
    _user = _firebaseAuth.currentUser;
    if (_user != null) {
      _loadUserModel();
    }
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserModel();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    try {
      // Try to load from admins collection first
      var doc = await _firestore.collection('admins').doc(_user!.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('📝 Raw admin data from Firestore: $data');
        print('📝 Role field value: ${data['role']}');
        _userModel = UserModel.fromJson(data);
        print('✅ Loaded admin from admins collection');
        print('✅ Parsed role: ${_userModel?.role}');
        print('✅ Is admin check: ${_userModel?.role == UserRole.admin}');
      } else {
        // If not found in admins, try users collection
        doc = await _firestore.collection('users').doc(_user!.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          print('📝 Raw user data from Firestore: $data');
          print('📝 Role field value: ${data['role']}');
          _userModel = UserModel.fromJson(data);
          print('✅ Loaded user from users collection');
          print('✅ Parsed role: ${_userModel?.role}');
        }
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user model: $e');
    }
  }

  Future<bool> signUpWithRole({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      print('🔐 Starting sign up for: $email');
      print('🔐 Role: ${role.toString()}');

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      print('✅ Firebase user created: ${user.uid}');

      await user.updateDisplayName(name);
      print('✅ Display name updated: $name');

      // Generate verification code
      final verificationCode = EmailService.generateVerificationCode();
      _verificationCode = verificationCode;
      _pendingEmail = email;

      print('🔢 Generated verification code: $verificationCode');

      // Send verification email with fallback
      try {
        await EmailService.sendVerificationCode(
          email: email,
          verificationCode: verificationCode,
          userName: name,
        );
      } catch (e) {
        print('⚠️ Email.js failed, using fallback: $e');
        // Show verification code in dialog as fallback
        if (_context != null) {
          FallbackEmailService.showVerificationCodeDialog(
            context: _context!,
            email: email,
            verificationCode: verificationCode,
            userName: name,
          );
        }
      }

      // Create user document in Firestore
      _userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
        isEmailVerified: false,
        verificationCode: verificationCode,
        verificationCodeExpiry: DateTime.now().add(const Duration(minutes: 10)),
        createdAt: DateTime.now(),
      );

      print('📝 Creating Firestore document...');

      // Store in appropriate collection based on role
      final collectionName = role == UserRole.admin ? 'admins' : 'users';
      await _firestore
          .collection(collectionName)
          .doc(user.uid)
          .set(_userModel!.toJson());
      print('✅ Firestore document created in $collectionName collection!');

      _user = user;
      _isLoading = false;
      notifyListeners();
      print('✅ Sign up completed successfully!');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ General Error during sign up: $e');
      _errorMessage = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmail(String code) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔐 Verifying email with code: $code');
      print('🔐 In-memory verification code: $_verificationCode');
      print('🔐 User model verification code: ${_userModel?.verificationCode}');

      // First, reload user model from Firestore to get latest verification code
      if (_user != null) {
        print('📝 Reloading user model from Firestore...');
        await _loadUserModel();
        print('📝 User model reloaded');
        print(
          '🔐 Updated user model verification code: ${_userModel?.verificationCode}',
        );
      }

      // Check against both in-memory and Firestore stored codes
      final storedCode = _verificationCode ?? _userModel?.verificationCode;

      print('🔐 Final stored code to compare: $storedCode');
      print('🔐 User entered code: $code');

      if (storedCode == null) {
        print('❌ ERROR: No verification code found in system!');
        _errorMessage =
            'Verification code not found. Please request a new one.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (storedCode != code) {
        print('❌ Code mismatch! Expected: $storedCode, Got: $code');
        _errorMessage = 'Invalid verification code';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('✅ Code matches!');

      if (_userModel?.verificationCodeExpiry?.isBefore(DateTime.now()) ??
          false) {
        print('❌ Verification code expired');
        _errorMessage = 'Verification code has expired';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('✅ Code not expired');

      // Update user in Firestore
      print('📝 Updating Firestore with verified status...');

      // Determine which collection to update based on role
      final collectionName = _userModel?.role == UserRole.admin
          ? 'admins'
          : 'users';

      // Use FieldValue.delete() to remove null fields instead of setting them to null
      await _firestore.collection(collectionName).doc(_user!.uid).update({
        'isEmailVerified': true,
        'verificationCode': FieldValue.delete(),
        'verificationCodeExpiry': FieldValue.delete(),
      });

      // Update local model
      _userModel = _userModel!.copyWith(
        isEmailVerified: true,
        verificationCode: null,
        verificationCodeExpiry: null,
      );

      print('✅ Firestore updated successfully!');

      _verificationCode = null;
      _pendingEmail = null;
      _isLoading = false;
      notifyListeners();

      print('✅ Email verification completed successfully!');
      return true;
    } catch (e) {
      print('❌ Verification error: $e');
      _errorMessage = 'Verification failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      print('🔐 Starting sign in for: $email');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      _user = userCredential.user;
      print('✅ Firebase sign in successful: ${_user?.uid}');

      print('📝 Loading user model from Firestore...');
      await _loadUserModel();
      print('📝 User model loaded');
      print('👤 User role: ${_userModel?.role}');
      print('👤 User name: ${_userModel?.name}');
      print('👤 Is admin: ${_userModel?.role == UserRole.admin}');

      // Update last login
      if (_userModel != null) {
        print('📝 Updating last login...');
        _userModel = _userModel!.copyWith(lastLogin: DateTime.now());

        // Update in the correct collection based on role
        final collectionName = _userModel!.role == UserRole.admin
            ? 'admins'
            : 'users';
        await _firestore.collection(collectionName).doc(_user!.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
        print('✅ Last login updated');
      }

      _isLoading = false;
      notifyListeners();
      print('✅ Sign in completed successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Sign in error: $e');
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firebaseAuth.signOut();
      _user = null;
      _userModel = null;
      _verificationCode = null;
      _pendingEmail = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendVerificationCode(String email, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final verificationCode = EmailService.generateVerificationCode();
      _verificationCode = verificationCode;

      print('🔄 Resending verification code: $verificationCode');

      // Send verification email with fallback
      try {
        await EmailService.sendVerificationCode(
          email: email,
          verificationCode: verificationCode,
          userName: name,
        );
      } catch (e) {
        print('⚠️ Email.js failed for resend, using fallback: $e');
        // Show verification code in dialog as fallback
        if (_context != null) {
          FallbackEmailService.showVerificationCodeDialog(
            context: _context!,
            email: email,
            verificationCode: verificationCode,
            userName: name,
          );
        }
      }

      // Update Firestore with new verification code
      if (_user != null) {
        print('📝 Updating Firestore with new verification code...');

        // Determine which collection to update based on role
        final collectionName = _userModel?.role == UserRole.admin
            ? 'admins'
            : 'users';

        await _firestore.collection(collectionName).doc(_user!.uid).update({
          'verificationCode': verificationCode,
          'verificationCodeExpiry': DateTime.now()
              .add(const Duration(minutes: 10))
              .toIso8601String(),
        });
        print('✅ Firestore updated with new code');

        // Update local model
        _userModel = _userModel?.copyWith(
          verificationCode: verificationCode,
          verificationCodeExpiry: DateTime.now().add(
            const Duration(minutes: 10),
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error resending verification code: $e');
      _errorMessage = 'Failed to resend verification code: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Recover admin account by recreating Firestore document
  Future<bool> recoverAdminAccount({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      print('🔄 Recovering admin account...');
      print('   UID: $uid');
      print('   Email: $email');
      print('   Name: $name');

      final adminData = {
        'uid': uid,
        'email': email,
        'name': name,
        'role': 'admin',
        'isEmailVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('admins').doc(uid).set(adminData);
      print('✅ Admin account recovered successfully!');

      // Reload user model
      await _loadUserModel();
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error recovering admin account: $e');
      _errorMessage = 'Failed to recover admin account: $e';
      notifyListeners();
      return false;
    }
  }
}
