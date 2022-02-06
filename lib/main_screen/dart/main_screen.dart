import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String date0 =
      DateTime.now().toIso8601String().toString().replaceAll("-", "");
  bool _isRecording = false;
  final _audioRecorder = Record();
  Timer _timer;
  Timer _ampTimer;
  int _recordDuration = 0;
  String minutes;
  String seconds;
  File recordFile;
  TextEditingController textEditingController;

  Amplitude _amplitude;

  Widget _buildRecordStopControl() {
    Icon icon;
    Color color;
    if (_isRecording) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 36);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = const Icon(Icons.mic, color: Colors.green, size: 42);
      color = theme.primaryColor.withOpacity(0.1);
    }
    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 40, height: 40, child: icon),
          onTap: () {
            _isRecording ? _stop() : _start();
          },
        ),
      ),
    );
  }

  _askPer() async {
    PermissionStatus per = await Permission.microphone.request();
    if (per == PermissionStatus.granted) {
      _start();
    } else {
      _askPer();
    }
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });
        _startTimer();
      } else {
        _askPer();
      }
    } catch (e) {
      _askPer();
      print(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _audioRecorder.stop();
    if (path.isNotEmpty) {
      setState(() {
        recordFile = File(path);
      });
      print("path ...  $path");
      setState(() => _isRecording = false);
    } else {
      print("not recorded");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }

  String formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }
    return numberStr;
  }

  @override
  void initState() {
    _isRecording = false;
    textEditingController = TextEditingController(text: date0.substring(0,17));
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    minutes = formatNumber(_recordDuration ~/ 60);
    seconds = formatNumber(_recordDuration % 60);
    textEditingController = TextEditingController(
        text: _isRecording ? '$minutes : $seconds' : null);
    return Scaffold(
      floatingActionButton:
      FloatingActionButton(
          onPressed: () async {
            if (!kIsWeb) {
              if (Platform.isIOS || Platform.isAndroid) {
                bool status =
                await Permission.storage.isGranted;
                if (!status) {
                  await Permission.storage.request();
                }
              }
            }
            ByteData data = await recordFile
                .readAsBytes()
                .then((data) =>
                ByteData.view(data as ByteBuffer));
            String path = await FileSaver.instance.saveFile(
              textEditingController.text == ""
                  ? "File"
                  : textEditingController.text,
              recordFile.readAsBytesSync(),
              "AAC",
            );
            print(path);
          },
          elevation: 16,
          backgroundColor: Colors.pinkAccent,
          child: const Icon(Icons.save ,
          color: Colors.green,)),
        
        appBar: AppBar(
          title: const Text("Home"),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                          labelText: "Name",
                          hintText: "Something",
                          border: OutlineInputBorder()),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: MediaQuery.of(context).size.width,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        primary: false,
                        padding: const EdgeInsets.all(4),
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        crossAxisCount: 3,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8),
                            child:
                                const Text("He'd have you all unravel at the"),
                            color: Colors.teal[100],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text('Heed not the rabble'),
                            color: Colors.teal[200],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text('Sound of screams but the'),
                            color: Colors.teal[300],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text('Who scream'),
                            color: Colors.teal[400],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: _buildRecordStopControl(),
                            color: Colors.teal[500],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text('Revolution, they...'),
                            color: Colors.teal[600],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text('Who scream'),
                            color: Colors.teal[400],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text('Revolution is coming...'),
                            color: Colors.teal[500],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text('Revolution, they...'),
                            color: Colors.teal[600],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                )));
  }
}
