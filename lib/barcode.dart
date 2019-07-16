import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class BarcodeWidget extends StatefulWidget {
  @override
  _BarcodeWidgetState createState() => _BarcodeWidgetState();
}

class _BarcodeWidgetState extends State<BarcodeWidget> {
  String _barcode = "";

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Barcode Scanner Example'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              tooltip: 'Back',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Container(
                  child: MaterialButton(
                      onPressed: scan,
                      child: Text("Scan")),
                  padding: const EdgeInsets.all(8.0),
                ),
                Text(_barcode),
              ],
            ),
          ),
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => _barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          _barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => _barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => _barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => _barcode = 'Unknown error: $e');
    }
  }

}
