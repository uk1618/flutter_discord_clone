import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/constants/custom_text.dart';
import '../components/custom_button.dart';
import 'login_page.dart';
import 'register_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    OnboardText _onboardText = OnboardText();
    CustomColors _customColors = CustomColors();
    return Scaffold(
      backgroundColor: _customColors.dcDark,
      body: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32),
        child: Column(
          children: [
            SizedBox(
                height: 150,
                width: 200,
                child: Image.asset('assets/discord_brand.png')),
            SizedBox(
              height: 12,
            ),
            SvgPicture.asset('assets/onboarding_bg.svg'),
            SizedBox(
              height: 12,
            ),
            Text(
              _onboardText.welcomeText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              _onboardText.subTitleText,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(
              height: 60,
            ),
            Container(
              width: double.infinity,
              height: 50,
              child: CmButton(
                text: _onboardText.registerText,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(
                          onTap: () {},
                        ),
                      ));
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                width: double.infinity,
                height: 50,
                child: CmButton(
                  text: _onboardText.loginText,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(
                            onTap: () {},
                          ),
                        ));
                  },
                )),
          ],
        ),
      ),
    );
  }
}
