import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../mainScreen/ScreenWithBottomNav.dart';
import 'LoginViewModel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: _LoginScreen(),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  @override
  __LoginScreenState createState() => __LoginScreenState();
}

class __LoginScreenState extends State<_LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _verificationId = '';
  String _countryCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(
                height: 80,
                width: 20,
              ),
              const Text(
                'Welcome to Task Manager', // Replace with your description
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
                width: 20,
              ),
              const Text(
                  'Unlock seamless task management – Login or Sign Up to Task Manager Hub with the ease of Phone OTP for effortless productivity.',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.start),
              const SizedBox(height: 20),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  // Handle changes in phone number input
                  print(number.phoneNumber);
                  _countryCode = number.dialCode!;
                },
                onInputValidated: (bool value) {
                  // Validate phone number
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: const TextStyle(color: Colors.black),
                textFieldController: _phoneNumberController,
                formatInput: false,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                inputDecoration: const InputDecoration(
                  labelText: 'Mobile Number',
                ),
                onSaved: (PhoneNumber? number) {
                  // Save the phone number
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                child: PinCodeTextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  hintCharacter: '',
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter OTP';
                    }
                    return null;
                  },
                  appContext: this.context,
                  length: 6,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Validate the form
                  if (_formKey.currentState?.validate() ?? false) {
                    // Perform login logic here
                    await _verifyPhoneNumber(context);
                  }
                },
                onLongPress: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenWithBottomNav(),
                    ),
                  );
                },
                child: const Text('Get OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPhoneNumber(BuildContext context) async {
    try {
      verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
        await Provider.of<LoginViewModel>(context, listen: false)
            .signInWithPhoneNumber(
          _phoneNumberController.text,
          phoneAuthCredential.verificationId!,
          phoneAuthCredential.smsCode!,
        );

        // Navigate to TodoScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ScreenWithBottomNav(),
          ),
        );
      }

      verificationFailed(FirebaseAuthException authException) {
        // Handle verification failed
        print('Verification Failed: ${authException.message}');
      }

      codeSent(String verificationId, int? resendToken) async {
        _verificationId = verificationId;
      }

      codeAutoRetrievalTimeout(String verificationId) {
        _verificationId = verificationId;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$_countryCode${_phoneNumberController.text}',
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      // Handle exceptions
      print(e.toString());
    }
  }
}
