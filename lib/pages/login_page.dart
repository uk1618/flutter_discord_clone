import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/components/custom_button.dart';
import 'package:flutter_whatsapp_clone/components/custom_textfield.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/constants/custom_text.dart';
import 'package:flutter_whatsapp_clone/pages/register_page.dart';
import 'package:flutter_whatsapp_clone/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //? text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //? sign in user
  void signIn() async {
    //* get the  auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailandPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    LoginText _loginText = LoginText();
    CustomColors _customColors = CustomColors();
    return Scaffold(
      backgroundColor: _customColors.dcDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 150,
                ),
                //* logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Image.asset(
                    "assets/discord_brand.png",
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                //* Tekrardan Hoşgeldin Mesajı
                Text(
                  _loginText.welcomeText,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),
                //* email textfield
                CmTextField(
                  obscureText: false,
                  hintText: _loginText.email,
                  controller: emailController,
                ),

                const SizedBox(
                  height: 50,
                ),
                //* şifre textfield
                CmTextField(
                  obscureText: true,
                  hintText: _loginText.password,
                  controller: passwordController,
                ),

                const SizedBox(
                  height: 50,
                ),
                //* giriş yap button
                Container(
                    width: double.infinity,
                    height: 60,
                    child: CmButton(onTap: signIn, text: _loginText.signIn)),

                const SizedBox(
                  height: 50,
                ),
                //* hemen kayıt ol butonu
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(onTap: () {}),
                          ));
                    },
                    child: Text(
                      _loginText.notAmember,
                      style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
