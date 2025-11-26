import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/email_verification_page.dart';
import 'pages/user_dashboard.dart';
import 'pages/firestore_debug_page.dart';
import 'pages/admin_recovery_page.dart';
import 'pages/admin_main_layout.dart';
import 'providers/auth_provider.dart';
import 'providers/ui_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UIProvider()),
      ],
      child: MaterialApp(
        title: 'RoboCleanerBuddy',
        theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: const SignInPage(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/sign-in': (context) => const SignInPage(),
          '/sign-up': (context) => const SignUpPage(),
          '/email-verification': (context) {
            final email = ModalRoute.of(context)?.settings.arguments as String?;
            return EmailVerificationPage(email: email ?? '');
          },
          '/admin-dashboard': (context) => const AdminMainLayout(),
          '/admin-panel': (context) => const AdminMainLayout(),
          '/user-dashboard': (context) => const UserDashboard(),
          '/firestore-debug': (context) => const FirestoreDebugPage(),
          '/admin-recovery': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            return AdminRecoveryPage(
              uid: args?['uid'] ?? '',
              email: args?['email'] ?? '',
            );
          },
        },
      ),
    );
  }
}
