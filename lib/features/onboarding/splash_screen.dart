import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/features/onboarding/onboarding_screen.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/features/auth/login_screen.dart';
import 'package:npc/features/home/home_page_screen.dart';
import 'package:npc/core/services/token_service.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/profile_view_model.dart';

// App khulnay per sab se pehli nazar aanay wali screen (Logo Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  // Navigation flow tay karna: Onboarding dekhi hai ya nahi? Login hai ya nahi?
  Future<void> _navigate() async {
    // 2 seconds ka intezar (Splash effect ke liye)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Custom Token check kryn gay Session persistence ke liye
    final String? token = await TokenService().getAccessToken();
    // Fallback logic for Firebase users
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      // Pehli dafa app khuli hai -> Onboarding slides per jao
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingMain()),
      );
    } else {
      if (token != null || currentUser != null) {
        // User pehle se login hai -> Pehle profile fetch kryn gay taake Home pe data nazar aaye
        final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
        bool success = await profileVM.getProfile();

        if (success) {
          // Profile mil gayi -> Home screen per jao
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePageScreen()),
          );
        } else {
          // Agar profile fetch fail ho jaye (e.g. invalid token), to Login pe bhej dain
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // User login nahi hai -> Login screen per jao
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: Center(
        child: Image.asset(AppAssets.splashLogo, width: 160, height: 160),
      ),
    );
  }
}
