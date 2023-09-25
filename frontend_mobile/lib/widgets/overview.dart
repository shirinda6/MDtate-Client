import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppLocalizations.dart';

class overView extends StatefulWidget {
  overView();
  @override
  _overViewState createState() => _overViewState();
}

class _overViewState extends State<overView> {
  YoutubePlayerController _controller;
  var url = "https://www.youtube.com/watch?v=wAo5RTvjr54&feature=youtu.be";

  @override
  void initState() {
    // TODO: implement initState
    _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url),
        flags: YoutubePlayerFlags(
          autoPlay: false,
          loop: false,
        ));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.only(top:8.0,right: 15.0,left:15.0,bottom: 2.0),
      child: Column(
        children: [
          SizedBox(height: 15.0),
          Text(AppLocalizations.of(context).translate('TitleVideo'),
              style: GoogleFonts.montserrat(
                  textStyle:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              textAlign: TextAlign.justify),
          //show the video
          SizedBox(height: 15.0),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: YoutubePlayer(
              controller: _controller,
              progressIndicatorColor: Colors.lightBlueAccent,
              showVideoProgressIndicator: true,
            ),
          ),
          SizedBox(height: 15.0),

          Text(AppLocalizations.of(context).translate('TitleOverView'),
              style: GoogleFonts.nunito(
                  textStyle:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              textAlign: TextAlign.justify),
          SizedBox(height: 8.0),
          Text(AppLocalizations.of(context).translate('ParagraphOverView'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
          SizedBox(height: 15.0),
          Text(AppLocalizations.of(context).translate('TitleApproach'),
              style: GoogleFonts.nunito(
                  textStyle:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))),
          SizedBox(height: 8.0),
          Text(AppLocalizations.of(context).translate('Approach1'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
          SizedBox(height: 10.0),
          Text(AppLocalizations.of(context).translate('Approach2'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
          SizedBox(height: 10.0),
          Text(AppLocalizations.of(context).translate('Approach3'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
          SizedBox(height: 10.0),
          Text(AppLocalizations.of(context).translate('Approach4'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
          SizedBox(height: 15.0),
          Text(AppLocalizations.of(context).translate('TreatmentCourse'),
              style: GoogleFonts.nunito(
                  textStyle:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))),
          SizedBox(height: 8.0),
          Text(AppLocalizations.of(context).translate('Treatment1'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
          SizedBox(height: 10.0),
          Text(AppLocalizations.of(context).translate('Treatment2'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
          SizedBox(height: 10.0),
          Text(AppLocalizations.of(context).translate('Treatment3'),
              style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0)),
              textAlign: TextAlign.justify),
        ],
      ),
    ));
  }
}
