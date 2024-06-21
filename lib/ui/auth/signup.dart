import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:video_app/ui/auth/otpScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

TextEditingController mobileController = TextEditingController(text: '');
bool showOtpField = false;
bool isSendingOTP = false;
bool info = false;

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode _focusNodemobile = FocusNode();
  final FocusNode _focusNodeotp = FocusNode();

  @override
  void dispose() {
    _focusNodemobile.dispose();
    _focusNodeotp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 15, 14, 51),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 200,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                child: Image.asset(
                  "asset/images/app-logo.png",
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                focusNode: _focusNodemobile,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter Mobile Number";
                  }
                  return null;
                },
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                controller: mobileController,
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: "Enter Mobile Number *",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(
                height: 20,
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
                    if (mobileController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Please Enter Mobile Number");
                    }
                    if (mobileController.text.isNotEmpty) {
                      setState(() {
                        isSendingOTP = true;
                      });
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException ex) {},
                        codeSent: (String verificationId, int? resendtoken) {
                          message();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(
                                verifyId: verificationId,
                              ),
                            ),
                          );
                          setState(() {
                            isSendingOTP = false;
                          });
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                        phoneNumber: "+91${mobileController.text.toString()}",
                      );
                    }
                  },
                  child: isSendingOTP
                      ? SizedBox(
                          height: 30,
                          width: 30,
                          child: LottieBuilder.asset(
                            "asset/lottie/loader.json",
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  message() {
    Fluttertoast.showToast(msg: "OTP sent Successfully !");
  }
}
