import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:npc/core/constants/app_colors.dart';
import 'package:npc/core/theme/text_styles.dart';
import 'package:npc/core/widgets/custom_appbar.dart';
import 'package:npc/core/widgets/custom_loading_indicator.dart';
import 'package:npc/view_models/privacy_policy_view_model.dart';
import 'package:npc/view_models/about_app_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// "About" ya "Privacy Policy" jaisi maloomat dikhanay wala screen
class AboutPrivacyScreen extends StatefulWidget {
  final String title; // Screen ka unwan (e.g., Privacy Policy)
  final String description; // Tafseeli maloomat (Fallback)

  const AboutPrivacyScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<AboutPrivacyScreen> createState() => _AboutPrivacyScreenState();
}

class _AboutPrivacyScreenState extends State<AboutPrivacyScreen> {
  @override
  void initState() {
    super.initState();
    // Har screen ke mutabiq sahi API call kryn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.title == "Privacy Policy") {
        Provider.of<PrivacyPolicyViewModel>(
          context,
          listen: false,
        ).fetchPrivacyPolicy();
      } else if (widget.title == "About App") {
        Provider.of<AboutAppViewModel>(context, listen: false).fetchAboutApp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 35.h, 20.w, 0),
              child: CustomAppBar(title: widget.title),
            ),
            Expanded(
              child: Consumer2<PrivacyPolicyViewModel, AboutAppViewModel>(
                builder: (context, policyVM, aboutVM, child) {
                  // Loading state handle kryn
                  bool isLoading =
                      (widget.title == "Privacy Policy" &&
                          policyVM.isLoading) ||
                      (widget.title == "About App" && aboutVM.isLoading);

                  if (isLoading) {
                    return const Center(child: CustomLoadingIndicator());
                  }

                  // Error message handle kryn
                  String? errorMessage = (widget.title == "Privacy Policy")
                      ? policyVM.errorMessage
                      : (widget.title == "About App")
                      ? aboutVM.errorMessage
                      : null;

                  if (errorMessage != null) {
                    return Center(
                      child: Text(
                        errorMessage,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Content nikalain
                  String? htmlContent;
                  if (widget.title == "Privacy Policy") {
                    htmlContent = policyVM.policy?.content;
                  } else if (widget.title == "About App") {
                    htmlContent = aboutVM.aboutApp?.content;
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTextStyles.mainheading),
                        SizedBox(height: 16.h),
                        // Agar API se HTML mil gya to wo dikhayen, warna fallback description
                        htmlContent != null
                            ? HtmlWidget(
                                htmlContent,
                                textStyle: AppTextStyles.bodysmall.copyWith(
                                  color: AppColors.textGrey,
                                  fontSize: 14.sp,
                                ),
                              )
                            : Text(
                                widget.description,
                                style: AppTextStyles.bodysmall.copyWith(
                                  color: AppColors.textGrey,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
