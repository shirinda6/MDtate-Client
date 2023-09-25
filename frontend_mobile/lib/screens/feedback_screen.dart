import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';

import '../providers/auth.dart';
import '../AppLocalizations.dart';
import '../Constants.dart';
import '../models/UserModel.dart';

class feedbackScreen extends StatefulWidget {
  static const routeName = '/feedback-screen';

  @override
  _feedbackScreenState createState() => _feedbackScreenState();

  feedbackScreen();
}

class _feedbackScreenState extends State<feedbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var report = "";
  UserModel _user;

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false)
        .usermodel; //get the object of the user
    super.initState();
  }

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

  Future<void> _save(BuildContext ctx) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    final url = Uri.parse(BASE_URL);
    try {
      final response = await http.post(
        url,
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is an error from the server
        _showErrorDialog(responseData['message']);
        return;
      }
      Navigator.of(ctx).pop();
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: Text(AppLocalizations.of(context).translate('Feedback'),
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
          child: Container(
            width: MediaQuery.of(context).size.width / 1,
            height: MediaQuery.of(context).size.height / 2,
            child: Neumorphic(
              margin: EdgeInsets.only(left: 2, right: 12, top: 40, bottom: 4),
              style: NeumorphicStyle(
                  depth: NeumorphicTheme.embossDepth(context),
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(20))),
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return AppLocalizations.of(context)
                        .translate('EmptyFeedback');
                },
                onSaved: (value) {
                  report = value;
                },
              ),
            ),
          ),
        ));
  }
}
