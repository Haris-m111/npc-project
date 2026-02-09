import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:npc/features/auth/login_screen.dart';
import 'package:npc/core/constants/app_assets.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';

// App ka ta'aruf dikhanay wali slides (Onboarding screens)
class OnboardingMain extends StatefulWidget {
  const OnboardingMain({super.key});

  @override
  State<OnboardingMain> createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  // Onboarding khatam kar ke 'hasSeenOnboarding' ko true set karna aur login per jana
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ... (PageView code unchanged) ...
            // Swipe hone wali slides (PageView)
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index; // Current slide index track karna
                });
              },
              children: [
                onboardingPage(
                  image: AppAssets.onboarding1,
                  title: "Welcome to the NPC!",
                  description:
                      "Get real-time challenges from event admins, complete them with photo proof, and track your progress as you go",
                  showSkip: true,
                ),
                onboardingPage(
                  image: AppAssets.onboarding2,
                  title: "Stay Updated",
                  description:
                      "Never miss a moment with real-time notifications. The NPC keeps you informed whenever a new task is assigned, a submission is reviewed, or your progress changes",
                  showSkip: false,
                ),
              ],
            ),

            // ... (Dots code unchanged) ...
            // Slides ke neeche walay points (Indicators)
            Positioned(
              bottom: 142,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    width: currentIndex == index ? 40 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? AppColors.primary
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),

            //  NEXT BUTTON
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (currentIndex == 0) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 140, vertical: 12),
                ),
                child: Text(
                  currentIndex == 0 ? "NEXT" : "NEXT",
                  style: AppTextStyles.headingmedium.copyWith(
                    fontFamily: "Nunito",
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SINGLE ONBOARDING PAGE UI

  // Ek individual slide banane ka widget
  Widget onboardingPage({
    required String image,
    required String title,
    required String description,
    required bool showSkip,
  }) {
    return Stack(
      children: [
        // Background image aur uske oopar halka sa andhera (Darken overlay)
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                AppColors.black.withAlpha(30),
                BlendMode.darken,
              ),
            ),
          ),
        ),

        // Skip button
        if (showSkip)
          Positioned(
            top: 80,
            right: 20,
            child: GestureDetector(
              onTap: () {
                _completeOnboarding();
              },
              child: Text("Skip", style: AppTextStyles.headingmedium),
            ),
          ),

        // Text content
        Positioned(
          bottom: 192,
          left: 10,
          right: 10,
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.headinglarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                description,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
