import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_page.dart';
import 'screens/add_property.dart';
import 'screens/property_detail.dart';
import 'screens/edit_property_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../models/property_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qjadmavgzuzrpyjmrjec.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYWRtYXZnenV6cnB5am1yamVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NjE2ODIsImV4cCI6MjA1OTIzNzY4Mn0.2xljHdHALzz5KWbf_g5z4Ut4BgrevvMsFwJbyvppn-o',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // Use AuthWrapper as home instead of routes
      routes: {
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/add_property': (context) => const AddPropertyPage(),
        '/property_detail': (context) {
          final propertyId = ModalRoute.of(context)!.settings.arguments as int;
          return PropertyDetailPage(propertyId: propertyId);
        },
        '/edit_property': (context) {
          final PropertyModel property =
              ModalRoute.of(context)!.settings.arguments as PropertyModel;
          return EditPropertyPage(property: property);
        },
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (mounted) {
        setState(() {
          // This will trigger a rebuild when auth state changes
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // If user is logged in, show HomePage
    if (session != null) {
      return const HomePage();
    }

    // If user is not logged in, show SignupPage as default
    return const SignupPage();
  }
}
