import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/features/onboarding/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:npc/view_models/auth_view_model.dart';
import 'package:npc/view_models/profile_view_model.dart';
import 'package:npc/view_models/quest_view_model.dart';
import 'package:npc/view_models/s3_view_model.dart';
import 'package:npc/view_models/privacy_policy_view_model.dart';
import 'package:npc/view_models/about_app_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, ProfileViewModel>(
          create: (_) => ProfileViewModel(),
          update: (context, authVM, profileVM) {
            profileVM?.syncUserId(authVM.userId);
            return profileVM!;
          },
        ),
        ChangeNotifierProvider(create: (_) => QuestViewModel()),
        ChangeNotifierProvider(create: (_) => S3ViewModel()),
        ChangeNotifierProvider(create: (_) => PrivacyPolicyViewModel()),
        ChangeNotifierProvider(create: (_) => AboutAppViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true, // font size will be adjusted based on the screen size
      splitScreenMode: true, //
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
