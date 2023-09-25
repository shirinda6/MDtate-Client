import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppLocalizations.dart';

class news extends StatelessWidget {
  news();

  @override
  Widget build(BuildContext context) {
    return
    SingleChildScrollView(child: 
         SafeArea(
           child: Padding(
        padding: const EdgeInsets.only(top:2.0,right: 10.0,left:10.0,bottom: 2.0),
        child: Column(
            children: [       
            Text(AppLocalizations.of(context).translate('NewsTitle1'),style:GoogleFonts.nunito(textStyle:TextStyle(fontSize: 18.0,fontWeight:FontWeight.bold )) ),
            SizedBox(height:6.0),
            Text(AppLocalizations.of(context).translate('NewsSubTitle1'),style:GoogleFonts.nunito(textStyle:TextStyle(fontSize: 16.0, )),textAlign: TextAlign.center,),
            SizedBox(height:8.0),

            Container( padding: EdgeInsets.all(20.0),
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
              child: Text(AppLocalizations.of(context).translate('NewsParagraph1'),style:GoogleFonts.nunito(textStyle:TextStyle(fontSize: 14.0)), textAlign: TextAlign.justify,)),
             SizedBox(height:15.0),
            Text(AppLocalizations.of(context).translate('NewsTitle2'),style:GoogleFonts.nunito(textStyle:TextStyle(fontSize: 18.0,fontWeight:FontWeight.bold ),)),
             SizedBox(height:4.0),
            Text(AppLocalizations.of(context).translate('NewsSubTitle2'),style:GoogleFonts.nunito(textStyle:TextStyle(fontSize: 16.0),)),
             SizedBox(height:4.0),
            Container( padding: EdgeInsets.all(20.0),   decoration: BoxDecoration(
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
              child: Text(AppLocalizations.of(context).translate('NewsParagraph2'),style:GoogleFonts.nunito(textStyle:TextStyle(fontSize: 14.0),) ,textAlign: TextAlign.justify)),
        ],
    ),
     ),
         ),
    );

  }
}
