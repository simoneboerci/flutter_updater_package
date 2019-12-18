import 'package:flutter/material.dart';
import 'package:flutter_updater_package/updater.dart';

class MainPage extends StatefulWidget {
  final String currentVersion = "0.0.1";
  final String latestVersion = "0.0.2";

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _text = Updater.status.toString();

  @override
  void initState() {
    super.initState();
    Updater.checkUpdates(widget.currentVersion, widget.latestVersion, "",
        sampleUpdate: true, setState: () {
      setState(() {
        _text = Updater.status.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          _text.split("UpdateStatus.")[1],
          style: TextStyle(
              fontSize: 30,
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
      ),
    ));
  }
}
