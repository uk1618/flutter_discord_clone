import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_text.dart';
import 'package:flutter_whatsapp_clone/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import '../components/custom_button.dart';
import '../components/custom_textfield.dart';
import '../constants/custom_color.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  CustomColors _customColors = CustomColors();
  RegisterText _registerText = RegisterText();

//? text controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPassController = TextEditingController();

  //? sign up user
  void signUp() async {
    if (passwordController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_registerText.passwordDontMatch)));
      return;
    }
    //* get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailandPassword(
          emailController.text, passwordController.text, "");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    RegisterText _registerText = RegisterText();
    return Scaffold(
      backgroundColor: _customColors.dcDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
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
                //* hesap oluşturma başlığı
                Text(
                  _registerText.mainTitle,
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
                  hintText: _registerText.email,
                  controller: emailController,
                ),
          
                const SizedBox(
                  height: 50,
                ),
                //* şifre textfield
                CmTextField(
                  obscureText: true,
                  hintText: _registerText.password,
                  controller: passwordController,
                ),
          
                const SizedBox(
                  height: 50,
                ),
                //* şifreyi doğrulama textfield
                CmTextField(
                  obscureText: true,
                  hintText: _registerText.repeatPassword,
                  controller: confirmPassController,
                ),
          
                const SizedBox(
                  height: 50,
                ),
                //* kayıt ol butonu
                Container(
                    width: double.infinity,
                    height: 60,
                    child: CmButton(onTap: signUp, text: _registerText.signUp)),
          
                const SizedBox(
                  height: 10,
                ),
                //* Zaten bir hesabınız mevcut mu ?
          
                TextButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(onTap: (){}),));
                    },
                    child: Text(_registerText.alreadyMember))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
