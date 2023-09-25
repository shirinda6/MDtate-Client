import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';

import '../models/UserModel.dart';
import '../providers/auth.dart';
import '../Constants.dart';
import '../AppLocalizations.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class changePasswordScreen extends StatefulWidget {
  static const routeName = '/change-password';

  @override
  _changePasswordScreenState createState() => _changePasswordScreenState();

  changePasswordScreen();
}

class _changePasswordScreenState extends State<changePasswordScreen> {
  UserModel _user = UserModel();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false)
        .usermodel; //get the object of the user
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
  }

  //open dialog if there is error from the server in the register ot login
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).translate('ErrorOccurred'),
        ),
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

//the function check validation and save the changes
  Future<void> _save(BuildContext ctx) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    final url = Uri.parse(BASE_URL);
    try {
      //save the new password in the server
      final response = await http.post(
        url,
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is an error from the server
        _showErrorDialog(responseData['message']);
        return;
      }
      //save the changes in the user's object
      Provider.of<Auth>(context, listen: false).setUpdate = _user.toJson();
      Navigator.of(ctx).pop(); //return to the settings screen
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 244, 249, 251),
        appBar: AppBar(
            elevation: 0,
            title:
                Text(AppLocalizations.of(context).translate('ChangePassword'),
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Color.fromARGB(255, 9, 40, 52),
                      ),
                    )),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  UniconsLine.save,
                  color: Color.fromARGB(255, 9, 40, 52),
                  size: 26.0,
                ),
                onPressed: () => _save(context),
              )
            ]),
        body: Form(
            key: _formKey,
            child: ListView(children: [
              Neumorphic(
                margin:
                    EdgeInsets.only(left: 25, right: 25, top: 50, bottom: 4),
                style: NeumorphicStyle(
                    depth: NeumorphicTheme.embossDepth(context),
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(20))),
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 25.0),
                child: TextFormField(
                  //text input for the old password of the user

                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context)
                          .translate('OldPassword')),
                  obscureText: true,
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
                    _user.old_password = value;
                  },
                ),
              ),
              Neumorphic(
                margin:
                    EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 4),
                style: NeumorphicStyle(
                    depth: NeumorphicTheme.embossDepth(context),
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(20))),
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 25.0),
                child: TextFormField(
                  //text input for new password of the user
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context)
                          .translate('NewPassword')),
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
                    _user.new_password = value;
                  },
                ),
              ),
              Neumorphic(
                margin:
                    EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 4),
                style: NeumorphicStyle(
                    depth: NeumorphicTheme.embossDepth(context),
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(20))),
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 25.0),
                child: TextFormField(
                  //text input for confirm password
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: AppLocalizations.of(context)
                          .translate('ConfirmPassword')),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return AppLocalizations.of(context)
                          .translate('PasswordsNotMatch');
                    }
                  },
                  onSaved: (value) {
                    _user.password_confirm = value;
                  },
                ),
              ),
            ])));
  }
}
