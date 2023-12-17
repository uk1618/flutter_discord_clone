import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/firebase_options.dart';
import 'package:flutter_whatsapp_clone/pages/register_page.dart';
import 'package:flutter_whatsapp_clone/services/auth/auth_gate.dart';
import 'package:flutter_whatsapp_clone/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'constants/custom_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  CustomColors _customColors = CustomColors();
  ThemeData darkThemeWithCustomBackground() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor:
          _customColors.dcDark, // Change this to your preferred background color
      // You can customize other theme properties here if needed
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AuthGate()
    );
  }
}
