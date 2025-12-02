import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';
import 'audit_service.dart';

/// Service for managing authentication security features
class SecurityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Security configuration
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration attemptWindowDuration = Duration(minutes: 30);

  /// Check if an account is currently locked due to failed attempts
  static Future<bool> isAccountLocked(String email) async {
    try {
      final doc = await _firestore
          .collection('security_attempts')
          .doc(_sanitizeEmail(email))
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final lockedUntil = data['lockedUntil'] as Timestamp?;

      if (lockedUntil == null) return false;

      final lockExpiry = lockedUntil.toDate();
      final now = DateTime.now();

      // If lock has expired, clear it
      if (now.isAfter(lockExpiry)) {
        await _clearLockout(email);
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error checking account lock status: $e');
      return false; // Fail open to prevent legitimate users from being locked out
    }
  }

  /// Get the time remaining for account lockout
  static Future<Duration?> getLockoutTimeRemaining(String email) async {
    try {
      final doc = await _firestore
          .collection('security_attempts')
          .doc(_sanitizeEmail(email))
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      final lockedUntil = data['lockedUntil'] as Timestamp?;

      if (lockedUntil == null) return null;

      final lockExpiry = lockedUntil.toDate();
      final now = DateTime.now();

      if (now.isAfter(lockExpiry)) {
        await _clearLockout(email);
        return null;
      }

      return lockExpiry.difference(now);
    } catch (e) {
      print('❌ Error getting lockout time: $e');
      return null;
    }
  }

  /// Record a failed login attempt
  static Future<void> recordFailedAttempt({
    required String email,
    String? errorCode,
    String? userAgent,
    String? ipAddress,
  }) async {
    try {
      print('🔒 Recording failed login attempt for: $email');

      final docRef = _firestore
          .collection('security_attempts')
          .doc(_sanitizeEmail(email));

      final doc = await docRef.get();
      final now = DateTime.now();

      if (!doc.exists) {
        // Create new security tracking document
        await docRef.set({
          'email': email,
          'failedAttempts': 1,
          'firstAttemptAt': Timestamp.fromDate(now),
          'lastAttemptAt': Timestamp.fromDate(now),
          'lockedUntil': null,
          'attempts': [
            {
              'timestamp': Timestamp.fromDate(now),
              'success': false,
              'errorCode': errorCode,
              'userAgent': userAgent,
              'ipAddress': ipAddress,
            }
          ],
        });

        print('✅ Created new security tracking for $email');
      } else {
        final data = doc.data()!;
        final firstAttempt = (data['firstAttemptAt'] as Timestamp).toDate();
        final attempts = List<Map<String, dynamic>>.from(data['attempts'] ?? []);

        // Check if we're still within the attempt window
        final windowExpired = now.difference(firstAttempt) > attemptWindowDuration;

        if (windowExpired) {
          // Reset counter if window has passed
          await docRef.update({
            'failedAttempts': 1,
            'firstAttemptAt': Timestamp.fromDate(now),
            'lastAttemptAt': Timestamp.fromDate(now),
            'attempts': [
              {
                'timestamp': Timestamp.fromDate(now),
                'success': false,
                'errorCode': errorCode,
                'userAgent': userAgent,
                'ipAddress': ipAddress,
              }
            ],
          });
          print('✅ Reset attempt counter (window expired)');
        } else {
          // Increment failed attempts
          final failedCount = (data['failedAttempts'] as int) + 1;

          // Add new attempt to history
          attempts.add({
            'timestamp': Timestamp.fromDate(now),
            'success': false,
            'errorCode': errorCode,
            'userAgent': userAgent,
            'ipAddress': ipAddress,
          });

          // Check if we need to lock the account
          if (failedCount >= maxFailedAttempts) {
            final lockUntil = now.add(lockoutDuration);
            await docRef.update({
              'failedAttempts': failedCount,
              'lastAttemptAt': Timestamp.fromDate(now),
              'lockedUntil': Timestamp.fromDate(lockUntil),
              'attempts': attempts,
            });

            print('🔒 Account locked until: $lockUntil');

            // Log security event
            await AuditService.log(
              action: AuditAction.systemWarning,
              description: 'Account locked due to $maxFailedAttempts failed login attempts: $email',
              actorId: 'system',
              actorEmail: email,
              actorName: 'Security System',
              actorType: 'system',
              category: 'security',
              riskLevel: RiskLevel.high,
              metadata: {
                'failedAttempts': failedCount,
                'lockedUntil': lockUntil.toIso8601String(),
                'reason': 'excessive_failed_attempts',
              },
            );
          } else {
            await docRef.update({
              'failedAttempts': failedCount,
              'lastAttemptAt': Timestamp.fromDate(now),
              'attempts': attempts,
            });

            print('⚠️ Failed attempt $failedCount of $maxFailedAttempts');

            // Log warning if approaching lockout
            if (failedCount >= maxFailedAttempts - 2) {
              await AuditService.log(
                action: AuditAction.systemWarning,
                description: 'Multiple failed login attempts detected: $email ($failedCount/$maxFailedAttempts)',
                actorId: 'system',
                actorEmail: email,
                actorName: 'Security System',
                actorType: 'system',
                category: 'security',
                riskLevel: RiskLevel.medium,
                metadata: {
                  'failedAttempts': failedCount,
                  'maxAttempts': maxFailedAttempts,
                  'remainingAttempts': maxFailedAttempts - failedCount,
                },
              );
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error recording failed attempt: $e');
      // Don't throw - we don't want security tracking to break login flow
    }
  }

  /// Record a successful login (clears failed attempts)
  static Future<void> recordSuccessfulLogin({
    required String email,
    String? userAgent,
    String? ipAddress,
  }) async {
    try {
      print('✅ Recording successful login for: $email');

      final docRef = _firestore
          .collection('security_attempts')
          .doc(_sanitizeEmail(email));

      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        final hadFailedAttempts = (data['failedAttempts'] as int? ?? 0) > 0;

        // Clear failed attempts and lockout
        await docRef.update({
          'failedAttempts': 0,
          'lockedUntil': null,
          'lastSuccessfulLogin': Timestamp.fromDate(DateTime.now()),
          'lastSuccessfulIp': ipAddress,
        });

        if (hadFailedAttempts) {
          print('✅ Cleared failed attempts after successful login');
        }
      } else {
        // Create record for first successful login
        await docRef.set({
          'email': email,
          'failedAttempts': 0,
          'lockedUntil': null,
          'lastSuccessfulLogin': Timestamp.fromDate(DateTime.now()),
          'lastSuccessfulIp': ipAddress,
          'firstAttemptAt': Timestamp.fromDate(DateTime.now()),
          'lastAttemptAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      print('❌ Error recording successful login: $e');
      // Don't throw - we don't want security tracking to break login flow
    }
  }

  /// Get number of failed attempts for an email
  static Future<int> getFailedAttemptCount(String email) async {
    try {
      final doc = await _firestore
          .collection('security_attempts')
          .doc(_sanitizeEmail(email))
          .get();

      if (!doc.exists) return 0;

      final data = doc.data()!;
      final firstAttempt = (data['firstAttemptAt'] as Timestamp?)?.toDate();
      
      if (firstAttempt == null) return 0;

      final now = DateTime.now();
      final windowExpired = now.difference(firstAttempt) > attemptWindowDuration;

      if (windowExpired) {
        return 0; // Window expired, count doesn't matter
      }

      return data['failedAttempts'] as int? ?? 0;
    } catch (e) {
      print('❌ Error getting failed attempt count: $e');
      return 0;
    }
  }

  /// Clear lockout for an account (admin function)
  static Future<void> clearLockoutManually(String email) async {
    try {
      print('🔓 Manually clearing lockout for: $email');

      await _clearLockout(email);

      // Log admin action
      await AuditService.log(
        action: AuditAction.adminAccessedLogs,
        description: 'Manually cleared account lockout for: $email',
        actorType: 'admin',
        category: 'security',
        riskLevel: RiskLevel.medium,
        metadata: {
          'targetEmail': email,
          'action': 'clear_lockout',
        },
      );

      print('✅ Lockout cleared');
    } catch (e) {
      print('❌ Error clearing lockout: $e');
      throw Exception('Failed to clear lockout');
    }
  }

  /// Internal method to clear lockout
  static Future<void> _clearLockout(String email) async {
    await _firestore
        .collection('security_attempts')
        .doc(_sanitizeEmail(email))
        .update({
      'lockedUntil': null,
      'failedAttempts': 0,
    });
  }

  /// Sanitize email for use as document ID
  static String _sanitizeEmail(String email) {
    return email.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9@._-]'), '_');
  }

  /// Check for suspicious login patterns
  static Future<bool> detectSuspiciousActivity({
    required String email,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final doc = await _firestore
          .collection('security_attempts')
          .doc(_sanitizeEmail(email))
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final attempts = List<Map<String, dynamic>>.from(data['attempts'] ?? []);

      if (attempts.isEmpty) return false;

      // Check for rapid-fire attempts (more than 3 in 1 minute)
      final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
      final recentAttempts = attempts.where((attempt) {
        final timestamp = (attempt['timestamp'] as Timestamp).toDate();
        return timestamp.isAfter(oneMinuteAgo);
      }).length;

      if (recentAttempts > 3) {
        print('⚠️ Suspicious activity: Rapid-fire attempts detected');
        return true;
      }

      // Check for IP address changes (if available)
      if (ipAddress != null) {
        final lastSuccessfulIp = data['lastSuccessfulIp'] as String?;
        if (lastSuccessfulIp != null && lastSuccessfulIp != ipAddress) {
          print('⚠️ Suspicious activity: IP address changed');
          // Note: This is just a warning, not blocking
        }
      }

      return false;
    } catch (e) {
      print('❌ Error detecting suspicious activity: $e');
      return false;
    }
  }

  /// Get security statistics for admin dashboard
  static Future<Map<String, dynamic>> getSecurityStats() async {
    try {
      final now = DateTime.now();
      final last24Hours = now.subtract(const Duration(hours: 24));

      final snapshot = await _firestore
          .collection('security_attempts')
          .where('lastAttemptAt', isGreaterThan: Timestamp.fromDate(last24Hours))
          .get();

      int totalFailedAttempts = 0;
      int lockedAccounts = 0;
      int suspiciousActivities = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final failedAttempts = data['failedAttempts'] as int? ?? 0;
        final lockedUntil = data['lockedUntil'] as Timestamp?;

        totalFailedAttempts += failedAttempts;

        if (lockedUntil != null && 
            lockedUntil.toDate().isAfter(now)) {
          lockedAccounts++;
        }

        if (failedAttempts >= maxFailedAttempts - 1) {
          suspiciousActivities++;
        }
      }

      return {
        'totalFailedAttempts': totalFailedAttempts,
        'lockedAccounts': lockedAccounts,
        'suspiciousActivities': suspiciousActivities,
        'monitoredAccounts': snapshot.docs.length,
        'timestamp': now.toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting security stats: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}

