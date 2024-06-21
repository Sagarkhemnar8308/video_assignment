import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_app/ui/auth/signup.dart';
import 'package:video_app/ui/screens/homescreen.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    if (userId != null) {
      Future.delayed(
        const Duration(seconds: 3),
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        },
      );
    } else {
      Future.delayed(
        const Duration(seconds: 3),
        () {
          Future.delayed(
            const Duration(seconds: 3),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
          );
        },
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        15,
        14,
        51,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ),
          child: Image.asset("asset/images/app-logo.png"),
        )),
      ),
    );
  }
}
