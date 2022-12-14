// firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hypergaragesale/screens/browse_posts_activity.dart';
import 'package:hypergaragesale/screens/registration_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../supplemental/cut_corners_border.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  /// Create variables and then set them equal to the value that the user types
  String email;
  String password;

  /// let the user know the app is running
  bool showSpinner = false;

  /// Add text editing controllers, to clear the text fields' values
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 100.0),
              Column(
                children: <Widget>[
                  Image.asset('images/login_images/garage_sale.png'),
                  SizedBox(height: 16.0),
                  Text('Hyper Garage Sale',
                      style: Theme.of(context).textTheme.headline4)
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: CutCornersBorder(),
                ),
              ),
              SizedBox(height: 15.0),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  border: CutCornersBorder(),
                ),
                obscureText: true,
              ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      ),
                    ),
                    child: Text('CANCEL'),
                    onPressed: () {
                      _usernameController.clear();
                      _passwordController.clear();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      ),
                    ),
                    child: Text('REGISTER'),
                    onPressed: () {
                      Navigator.pushNamed(context, RegistrationScreen.id);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 8.0,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      ),
                    ),
                    child: Text('SIGN IN'),
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        final user = await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                        if (user != null) {
                          Navigator.pushNamed(context, BrowsePostsScreen.id);
                        }
                      } catch (e) {
                        print(e);
                      } finally {
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    },
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
