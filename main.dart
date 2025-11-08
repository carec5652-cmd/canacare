import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:admin_can_care/config/routes.dart';
import 'package:admin_can_care/ui/screens/auth/admin_login_screen.dart';
import 'package:admin_can_care/ui/screens/dashboard/dashboard_screen.dart';
import 'package:admin_can_care/data/services/firebase_auth_service.dart';
import 'package:admin_can_care/provider/app_state_provider.dart';
import 'package:admin_can_care/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(create: (_) => AppStateProvider(), child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Can Care Admin',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: appState.themeMode,
      locale: appState.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;

          // Allow anonymous (guest) users to access dashboard
          if (user.isAnonymous) {
            return const DashboardScreen();
          }

          // Verify admin role for email users
          return FutureBuilder<bool>(
            future: FirebaseAuthService().isAdmin(user.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // If admin verification succeeded
              if (adminSnapshot.data == true) {
                return const DashboardScreen();
              }

              // Not an admin or no admin document found
              // Sign out and show login screen
              WidgetsBinding.instance.addPostFrameCallback((_) {
                FirebaseAuth.instance.signOut();
              });
              return const AdminLoginScreen();
            },
          );
        }

        return const AdminLoginScreen();
      },
    );
  }
}
