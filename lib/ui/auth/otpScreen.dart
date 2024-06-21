import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_app/ui/auth/userInfoScreen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.verifyId});
  final String verifyId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController firstOtp = TextEditingController();
  final TextEditingController secondOtp = TextEditingController();
  final TextEditingController thirdOtp = TextEditingController();
  final TextEditingController fourthOtp = TextEditingController();
  final TextEditingController fifthOtp = TextEditingController();
  final TextEditingController sixthOtp = TextEditingController();

  int secondsRemaining = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void resendOtp() {
    setState(() {
      secondsRemaining = 30;
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 51),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: Image.asset(
                "asset/images/app-logo.png",
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _textFieldOTP(
                  first: true,
                  otp: firstOtp,
                ),
                _textFieldOTP(
                  first: false,
                  otp: secondOtp,
                ),
                _textFieldOTP(
                  first: false,
                  otp: thirdOtp,
                ),
                _textFieldOTP(
                  first: false,
                  otp: fourthOtp,
                ),
                _textFieldOTP(
                  first: false,
                  otp: fifthOtp,
                ),
                _textFieldOTP(
                  first: false,
                  last: true,
                  otp: sixthOtp,
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: secondsRemaining == 0 ? resendOtp : null,
                child: secondsRemaining > 0
                    ? Text(
                        "$secondsRemaining s",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      )
                    : GestureDetector(
                        onTap: resendOtp,
                        child: const Text(
                          "Didn't get OTP ? resend it",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              width: 170,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    )),
                onPressed: () async {
                  String otpController =
                      "${firstOtp.text}${secondOtp.text}${thirdOtp.text}${fourthOtp.text}${fifthOtp.text}${sixthOtp.text}";
                  print("otp is $otpController and ${widget.verifyId}");
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                      verificationId: widget.verifyId,
                      smsCode: otpController,
                    );
                    await FirebaseAuth.instance
                        .signInWithCredential(credential)
                        .then((value) async {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserInfoScreen(),
                        ),
                        (route) => false,
                      );
                    });
                    validmessage();
                  } catch (e, stk) {
                    print(
                      'Error signing in: $e , $stk',
                    );
                    invalidmessage();
                  }
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  invalidmessage() {
    Fluttertoast.showToast(msg: "Invalid OTP !");
  }

  validmessage() {
    Fluttertoast.showToast(msg: "Otp Verified Successfully");
  }

  Widget _textFieldOTP(
      {required bool first, last, required TextEditingController otp}) {
    return Flexible(
      child: TextField(
        controller: otp,
        cursorColor: Colors.white,
        autofocus: true,
        onChanged: (value) {
          if (value.isNotEmpty || first == true) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty || last == true) {
            FocusScope.of(context).previousFocus();
          }
          // print(otp);
        },
        showCursor: true,
        readOnly: false,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                width: 2,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
