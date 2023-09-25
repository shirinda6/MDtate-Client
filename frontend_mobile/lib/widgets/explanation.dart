import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppLocalizations.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:lottie/lottie.dart';
import 'package:auto_size_text/auto_size_text.dart';

class explanation extends StatelessWidget {
  explanation();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 2.0, right: 8.0, left: 8.0, bottom: 2.0),
        child: Column(
          children: [
            AutoSizeText(
                AppLocalizations.of(context).translate('ExplanationTitle'),
                maxLines: 1,
                style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold))),
            SizedBox(height: 15.0),
            Container(
              height: 60.0,
              child: Lottie.asset(
                'assets/animation/mindfulness.json',
                repeat: false,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2.0),
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20)),
              child: ExpansionCard(
                borderRadius: 10,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText(
                        AppLocalizations.of(context)
                            .translate('MindfulnessTitle'),
                        maxLines: 3,
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 16.0),
                            color: Colors.black)),
                  ],
                ),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                        AppLocalizations.of(context).translate('Mindfulness'),
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 14.0)),
                        textAlign: TextAlign.justify),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20)),
              child: ExpansionCard(
                borderRadius: 10,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText(
                        AppLocalizations.of(context)
                            .translate('RelaxationTitle'),
                        maxLines: 3,
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 16.0),
                            color: Colors.black)),
                  ],
                ),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                        AppLocalizations.of(context).translate('Relaxation'),
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 13.0)),
                        textAlign: TextAlign.justify),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20)),
              child: ExpansionCard(
                borderRadius: 20,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText(
                        AppLocalizations.of(context)
                            .translate('MindfulnessVSRelaxationTitle'),
                        maxLines: 3,
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 16.0),
                            color: Colors.black)),
                  ],
                ),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                        AppLocalizations.of(context)
                            .translate('MindfulnessVSRelaxation'),
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 13.0)),
                        textAlign: TextAlign.justify),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20)),
              child: ExpansionCard(
                borderRadius: 10,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText(
                        AppLocalizations.of(context)
                            .translate('RelaxationSleepTitle'),
                        maxLines: 1,
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 16.0),
                            color: Colors.black)),
                  ],
                ),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                        AppLocalizations.of(context)
                            .translate('RelaxationSleep'),
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(fontSize: 13.0)),
                        textAlign: TextAlign.justify),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20)),
              child: ExpansionCard(
                borderRadius: 10,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText(
                      AppLocalizations.of(context)
                          .translate('RulesForMindfulness'),
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(fontSize: 16.0),
                          color: Colors.black),
                      maxLines: 3,
                    ),
                  ],
                ),
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                        children: [
                          AutoSizeText(
                              AppLocalizations.of(context)
                                  .translate('RelaxationSleep'),
                              maxLines: 2,
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(fontSize: 13.0)),
                              textAlign: TextAlign.justify),
                          Text(
                              AppLocalizations.of(context)
                                  .translate('FirstRule'),
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(fontSize: 13.0)),
                              textAlign: TextAlign.justify),
                          SizedBox(height: 10.0),
                          Text(
                              AppLocalizations.of(context)
                                  .translate('SecondRule'),
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(fontSize: 13.0)),
                              textAlign: TextAlign.justify),
                          SizedBox(height: 10.0),
                          Text(
                              AppLocalizations.of(context)
                                  .translate('ThirdRule'),
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(fontSize: 13.0)),
                              textAlign: TextAlign.justify),
                        ],
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
