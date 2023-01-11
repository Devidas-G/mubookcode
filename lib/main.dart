import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'Pages/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
      debug:
          false // optional: set to false to disable printing logs to console (default: true)
      );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}


