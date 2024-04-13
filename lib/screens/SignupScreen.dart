import 'package:audioapp/screens/tabsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;
class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  bool _toggleValue = false;
  bool _checkBoxValue = false;

  void _submit() async {
  final isValid = _formKey.currentState!.validate();

  if (!isValid) {
    return;
  }

  _formKey.currentState!.save();

  try {
    if (_isLogin) {
      await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
    } else {
      final userCredentials = await _firebase
          .createUserWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);

      // Navigate to home screen after sign up
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TabsScreen(),
        ),
      );
    }
  } on FirebaseAuthException catch (error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Authentication failed.'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 30, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/signuplogo.png"),
              SizedBox(height: 10),
              Row(
                key: _formKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
  decoration: InputDecoration(
    labelText: "Email",
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.emailAddress,
  textCapitalization: TextCapitalization.none,
  validator: (value) {
    if (value == null ||
        value.trim().isEmpty ||
        !value.contains('@')) {
      return 'Please enter a valid email address.';
    }
    return null;
  },
  onSaved: (value) {
    _enteredEmail = value!;
  },
),

              SizedBox(height: 10),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
              ),
              SizedBox(height: 10),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
                 validator: (value) {
    if (value != _enteredPassword) {
      return 'Passwords do not match.';
    }
    return null;
  },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Switch(
                    
                    value: _toggleValue,
                    onChanged: (value) {
                      setState(() {
                        _toggleValue = value;
                      });
                    },
                  ),
                  Text('Save password?'),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: _checkBoxValue,
                    onChanged: (value) {
                      setState(() {
                        _checkBoxValue = value!;
                      });
                    },
                  ),
                  RichText(
                    text: TextSpan(
                      text: "I agree to the ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Terms and Conditions",
                          style: TextStyle(color: Colors.orange),
                        ),
                        TextSpan(text: " of @company"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange),
                  minimumSize: MaterialStateProperty.all(
                    Size(double.infinity, 50),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(237, 0, 0, 0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Sign up with",
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        "assets/images/google.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 60),
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        "assets/images/facebook.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 60),
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        "assets/images/Twitter-Logo.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already Have an Account?",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => Signin(),
                      //   ),
                      // );
                    },
                    child: Text(
                    " Sign In",
                    style: TextStyle(color: Colors.orange, fontSize: 25),
                  ),
                  ),


                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
