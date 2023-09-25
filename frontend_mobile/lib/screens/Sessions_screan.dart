import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppLocalizations.dart';
import 'sessions_by_type.dart';
import '../providers/auth.dart';
import '../models/UserModel.dart';
import '../models/Sessions.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../models/Session.dart';

class SessionScreen extends StatefulWidget {
  SessionScreen();

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  UserModel _user = null;
  Sessions _sessions = Sessions();

//add to the user the sessions from the server.
//there are 4 types of sessions (morning, night, long and short)
  void getSessions(Map<String, dynamic> sessions) {
    if (sessions != null) {
      var mornings = sessions["MORNING"];
      for (var morning in mornings) {
        var m = Session.fromJson(morning);
        _sessions.addMorning(m);
      }
      var nights = sessions["NIGHT"];
      for (var night in nights) {
        var n = Session.fromJson(night);
        _sessions.addNight(n);
      }
      var longs = sessions["LONG"];
      for (var long in longs) {
        var l = Session.fromJson(long);
        _sessions.addLong(l);
      }
      var shorts = sessions["SHORT"];
      for (var short in shorts) {
        var s = Session.fromJson(short);
        _sessions.addShort(s);
      }
      Provider.of<Auth>(context, listen: false).setSessions = _sessions;
    }
  }

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false).usermodel;
    super.initState();
  }

  void openSessions(String type) {
    Navigator.of(context)
        .pushNamed(SessionByTypeScreen.routeName, arguments: type);
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12)
      return AppLocalizations.of(context).translate('GoodMorning');
    else if (hour >= 12 && hour < 18)
      return AppLocalizations.of(context).translate('GoodAfternoon');
    else if (hour >= 18 && hour < 0)
      return AppLocalizations.of(context).translate('GoodEvening');
    else
      return AppLocalizations.of(context).translate('GoodNight');
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> sessions = Provider.of<Auth>(context).getSessionServer;
    //if the user open this page for the first time this iteration,
    //add the sessions to the user from the map we got from the server
    if (_user.sessions.getMorning().isEmpty)
      getSessions(sessions);
    else
      _sessions = _user.sessions;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(left: 45.0, right: 45.0, top: 45.0),
            child: Row(
              children: [
                Text(
                  getGreeting(),
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                          fontSize:  MediaQuery.of(context).size.width / 15.0,
                          color: Color.fromARGB(217, 33, 38, 38),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 45.0, right: 45.0, top: 10.0),
            child: Row(
              children: [
                AutoSizeText(
                  " ${_user.first_name}",
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 15.0,
                          color: Color.fromARGB(217, 33, 38, 38),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.only(top: 25.0),
                      width: MediaQuery.of(context).size.width / 2.4,
                      height: MediaQuery.of(context).size.height / 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: GradientBoxBorder(
                          gradient: LinearGradient(colors: [
                            Color.fromARGB(184, 75, 136, 160),
                            Color.fromARGB(247, 210, 210, 249),
                          ]),
                          width: 4,
                        ),
                        image: DecorationImage(
                            image: AssetImage('assets/images/mornning.png'),
                            fit: BoxFit.fill),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 113, 181, 207),
                            blurRadius: 1,
                            offset: Offset(2, 2), // Shadow position
                          ),
                        ],
                      ),
                      child: Center(
                        child: AutoSizeText(
                            AppLocalizations.of(context)
                                .translate('MorningSession'),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width / 20.0,
                                fontFamily: "RobotoMono",
                                color: Color.fromARGB(217, 33, 38, 38)),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    onTap: () => openSessions("morning"),
                  ),
                ],
              ),
              SizedBox(
                width: 20.0,
              ),
              Column(
                children: [
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.only(top: 25.0),
                      width: MediaQuery.of(context).size.width / 2.4,
                      height: MediaQuery.of(context).size.height / 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: GradientBoxBorder(
                          gradient: LinearGradient(colors: [
                            Color.fromARGB(184, 75, 136, 160),
                            Color.fromARGB(247, 210, 210, 249),
                          ]),
                          width: 4,
                        ),
                        image: DecorationImage(
                            image: AssetImage('assets/images/night.png'),
                            fit: BoxFit.fill),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 113, 181, 207),
                            blurRadius: 1,
                            offset: Offset(2, 2), // Shadow position
                          ),
                        ],
                      ),
                      child: Center(
                        child: AutoSizeText(
                            AppLocalizations.of(context)
                                .translate('NightSession'),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width / 20.0,
                                fontFamily: "RobotoMono",
                                color: Color.fromARGB(217, 33, 38, 38)),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    onTap: () => openSessions("night"),
                  ),
                ],
              )
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                height: MediaQuery.of(context).size.height / 8,
                margin: EdgeInsets.only(top: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: GradientBoxBorder(
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(184, 75, 136, 160),
                      Color.fromARGB(247, 210, 210, 249),
                    ]),
                    width: 4,
                  ),
                  image: DecorationImage(
                      image: AssetImage('assets/images/short.png'),
                      fit: BoxFit.fill),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 113, 181, 207),
                      blurRadius: 1,
                      offset: Offset(2, 2), // Shadow position
                    ),
                  ],
                ),
                child: Center(
                  child: AutoSizeText(
                      AppLocalizations.of(context).translate('ShortSession'),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 20.0,
                        fontFamily: "RobotoMono",
                        color: Color.fromARGB(217, 33, 38, 38),
                      ),
                      textAlign: TextAlign.start),
                ),
              ),
              onTap: () => openSessions("short"),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 8,
                  margin: EdgeInsets.only(top: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: GradientBoxBorder(
                      gradient: LinearGradient(colors: [
                        Color.fromARGB(184, 75, 136, 160),
                        Color.fromARGB(247, 210, 210, 249),
                      ]),
                      width: 4,
                    ),
                    image: DecorationImage(
                        image: AssetImage('assets/images/long.png'),
                        fit: BoxFit.fill),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 113, 181, 207),
                        blurRadius: 1,
                        offset: Offset(2, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: Center(
                      child: AutoSizeText(
                          AppLocalizations.of(context).translate('LongSession'),
                          style: TextStyle(
                               fontSize: MediaQuery.of(context).size.width / 20.0,
                              fontFamily: "RobotoMono",
                              color: Color.fromARGB(217, 33, 38, 38)),
                          textAlign: TextAlign.start)),
                ),
                onTap: () => openSessions("long"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
