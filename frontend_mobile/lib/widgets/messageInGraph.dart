import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../AppLocalizations.dart';
import '../providers/auth.dart';

class MessageGraphDialog extends StatefulWidget {
  @override
  _MessageGraphDialogState createState() => _MessageGraphDialogState();
}

//dialog that open to explain to the user that he can click on the months in graph
class _MessageGraphDialogState extends State<MessageGraphDialog> {
  bool isDisplay = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Container(
        height: 150,
        width:  MediaQuery.of(context).size.width / 1.1,
        child: 
       
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
                mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              AutoSizeText(AppLocalizations.of(context).translate('ClickMonthGraph'),
                  maxLines: 3,
                  style:
                      GoogleFonts.nunito(textStyle: TextStyle(fontSize: 15.0))),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment:MainAxisAlignment.start,
                children: [
                  
                  //checkbox that the user can decide that not to open this dialog again
                  Checkbox(
                    value: isDisplay,
                    onChanged: (value) {
                      Provider.of<Auth>(context, listen: false)
                          .setDisplayMessage(value);
                      setState(() {
                        isDisplay = value ?? false;
                      });
                    },
                  ),

                  Expanded(
                    child: AutoSizeText(AppLocalizations.of(context)
                    
                        .translate('displayMessageInGraphPage'),maxLines: 2, style:
                        GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14.0))),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text(AppLocalizations.of(context).translate('OK'),
              style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              )),
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>(
                Color.fromARGB(255, 71, 124, 186)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
