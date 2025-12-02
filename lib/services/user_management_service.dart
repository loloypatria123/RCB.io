import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<UserModel>> getAllAccounts() async {
    try {
      final adminsSnapshot = await _firestore.collection('admins').get();
      final usersSnapshot = await _firestore.collection('users').get();

      final admins = adminsSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
      final users = usersSnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();

      final all = <UserModel>[];
      all.addAll(admins);
      all.addAll(users);

      return all;
    } catch (e) {
      print('❌ Error loading accounts: $e');
      return [];
    }
  }

  static Future<bool> updateUserStatus({
    required String targetUserId,
    required bool isAdmin,
    required String newStatus,
    required String adminId,
    required String adminEmail,
    required String adminName,
  }) async {
    try {
      final collectionName = isAdmin ? 'admins' : 'users';

      await _firestore.collection(collectionName).doc(targetUserId).update({
        'status': newStatus,
      });

      print('✅ Updated user status for $targetUserId to $newStatus');
      return true;
    } catch (e) {
      print('❌ Error updating user status: $e');
      return false;
    }
  }

  static Future<bool> updateUserRole({
    required String targetUserId,
    required bool currentIsAdmin,
    required bool makeAdmin,
    required String adminId,
    required String adminEmail,
    required String adminName,
  }) async {
    try {
      if (currentIsAdmin == makeAdmin) {
        return true;
      }

      final fromCollection = currentIsAdmin ? 'admins' : 'users';
      final toCollection = makeAdmin ? 'admins' : 'users';

      final docRef = _firestore.collection(fromCollection).doc(targetUserId);
      final doc = await docRef.get();
      if (!doc.exists) {
        print('❌ User document not found in $fromCollection: $targetUserId');
        return false;
      }

      final data = doc.data() ?? {};

      data['role'] = makeAdmin ? 'admin' : 'user';

      await _firestore.collection(toCollection).doc(targetUserId).set(data);
      await docRef.delete();

      print(
        '✅ Moved user $targetUserId from $fromCollection to $toCollection with role ${data['role']}',
      );

      return true;
    } catch (e) {
      print('❌ Error updating user role: $e');
      return false;
    }
  }
}
