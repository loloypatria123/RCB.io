import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreVerificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verify and fix Firestore structure
  static Future<void> verifyAndFixFirestore() async {
    print('🔍 Starting Firestore verification...\n');

    try {
      // Step 1: Check admins collection
      print('📋 Step 1: Checking admins collection...');
      await _verifyAdminsCollection();

      // Step 2: Check users collection
      print('\n📋 Step 2: Checking users collection...');
      await _verifyUsersCollection();

      // Step 3: Fix any issues
      print('\n📋 Step 3: Fixing any issues...');
      await _fixIssues();

      print('\n✅ Firestore verification completed!');
    } catch (e) {
      print('❌ Error during verification: $e');
    }
  }

  /// Verify admins collection
  static Future<void> _verifyAdminsCollection() async {
    try {
      final adminsSnapshot = await _firestore.collection('admins').get();
      print('   Found ${adminsSnapshot.docs.length} admin(s)');

      for (var doc in adminsSnapshot.docs) {
        final data = doc.data();
        print('\n   📄 Admin Document: ${doc.id}');
        print('      Email: ${data['email']}');
        print('      Name: ${data['name']}');
        print('      Role: ${data['role']}');
        print('      Email Verified: ${data['isEmailVerified']}');

        // Check if role is correct
        if (data['role'] != 'admin') {
          print(
            '      ⚠️  WARNING: Role is "${data['role']}", should be "admin"',
          );
        } else {
          print('      ✅ Role is correct');
        }
      }
    } catch (e) {
      print('   ❌ Error checking admins collection: $e');
      print('   ℹ️  Creating admins collection...');
      // Collection will be created when first document is added
    }
  }

  /// Verify users collection
  static Future<void> _verifyUsersCollection() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      print('   Found ${usersSnapshot.docs.length} user(s)');

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        print('\n   📄 User Document: ${doc.id}');
        print('      Email: ${data['email']}');
        print('      Name: ${data['name']}');
        print('      Role: ${data['role']}');
        print('      Email Verified: ${data['isEmailVerified']}');

        // Check if role is correct
        if (data['role'] != 'user') {
          print(
            '      ⚠️  WARNING: Role is "${data['role']}", should be "user"',
          );
        } else {
          print('      ✅ Role is correct');
        }

        // Check if this is an admin that should be in admins collection
        if (data['email']?.toString().contains('admin') ?? false) {
          print('      ⚠️  WARNING: This looks like an admin account!');
        }
      }
    } catch (e) {
      print('   ❌ Error checking users collection: $e');
      print('   ℹ️  Creating users collection...');
      // Collection will be created when first document is added
    }
  }

  /// Fix issues in Firestore
  static Future<void> _fixIssues() async {
    try {
      // Fix 1: Move admin accounts from users to admins collection
      print('\n   🔧 Fixing: Moving admin accounts to admins collection...');
      final usersSnapshot = await _firestore.collection('users').get();

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final email = data['email'] as String? ?? '';
        final role = data['role'] as String? ?? '';

        // If role is not "user", it might need to be moved
        if (role != 'user') {
          print('      Found document with role "$role": $email');
          print('      Moving to admins collection...');

          // Add to admins collection
          await _firestore.collection('admins').doc(doc.id).set(data);

          // Update role to admin if it's not already
          if (role != 'admin') {
            await _firestore.collection('admins').doc(doc.id).update({
              'role': 'admin',
            });
            print('      ✅ Updated role to "admin"');
          }

          // Remove from users collection
          await _firestore.collection('users').doc(doc.id).delete();
          print('      ✅ Removed from users collection');
        }
      }

      // Fix 2: Ensure all documents have correct role field
      print(
        '\n   🔧 Fixing: Ensuring all documents have correct role field...',
      );

      // Fix admins
      final adminsSnapshot = await _firestore.collection('admins').get();
      for (var doc in adminsSnapshot.docs) {
        final role = doc.data()['role'];
        if (role != 'admin') {
          print('      Fixing admin role for ${doc.data()['email']}');
          await _firestore.collection('admins').doc(doc.id).update({
            'role': 'admin',
          });
          print('      ✅ Fixed');
        }
      }

      // Fix users
      final usersSnapshot2 = await _firestore.collection('users').get();
      for (var doc in usersSnapshot2.docs) {
        final role = doc.data()['role'];
        if (role != 'user') {
          print('      Fixing user role for ${doc.data()['email']}');
          await _firestore.collection('users').doc(doc.id).update({
            'role': 'user',
          });
          print('      ✅ Fixed');
        }
      }

      print('\n   ✅ All fixes completed!');
    } catch (e) {
      print('   ❌ Error during fixes: $e');
    }
  }

  /// Create a test admin account
  static Future<void> createTestAdminAccount({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      print('\n🆕 Creating test admin account...');
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
      print('   ✅ Admin account created successfully!');
    } catch (e) {
      print('   ❌ Error creating admin account: $e');
    }
  }

  /// Create a test user account
  static Future<void> createTestUserAccount({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      print('\n🆕 Creating test user account...');
      print('   Email: $email');
      print('   Name: $name');

      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'role': 'user',
        'isEmailVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(uid).set(userData);
      print('   ✅ User account created successfully!');
    } catch (e) {
      print('   ❌ Error creating user account: $e');
    }
  }

  /// Get all admins
  static Future<List<UserModel>> getAllAdmins() async {
    try {
      final snapshot = await _firestore.collection('admins').get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error getting admins: $e');
      return [];
    }
  }

  /// Get all users
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error getting users: $e');
      return [];
    }
  }

  /// Print summary
  static Future<void> printSummary() async {
    try {
      print('\n📊 FIRESTORE SUMMARY\n');

      final admins = await getAllAdmins();
      final users = await getAllUsers();

      print('👨‍💼 ADMINS (${admins.length}):');
      for (var admin in admins) {
        print('   • ${admin.email} (${admin.name})');
      }

      print('\n👤 USERS (${users.length}):');
      for (var user in users) {
        print('   • ${user.email} (${user.name})');
      }

      print('\n✅ Summary complete!');
    } catch (e) {
      print('❌ Error printing summary: $e');
    }
  }
}
