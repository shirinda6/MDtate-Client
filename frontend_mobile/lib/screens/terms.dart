import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppLocalizations.dart';

class termsScreen extends StatefulWidget {
  static const routeName = '/terms';

  @override
  _termsScreenState createState() => _termsScreenState();

  termsScreen();
}

class _termsScreenState extends State<termsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 249, 251),
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context).translate('Term'),
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color.fromARGB(255, 9, 40, 52),
              ),
            )),
      ),
      body: WebView(
        //open the policy through url
        initialUrl: 'https://mdtate.onrender.com/web/terms',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
