import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import '../models/Session.dart';
import 'package:google_fonts/google_fonts.dart';

import '../AppLocalizations.dart';
import '../widgets/finish_session.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class sessionAudioScreen extends StatefulWidget {
  static const routeName = '/session-audio';
  sessionAudioScreen();

  @override
  _sessionAudioScreenState createState() => _sessionAudioScreenState();
}

class _sessionAudioScreenState extends State<sessionAudioScreen> {
  Session _session;
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  List<double> lstSpeed = <double>[
    0.8,
    1.0,
    1.2
  ]; //The list of speeds that the user can hear the audio
  double speed = 1.0;
  ValueNotifier<double> progressNotifier;

  @override
  void initState() {
    super.initState();
    progressNotifier = ValueNotifier<double>(0.0);
    //first dialog oprn with recommendation before hearing the audio
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await recommendation();
    });
  }

  void recommendation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        title: Text(AppLocalizations.of(context).translate('Recommendation'),
            style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))),
        content: Text(_session.guided_text,
            style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 16.0))),
        actions: <Widget>[
          ElevatedButton(
            child: Text(AppLocalizations.of(context).translate('OK'),
                style: GoogleFonts.nunito(
                  textStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                )),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(
                  Color.fromARGB(255, 71, 124, 186)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void setupPlaylist() async {
    //setup the audio from the link
    await audioPlayer.open(Audio.network(_session.audio),
        autoStart: false,
        playInBackground: PlayInBackground.disabledRestoreOnForeground);

//when the audio end, open dialog of class finishSession,
//and the user can give feedback for this audio
    audioPlayer.playlistFinished.listen((finished) {
      if (finished) {
        Future<void> future = showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            context: context,
            builder: ((context) => finishSession(_session)));
        future.then((void value) {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

//the widget that play the audio, with ProgressBar
  Widget circularAudioPlayer(
      RealtimePlayingInfos realtimePlayingInfos, double screenWidth) {
    progressNotifier.value = 100 *
        (realtimePlayingInfos.currentPosition.inSeconds /
            realtimePlayingInfos.duration.inSeconds);
    if (realtimePlayingInfos.duration.inSeconds > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SimpleCircularProgressBar(
                valueNotifier: progressNotifier,
                progressColors: const [
                  Color.fromARGB(255, 113, 181, 207),
                  Color.fromARGB(255, 190, 113, 207)
                ],
                backColor: Colors.black.withOpacity(0.1),
                progressStrokeWidth: 24,
                backStrokeWidth: 24,
                mergeMode: true,
                size: screenWidth / 1.5,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Text(
                    //How long has it been since the audio
                    "${realtimePlayingInfos.currentPosition.toString().substring(0, realtimePlayingInfos.currentPosition.toString().indexOf("."))}/${realtimePlayingInfos.duration.toString().substring(0, realtimePlayingInfos.duration.toString().indexOf("."))}",
                    style: TextStyle(
                        fontSize: 16.0, color: Color.fromARGB(255, 29, 73, 91)),
                  ),
                  SizedBox(height: 15),
                  Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          //repeat 10 seconds back
                          color: Color.fromARGB(255, 29, 73, 91),
                          iconSize: screenWidth / 8,
                          onPressed: () {
                            audioPlayer.seekBy(Duration(seconds: -10));
                          },
                          icon: Icon(Icons.replay_10)),
                      IconButton(
                        //stop the audio
                        color: Color.fromARGB(255, 29, 73, 91),
                        iconSize: screenWidth / 5,
                        icon: Icon(realtimePlayingInfos.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        onPressed: () => {audioPlayer.playOrPause()},
                      ),
                      IconButton(
                          //move forward 10 seconds
                          color: Color.fromARGB(255, 29, 73, 91),
                          iconSize: screenWidth / 8,
                          onPressed: () {
                            audioPlayer.seekBy(Duration(seconds: 10));
                          },
                          icon: Icon(Icons.forward_10)),
                    ],
                  ),
                  SizedBox(height: 8),
                  DropdownButton<double>(
                    //change the speed of the audio from the list lstSpeed
                    value: speed,
                    onChanged: (double value) {
                      audioPlayer.setPlaySpeed(value);
                      speed = value;
                    },
                    items:
                        lstSpeed.map<DropdownMenuItem<double>>((double value) {
                      return DropdownMenuItem<double>(
                        value: value,
                        child: Text(
                          "${value}x",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 29, 73, 91)),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ],
          ),
        ],
      );
    }
    ;
    return SizedBox(height: 15);
  }

  @override
  Widget build(BuildContext context) {
    _session = ModalRoute.of(context).settings.arguments as Session;
    setupPlaylist();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:Color.fromARGB(255, 29, 73, 91),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/b6.png"), fit: BoxFit.cover),
        ),
        child: Container(
          child: audioPlayer.builderRealtimePlayingInfos(
              builder: (context, realtimePlayingInfos) {
            if (realtimePlayingInfos != null) {
              return circularAudioPlayer(
                  realtimePlayingInfos, MediaQuery.of(context).size.width);
            } else {
              return Container();
            }
          }),
        ),
      ),
    );
  }
}
