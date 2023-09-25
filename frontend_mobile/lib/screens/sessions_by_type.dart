import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../providers/auth.dart';
import '../models/Session.dart';
import 'session_audio.dart';
import '../AppLocalizations.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionByTypeScreen extends StatefulWidget {
  static const routeName = '/session-by-type';
  SessionByTypeScreen();

  @override
  _SessionByTypeScreenState createState() => _SessionByTypeScreenState();
}

class _SessionByTypeScreenState extends State<SessionByTypeScreen> {
  List<Session> _sessions;
  String _type;

  String getTitle(String type) {
    var title;
    switch (type) {
      case "morning":
        title = AppLocalizations.of(context).translate('MorningSession');
        break;
      case "night":
        title = AppLocalizations.of(context).translate('NightSession');
        break;
      case "short":
        title = AppLocalizations.of(context).translate('ShortSession');
        break;
      case "long":
        title = AppLocalizations.of(context).translate('LongSession');
    }
    return title;
  }

//the icon of the feedback that the user choose of the audio
  Icon getIconForHelp(int help) {
    switch (help) {
      case 1:
        return Icon(UniconsLine.dizzy_meh,
            color: Color.fromARGB(255, 158, 11, 0),size: 26);
        break;
      case 2:
        return Icon(UniconsLine.sad, color: Colors.redAccent,size: 26,);
        break;
      case 3:
        return Icon(UniconsLine.meh_alt, color: Colors.amber,size: 26);
        break;
      case 4:
        return Icon(UniconsLine.smile, color: Colors.lightGreen,size: 26);
        break;
      case 5:
        return Icon(UniconsLine.smile_beam, color: Colors.green,size: 26);
        break;
    }
  }

//open the page of the audio of the session
  void openAudio(int index) {
    Navigator.of(context)
        .pushNamed(sessionAudioScreen.routeName, arguments: _sessions[index])
        .then((value) => setState(() {
              //in the end of the audio, the user back to this page
              //and we need to update the list of the new icons near the name of this audio
              _sessions = Provider.of<Auth>(context, listen: false)
                  .getSessions
                  .getByType(_type);
            }));
  }

  @override
  Widget build(BuildContext context) {
    _type = ModalRoute.of(context).settings.arguments as String;
    _sessions =
        Provider.of<Auth>(context, listen: false).getSessions.getByType(_type);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 249, 251),
      appBar: AppBar(
        elevation: 0,
        title: Text(getTitle(_type),
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                letterSpacing: 1,

                color: Color.fromARGB(255, 9, 40, 52),
              ),
            )),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              elevation: 7.0,
              margin: EdgeInsets.only(
                top: 12.0,
                right: 10.0,
                left: 10.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.all(4.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: AutoSizeText(_sessions[index].name,
                    maxLines: 2,
                   
                        style: GoogleFonts.poppins(
                          letterSpacing: 0.5,
                          
                          textStyle: TextStyle(
                            
                            fontSize: 14.0,
                            height: 1.5,
                          ),
                        )
                        ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //if the user fill feedback of the session
                        _sessions[index].feedback > 0
                            ? getIconForHelp(_sessions[index].feedback)
                            : Container(),
                        SizedBox(
                          height: 5,
                          width: 5,
                        ),
                        //if the user hear the session
                        _sessions[index].completed == true
                            ? Icon(Icons.hearing,size: 24,color:Color.fromARGB(217, 33, 38, 38),)
                            : Container(),
                      ],
                    ),
                  ),
                ),
                onTap: () => openAudio(index),
              ),
            );
          },
          itemCount: _sessions.length,
        ),
      ),
    );
  }
}
