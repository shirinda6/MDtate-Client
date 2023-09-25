import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppLocalizations.dart';

class privacyPolicyScreen extends StatefulWidget {
  static const routeName = '/privacy-policy';

  @override
  _privacyPolicyScreenState createState() => _privacyPolicyScreenState();

  privacyPolicyScreen();
}

class _privacyPolicyScreenState extends State<privacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(AppLocalizations.of(context).translate('Policy'),
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
          initialUrl: 'https://mdtate.onrender.com/web/privacy_policy',
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
