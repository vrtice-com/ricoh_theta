import 'package:flutter/material.dart';
import 'package:ricoh_theta_example/pages/connect.dart';
import 'package:ricoh_theta_example/pages/home.dart';
import 'package:ricoh_theta_example/pages/image_view.dart';
import 'package:ricoh_theta_example/pages/settings.dart';

void main() {
  runApp(const RicohThetaApp());
}

class RicohThetaApp extends StatefulWidget {
  const RicohThetaApp({super.key});

  @override
  State<RicohThetaApp> createState() => _RicohThetaAppState();
}

class _RicohThetaAppState extends State<RicohThetaApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const ConnectPage(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => const HomePage(),
            );
          case '/home/image-view':
            final args = (settings.arguments as Map<String, String>);
            return MaterialPageRoute(
              builder: (context) => ImageViewPage(
                fileId: args['fileId']!,
              ),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const ConnectPage(),
            );
        }
      },
    );
  }
}
