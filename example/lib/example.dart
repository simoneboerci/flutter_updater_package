import 'package:flutter/material.dart';

import 'package:flutter_updater_package/flutter_updater_package.dart';

class Example extends StatefulWidget {

  final String currentVersion = "0.0.1";
  final String latestVersion = "0.0.2";

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {

  String _text = "";

  @override
  void initState() {
    super.initState();
    Updater.checkUpdates(widget.currentVersion, widget.latestVersion, "", sampleUpdate: true, setState: (){
      setState(() {
        _text = Updater.status.toString().replaceAll("UpdateStatus.", '');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Text(
          _text,
          style: TextStyle(
            fontSize: 30,
            color: Colors.greenAccent,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}