import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';
import '../AppLocalizations.dart';
import 'terms.dart';
import 'package:lottie/lottie.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({
    Key key,
  }) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool agree = true;
  bool agreeResearch = true;
  AuthMode _authMode = AuthMode.Login; //init mode is login
  Map<String, String> _authData = {
    //map that will contain the input of the user
    'name': '',
    'email': '',
    'password': '',
    'confirm_password': '',
    'doctor_id': '',
  };
  var _isLoading = false; //check if need to wait to a respond
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

//open dialog if there is error from the server in the register ot login
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('ErrorOccurred')),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text(AppLocalizations.of(context).translate('OK')),
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
    if (!_formKey.currentState.validate()) {
      //check the validtaion
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['name'],
            _authData['email'],
            _authData['password'],
            _authData['confirm_password'],
            _authData['doctor_id'],
            agreeResearch);
      }
    } on HttpException catch (error) {
      //if there is error from the server
      print(error);
      _showErrorDialog(error.toString());
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      print(error);
      _showErrorDialog(errorMessage);
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
      await Provider.of<Auth>(context, listen: false).googleLogin();
      //if this is the first time to enter the app,
      //show dialog that ask his approve to the research
      //check the first time by createdDate, if it happen for the last 5 minutes
      DateTime createdDate =
          Provider.of<Auth>(context, listen: false).createdDate;
      DateTime now = new DateTime.now();
      final difference = now.difference(createdDate).inMinutes;
      bool isR = false;
      TextEditingController _controller = TextEditingController();
      if (difference < 5) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Container(
              height: 120,
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText:
                          AppLocalizations.of(context).translate('DoctorID'),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Row(children: [
                    Text(
                        AppLocalizations.of(ctx).translate('ResearchApprove1')),
                    InkWell(
                      onTap: () {},
                      child: Text(
                          AppLocalizations.of(ctx)
                              .translate('ResearchApprove2'),
                          style: TextStyle(
                              color: Colors.lightBlue,
                              decoration: TextDecoration.underline)),
                    ),
                  ]),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(AppLocalizations.of(ctx).translate('Yes')),
                onPressed: () async {
                  isR = true;
                  Navigator.of(ctx).pop();
                },
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(ctx).translate('No')),
                onPressed: () async {
                  isR = false;
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
      var id = _controller.text;
      if (isR)
        await Provider.of<Auth>(context, listen: false)
            .ResearchGoogle(true, id);
      else
        await Provider.of<Auth>(context, listen: false)
            .ResearchGoogle(false, id);
    } on HttpException catch (error) {
      print(error);
      _showErrorDialog(error.toString());
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
        agree = false;
        agreeResearch = false;
        _passwordController.text = '';
        _emailController.text = '';
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        agree = true;
        agreeResearch = true;
        _emailController.text = '';
        _passwordController.text = '';
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return
      Container(
        color:Color.fromARGB(255, 61, 61, 61),
        child: SingleChildScrollView(
          child:
            Card(
                color:Color.fromARGB(255, 244, 249, 251),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 8.0,
              child:
                  Container(
                    //the form of the login or the register
                    height: deviceSize.height*1.12,
                    width: deviceSize.width * 0.8,
                    margin: EdgeInsets.only(top:5.0,bottom: 5.0,left:20,right: 20),
                    padding: EdgeInsets.fromLTRB(25.0, 16.0, 25.0, 16.0), // Adjust the padding as needed
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          if (_authMode == AuthMode.Signup)
                            AutoSizeText(
                                AppLocalizations.of(context).translate('SignUpTitle'),
                                maxLines: 1,
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 50.0,
                                    height: 1.5,
                                  ),
                                )),
                          if (_authMode == AuthMode.Login)
                            AutoSizeText(
                                AppLocalizations.of(context).translate('SignInTitle'),
                                maxLines: 1,
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 50.0,
                                      height: 3.0),
                                )),
                          if (_authMode == AuthMode.Signup)
                            TextFormField(
                              style: TextStyle(fontSize: 14),
                              key: Key("FullName"),
                              //text input for the name of the user
                              enabled: _authMode == AuthMode.Signup,
                              decoration: InputDecoration(
                                isDense: true,                   
                                  icon: Icon(Icons.person_outline),
                                  labelText: AppLocalizations.of(context)
                                      .translate('FullName')),
                              onSaved: (value) {
                                _authData['name'] = value;
                              },
                            ),
                          SizedBox(
                            height: 3.0,
                          ),
                          TextFormField(
                            key: Key('email'),
                            style: TextStyle(fontSize: 14),
                            //text input for the email of the user
                            decoration: InputDecoration(
                              isDense: true,                   
                                icon: Icon(Icons.email_outlined),
                                labelText:
                                    AppLocalizations.of(context).translate('Email')),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: (value) {
                              if (value.isEmpty || !value.contains('@')) {
                                return AppLocalizations.of(context)
                                    .translate('InvalidEmail');
                              }
                            },
                            onSaved: (value) {
                              _authData['email'] = value;
                            },
                          ),
                          SizedBox(
                            height: 3.0,
                          ),
                          TextFormField(
                            style: TextStyle(fontSize: 14),
                            key: Key('password'),
                            //text input for the password of the user
                            decoration: InputDecoration(
                                icon: Icon(Icons.password),
                                isDense: true,                   
                                labelText:
                                    AppLocalizations.of(context).translate('Password')),
                            obscureText: true,
                            controller: _passwordController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context)
                                    .translate('PasswordEmpty');
                              }
                              if (value.length < 6) {
                                return AppLocalizations.of(context)
                                    .translate('PasswordShort');
                              }
                            },
                            onSaved: (value) {
                              _authData['password'] = value;
                            },
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          if (_authMode == AuthMode.Signup)
                            TextFormField(
                              style: TextStyle(fontSize: 14),
                              key: Key("ConfirmPassword"),
                              //text input for confirm password
                              enabled: _authMode == AuthMode.Signup,
                              decoration: InputDecoration(
                                isDense: true,                   
                                  icon: Icon(Icons.password),
                                  labelText: AppLocalizations.of(context)
                                      .translate('ConfirmPassword')),
                              obscureText: true,
                              onSaved: (value) {
                                _authData['confirm_password'] = value;
                              },
                              validator: _authMode == AuthMode.Signup
                                  ? (value) {
                                      if (value != _passwordController.text) {
                                        return AppLocalizations.of(context)
                                            .translate('PasswordsNotMatch');
                                      }
                                    }
                                  : null,
                            ),
                          if (_authMode == AuthMode.Signup)
                            TextFormField(
                              style: TextStyle(fontSize: 14),
                              //text input for confirm password
                              enabled: _authMode == AuthMode.Signup,
                              decoration: InputDecoration(
                                isDense: true,                   
                                  icon: Icon(Icons.person_outline),
                                  labelText: AppLocalizations.of(context)
                                      .translate('DoctorID')),
                              obscureText: true,
                              onSaved: (value) {
                                _authData['doctor_id'] = value;
                              },
                            ),
                            if (_authMode ==
                              AuthMode
                                  .Signup)
                              SizedBox(height: 10.0,),    
                          if (_authMode ==
                              AuthMode
                                  .Signup) //ask to approve the terms, otherwise user can not register
                            Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          width: 40.0,
                                          height: 20.0,
                                          padding: EdgeInsets.only(right: 15.0),
                                          child: Checkbox(
                                            activeColor: Color.fromARGB(255, 99, 170, 101),
                                            value: agree,
                                            onChanged: (value) {
                                              setState(() {
                                                agree = value ?? false;
                                              });
                                            },
                                          ),
                                        ),
                                      // ),
                                      Text(AppLocalizations.of(context)
                                          .translate('AcceptTerms1'),style: TextStyle(
                                            fontSize: 12                            
                                                )),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamed(termsScreen.routeName);
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)
                                                .translate('AcceptTerms2'),
                                            style: TextStyle(
                                                color: Colors.lightBlue,
                                                fontSize: 12,
                                                decoration: TextDecoration.underline)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 40.0,
                                        height: 25.0,
                                        padding: EdgeInsets.only(right: 15.0),                              
                                        child:
                                        Checkbox(
                                          activeColor: Color.fromARGB(255, 99, 170, 101),
                                          value: agreeResearch,
                                          onChanged: (value) {
                                            setState(() {
                                              agreeResearch = value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      AutoSizeText(AppLocalizations.of(context)
                                          .translate('ResearchApprove1'),maxLines: 1,style: TextStyle(
                                            fontSize: 12                            
                                                )),
                                      InkWell(
                                        onTap: () {},
                                        child: AutoSizeText(
                                            AppLocalizations.of(context)
                                                .translate('ResearchApprove2'),maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.lightBlue,
                                                decoration: TextDecoration.underline, fontSize: 13 )),
                                      ),
                                      AutoSizeText(AppLocalizations.of(context)
                                          .translate('ResearchApprove3'),maxLines: 1,style: TextStyle(
                                            fontSize: 12                            
                                                )),
                                    ],
                                  ),
                                ],
                              ),
                          ),        
                        SizedBox(
                            height: 30.0,
                          ),
                          if (_isLoading)
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.1,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Lottie.asset('assets/animation/load.json'))

                          else
                            SizedBox(
                              height: 40, //height of button
                              width: deviceSize.width*0.9,
                              child: ElevatedButton(
                                key: Key("btnSignIn"),
                                child: Text(_authMode == AuthMode.Login
                                    ? AppLocalizations.of(context).translate('Login')
                                    : AppLocalizations.of(context).translate('SignUp'),style: TextStyle(fontSize:14),),
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(255, 99, 170, 101),
                                  onPrimary: Colors.white,
                                  shadowColor: Color.fromARGB(255, 127, 208, 130),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 8.0,
                                ),
                                onPressed: agree ? _submit : null,
                              ),
                            ),               
                            Container(         
                              child: TextButton(
                                key: Key("btnSwitchMode"),
                                child: Text(
                                    '${_authMode == AuthMode.Login ? AppLocalizations.of(context).translate('NoHaveAccount') : AppLocalizations.of(context).translate('HaveAccount')}',style: TextStyle(
                                        fontSize: 12              
                                            )),
                                onPressed: _switchAuthMode,

                              ),
                            ),                       
                            Container(
                                margin: EdgeInsets.all(2),   
                                child: SignInButton(
                                  Buttons.Google,
                                  onPressed: _signup,
                                  elevation: 2.0,
                                  padding: EdgeInsets.all(2.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1.0)),
                                ),
                              ),          
                        ],
                      ),
                    ),
                  ),
            ),
        ),
      );
  }
}
