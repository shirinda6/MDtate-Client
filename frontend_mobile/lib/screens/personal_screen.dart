import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/calender.dart';
import 'package:flutter_complete_guide/widgets/graph.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:age_calculator/age_calculator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../providers/auth.dart';
import '../models/UserModel.dart';
import '../Constants.dart';
import '../AppLocalizations.dart';

class PersonalScreen extends StatefulWidget {
  static const routeName = '/personal';
  String language;

  PersonalScreen(this.language);

  @override
  _PersonalScreenState createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  UserModel _user = UserModel();
  var _isLoading = false; //check if need to wait to a respond
  List attacks; //list of the attacks of the user
  List medications; //list of the medications of the user
  var firstReport =
      null; //the first report of the user, to check if there is none so the user add it.
  var reports =
      {}; //A dictionary of the reports,the key is the date and the value is a list of the reports for that day
  var sessionsByday =
      {}; //like the reports, only the seesions that the user listen for the dates

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

  void getReport() async {
    final url = Uri.parse(BASE_URL);
    try {
      final response = await http.get(
        //called the server
        url,
        headers: {},
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is an error from the server
        _showErrorDialog(responseData['message']);
        return;
      }

      //save the data from the server in the user's object and the lists
      _user = UserModel.fromJson(responseData["user"]);
      if (responseData["user"].keys.contains("initial_report")) {
        //check if there is first report
        firstReport = responseData["user"]["initial_report"];
      }
      attacks = responseData["user"]["reports"];
      attacks = attacks.map((e) => e as Map).toList();
      var sessions = responseData["sessions"].map((e) => e as Map).toList();
      for (var session in sessions) {
        //add for each session a dateTime field for the dictionary and the calender
        session["datetime"] = DateFormat("yyyy-MM-dd").parse(session["date"]);
        if (sessionsByday.keys.contains(session["datetime"])) {
          //add the session to the dictionary
          sessionsByday[session["datetime"]].add(session);
        } else {
          sessionsByday[session["datetime"]] = [session];
        }
      }
    } catch (error) {
      throw error;
    }
  }

//Shell function that call getReport and mergeMedicationsToAttacks functions
//the function sort the attacks by date
  void getInitReport() async {
    await getReport();
    for (var attack in attacks) {
      attack["datetime"] = DateFormat("yyyy-MM-dd").parse(attack["date"]);
      if (reports.keys.contains(attack["datetime"])) {
        reports[attack["datetime"]].add(attack);
      } else {
        reports[attack["datetime"]] = [attack];
      }
    }
    //save the reports and sessions in the userModel,
    //for not send a new request when open again this page
    Provider.of<Auth>(context, listen: false).setReport = reports;
    Provider.of<Auth>(context, listen: false).countReports = attacks.length;
    Provider.of<Auth>(context, listen: false).setFirstReport = firstReport;
    Provider.of<Auth>(context, listen: false).setSessionsPersonalArea =
        sessionsByday;
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false).usermodel;
    if (_user.reports == null) {
      //if there are not reports so send requst to the server
      getInitReport();
    } else {
      //get the dictionaries from the userModel
      reports = _user.reports;
      firstReport = _user.firstReport;
      sessionsByday = _user.sessionsPesonalArea;
      _isLoading = true;
    }

    super.initState();
  }

//get the age of the user from the birthday
  int getAge() {
    DateDuration duration;
    duration = AgeCalculator.age(_user.birthday);
    return duration.years;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        color: Color.fromARGB(255, 9, 40, 52),
      ),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            margin: EdgeInsets.only(left: 35.0, right: 30.0, top: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  //display the profile image
                  radius: MediaQuery.of(context).size.width / 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width / 7,
                    ),
                    child: _user.profile_image == null
                        ? Icon(
                            Icons.image,
                            size: 20,
                          )
                        : Image.network(
                            _user.profile_image,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width / 8,
                      left: 30.0,
                      right: 30.0),
                  child: Column(
                    children: [
                      Text(
                        "  ${_user.first_name} ${_user.last_name}",
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 24.0,
                          color: Color.fromARGB(255, 228, 217, 206),
                        )),
                      ),
                      SizedBox(height: 2.0),
                      //display the age, by the language of the app and gender
                      if (widget.language == 'en' && _user.birthday != null)
                        Text(
                          "    ${getAge()} ${AppLocalizations.of(context).translate('AgeBoy')}",
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 24.0,
                            color: Color.fromARGB(255, 228, 217, 206),
                          )),
                        ),
                      if (widget.language == 'he' &&
                          _user.gender == 1 &&
                          _user.birthday != null)
                        Text(
                          "${AppLocalizations.of(context).translate('AgeBoy')} ${getAge()}",
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 24.0,
                            color: Color.fromARGB(255, 228, 217, 206),
                            // color: Color.fromARGB(217, 33, 38, 38),
                          )),
                        ),
                      if (widget.language == 'he' &&
                          _user.gender == 2 &&
                          _user.birthday != null)
                        Text(
                          "${AppLocalizations.of(context).translate('AgeGirl')} ${getAge()}",
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            color: Color.fromARGB(255, 228, 217, 206),
                            fontSize: MediaQuery.of(context).size.width / 24.0,
                          )),
                        ),
                      if (widget.language == 'he' &&
                          _user.gender == 3 &&
                          _user.birthday != null)
                        Text(
                          "${AppLocalizations.of(context).translate('Agetrans')} ${getAge()}",
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 24.0,
                            color: Color.fromARGB(255, 228, 217, 206),
                          )),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
          if (_isLoading == false) //wait for response from the server
            Container(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Lottie.asset('assets/animation/Relax.json')),
            )
          else
            Expanded(
              child: DefaultTabController(
                  length: 2, // length of tabs
                  initialIndex: 0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          child: TabBar(
                            labelStyle: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                    fontSize: 22.0,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold)),
                            labelColor: Color.fromARGB(255, 228, 217, 206),
                            unselectedLabelColor:
                                Color.fromARGB(255, 228, 217, 206),
                            unselectedLabelStyle: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                    fontSize: 18.0,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold)),
                            tabs: [
                              Tab(
                                  text: AppLocalizations.of(context)
                                      .translate('Calender')),
                              Tab(
                                  text: AppLocalizations.of(context)
                                      .translate('Graph')),
                            ],
                          ),
                        ),
                        Container(
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * 0.65,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.7),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(243, 247, 253, 255),
                                border: Border(
                                    top: BorderSide(
                                        color: Color.fromARGB(255, 9, 40, 52),
                                        width: 1.0))),
                            child: TabBarView(children: <Widget>[
                              Calender(reports, firstReport, sessionsByday),
                              Graph(reports, sessionsByday),
                            ]))
                      ])),
            )
        ],
      ),
    );
  }
}
