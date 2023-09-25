import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unicons/unicons.dart';
import '../providers/auth.dart';
import '../models/Session.dart';
import '../AppLocalizations.dart';
import '../Constants.dart';
import '../models/UserModel.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:google_fonts/google_fonts.dart';

class finishSession extends StatefulWidget {
  static const routeName = '/finish-session';

  Session _session;
  finishSession(this._session);

  @override
  _finishSessionState createState() => _finishSessionState();
}

class _finishSessionState extends State<finishSession> {
  UserModel _user;

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

  String getSessionType(int stage) {
    var type = "";
    switch (stage) {
      case 1:
        type = "MORNING";
        break;
      case 2:
        type = "NIGHT";
        break;
      case 3:
        type = "LONG";
        break;
      case 4:
        type = "SHORT";
        break;
    }
    return type;
  }

//send request to the server that the user listen to session, with his feedback
//the feedback is from 1-5 that represented by icons of faces.
//if the user skip, the feedback will be 0.
  Future<void> sessionDone(int smily) async {
    final url = Uri.parse(BASE_URL);
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: json.encode({}));
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is an error from the server
        _showErrorDialog(responseData['message']);
        return;
      }
      //update the session in userModel with the feedback and that the user listen to it
      Provider.of<Auth>(context, listen: false)
          .doneSession(widget._session.name, widget._session.stage, smily);
      Navigator.pop(context);
    } catch (error) {
      throw error;
    }
  }

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false)
        .usermodel; //get the object of the user

    super.initState();
  }

  Future<void> sessionHelp(int help) async {}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 30.0, right: 10.0, top: 15.0, bottom: 15.0),
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height / 2.5,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: AutoSizeText(widget._session.completed_message,
                maxLines: 2,
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(fontSize: 14.0),
                )),
          ),
          Divider(),
          SizedBox(height: 10),
          AutoSizeText(
            AppLocalizations.of(context).translate('HowSession'),
            maxLines: 1,
            style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Ink(
                    child: IconButton(
                      icon: Icon(UniconsLine.dizzy_meh),
                      iconSize: 48,
                      onPressed: () {
                        sessionDone(1);
                      },
                      color: Color.fromARGB(255, 158, 11, 0),
                      tooltip: AppLocalizations.of(context)
                          .translate('VeryDissatisfied'),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Ink(
                    child: IconButton(
                      icon: Icon(UniconsLine.sad),
                      iconSize: 48,
                      onPressed: () {
                        sessionDone(2);
                      },
                      color: Colors.redAccent,
                      tooltip: AppLocalizations.of(context)
                          .translate('Dissatisfied'),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Ink(
                    child: IconButton(
                      icon: Icon(UniconsLine.meh_alt),
                      iconSize: 48,
                      onPressed: () {
                        sessionDone(3);
                      },
                      color: Colors.amber,
                      tooltip:
                          AppLocalizations.of(context).translate('Neutral'),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Ink(
                    child: IconButton(
                      icon: Icon(UniconsLine.smile),
                      iconSize: 48,
                      onPressed: () {
                        sessionDone(4);
                      },
                      color: Colors.lightGreen,
                      tooltip:
                          AppLocalizations.of(context).translate('Satisfied'),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Ink(
                    child: IconButton(
                      icon: Icon(UniconsLine.smile_beam),
                      iconSize: 48,
                      onPressed: () {
                        sessionDone(5);
                      },
                      color: Colors.green,
                      tooltip: AppLocalizations.of(context)
                          .translate('VerySatisfied'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            height: 1,
          ),
          SizedBox(height: 25),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    Color.fromARGB(255, 71, 124, 186)),
              ),
              onPressed: (() {
                sessionDone(0);
              }),
              child: Text(AppLocalizations.of(context).translate('Skip'),
                  style: GoogleFonts.nunito(
                    textStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ))),
        ],
      ),
    );
  }
}
