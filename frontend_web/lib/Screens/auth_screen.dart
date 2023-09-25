import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lottie/lottie.dart';

import '../AppLocalizations.dart';
import 'main_table.dart';
import '../auth.dart';
import '../main.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen();

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login; //init mode is login
  Map<String, String> _authData = {
    //map that will contain the input of the user
    'name': '',
    'email': '',
    'password': '',
    'confirm_password': '',
  };
  var _isLoading = false; //check if need to wait to a respond
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  var _valueDropdown;
  var auth_with_server = Auth();

//open dialog if there is error from the server in the register ot login
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('ErrorOccurred')),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('OK')),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

//function that submit when the user click the button for login or register
//this function call to a provider auth for doing the action
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      //check the validtaion
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    var user;
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        user = await auth_with_server.login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        //   // Sign user up
        user = await auth_with_server.signup(
            _authData['name'],
            _authData['email'],
            _authData['password'],
            _authData['confirm_password']);
      }
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (__) => MainTable(doctorModel: user)));
    } catch (error) {
      // const errorMessage =
      //     'Could not authenticate you. Please try again later.';
      _showErrorDialog(error.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

//funtcion that sign up the user with is google acount
//this function call to a provider auth for doing the action
  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await auth_with_server.googleLogin();
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

//funtcion that switch mode from login to register or vice versa
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _passwordController.text = '';
        _emailController.text = '';
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _emailController.text = '';
        _passwordController.text = '';
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var f = AppLocalizations.of(context)!.locale.languageCode;
    if (f == 'en')
      _valueDropdown = 'English';
    else
      _valueDropdown = "עברית";
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 9, 40, 52),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          // actions: [
          // DropdownButton(
          //   style: GoogleFonts.nunito(
          //               textStyle: TextStyle(
          //             fontSize: 24.0,
          //             color: Color.fromARGB(255, 228, 217, 206),
          //           )),
          //   dropdownColor:  Color.fromARGB(255, 9, 40, 52),
          //   value: _valueDropdown,
          //   items: <DropdownMenuItem<String>>[
          //     DropdownMenuItem(
          //       child: Text('English'),
          //       value: 'English',
          //     ),
          //     DropdownMenuItem(child: Text('עברית'), value: 'עברית'),
          //   ],
          //   underline: SizedBox(
          //     height: 0,
          //   ),
          //   onChanged: (value) {
          //     Locale l = Locale('he', 'IL');
          //     if (value == 'English') {
          //       l = Locale('en', 'US');
          //     } else {
          //       l = Locale('he', 'IL');
          //     }

          //     MyApp.of(context)!.setLocale(l);
          //     AppLocalizations.of(context)!.changeLocale(l);
          //   },
          // ),
        ]),
      ),
      body: SingleChildScrollView(
          child: Card(
        color: Color.fromARGB(255, 244, 249, 251),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  //the form of the login or the register
                  height: deviceSize.height,
                  width: deviceSize.width * 0.4,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        if (_authMode == AuthMode.Signup)
                          AutoSizeText(
                              AppLocalizations.of(context)!
                                  .translate('SignUpTitle'),
                              maxLines: 1,
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 55.0,
                                  height: 2.5,
                                ),
                              )),
                        if (_authMode == AuthMode.Login)
                          AutoSizeText(
                              AppLocalizations.of(context)!
                                  .translate('SignInTitle'),
                              maxLines: 1,
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 55.0,
                                    height: 3.0),
                              )),
                        if (_authMode == AuthMode.Signup)
                          TextFormField(
                            key: Key("FullName"),
                            //text input for the name of the user
                            enabled: _authMode == AuthMode.Signup,
                            decoration: InputDecoration(
                                icon: Icon(Icons.person_outline),
                                labelText: AppLocalizations.of(context)
                                    ?.translate('FullName')),
                            onSaved: (value) {
                              _authData['name'] = value ?? '';
                            },
                          ),
                        SizedBox(
                          height: 5.0,
                        ),
                        TextFormField(
                          key: Key('email'),
                          //text input for the email of the user
                          decoration: InputDecoration(
                              icon: Icon(Icons.email_outlined),
                              labelText: AppLocalizations.of(context)
                                  ?.translate('Email')),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (String? value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return AppLocalizations.of(context)
                                  ?.translate('InvalidEmail');
                            }
                          },
                          onSaved: (value) {
                            _authData['email'] = value ?? '';
                          },
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        TextFormField(
                          onFieldSubmitted: (value) {
                            if (_authMode == AuthMode.Login) {
                              _submit();
                            }
                          },
                          //text input for the password of the user
                          decoration: InputDecoration(
                              icon: Icon(Icons.password),
                              labelText: AppLocalizations.of(context)
                                  ?.translate('Password')),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)
                                  ?.translate('PasswordEmpty');
                            }
                            if (value.length < 6) {
                              return AppLocalizations.of(context)
                                  ?.translate('PasswordShort');
                            }
                          },
                          onSaved: (value) {
                            _authData['password'] = value ?? '';
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        if (_authMode == AuthMode.Signup)
                          TextFormField(
                            key: Key("ConfirmPassword"),
                            //text input for confirm password
                            enabled: _authMode == AuthMode.Signup,
                            decoration: InputDecoration(
                                icon: Icon(Icons.password),
                                labelText: AppLocalizations.of(context)
                                    ?.translate('ConfirmPassword')),
                            obscureText: true,
                            onSaved: (value) {
                              _authData['confirm_password'] = value ?? '';
                            },
                            onFieldSubmitted: (value) {
                              _submit();
                            },
                            validator: _authMode == AuthMode.Signup
                                ? (value) {
                                    if (value != _passwordController.text) {
                                      return AppLocalizations.of(context)
                                          ?.translate('PasswordsNotMatch');
                                    }
                                  }
                                : null,
                          ),
                        SizedBox(
                          height: 10.0,
                        ),
                        if (_isLoading)
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Lottie.asset('assets/animation/load.json'))

                        // CircularProgressIndicator()
                        else
                          SizedBox(
                            height: 40, //height of button
                            width: 200,
                            child: ElevatedButton(
                              key: Key("btnSignIn"),
                              child: Text(_authMode == AuthMode.Login
                                  ? AppLocalizations.of(context)!
                                      .translate('Login')
                                  : AppLocalizations.of(context)!
                                      .translate('SignUp')),
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(255, 99, 170, 101),
                                onPrimary: Colors.white,
                                shadowColor: Color.fromARGB(255, 127, 208, 130),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                elevation: 8.0,
                              ),
                              onPressed: _submit,
                            ),
                          ),
                        TextButton(
                          key: Key("btnSwitchMode"),
                          child: Text(
                              '${_authMode == AuthMode.Login ? AppLocalizations.of(context)!.translate('NoHaveAccount') : AppLocalizations.of(context)!.translate('HaveAccount')}'),
                          onPressed: _switchAuthMode,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: SignInButton(
                            Buttons.Google,
                            onPressed: _signup,
                            elevation: 4.0,
                            padding: EdgeInsets.all(2.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  height: deviceSize.height,
                  width: deviceSize.width * 0.4,
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Lottie.asset('assets/animation/Relax.json')),
                )
              ],
            ),
          ],
        ),
      )),
    );
  }
}
