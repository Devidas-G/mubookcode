import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  var isDarkMode;
  VoidCallback retry;

  LoadingScreen({Key? key,required this.isDarkMode,required this.retry}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 20)),
        builder: (c, s) => s.connectionState == ConnectionState.done
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                  ElevatedButton(
                      onPressed: widget.retry,
                      child: const Text("Retry"),
                      style:
                          ElevatedButton.styleFrom(primary: Colors.tealAccent)),
                ],
              )
            : const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                ),
              ),
      ),
    );
  }
}
