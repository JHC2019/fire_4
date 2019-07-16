import 'package:flutter/material.dart';

import 'vision-text.dart';
import 'barcode.dart';
import 'firestore.dart';

void main() {
  runApp(MaterialApp(
    title: 'App for Barcode & OCR',
    // Start the app with the "/" named route. In our case, the app will start
    // on the FirstScreen Widget
    initialRoute: '/',
    routes: {
      '/': (context) => StartScreen(),
      '/vision-text': (BuildContext context) => VisionTextWidget(),
      '/barcode': (BuildContext context) => BarcodeWidget(),
      '/firestore': (BuildContext context) => FirestoreWidget(),
    },
  ));
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('MLKit Demo'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: RaisedButton(
                child: Text('OCR'),
                onPressed: () {
                  // Navigate to the second screen using a named route
                  Navigator.pushNamed(context, '/vision-text');
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text('Barcode & QR Code'),
                onPressed: () {
                  // Navigate to the second screen using a named route
                  Navigator.pushNamed(context, '/barcode');
                },
              ),
            ),
            Center(
              child: RaisedButton(
                child: Text('Firestore Test'),
                onPressed: () {
                  // Navigate to the second screen using a named route
                  Navigator.pushNamed(context, '/firestore');
                },
              ),
            ),
          ],
        ));
  }
}