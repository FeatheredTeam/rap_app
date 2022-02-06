import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rap_app/main_screen/dart/main_screen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}



class MyApp extends StatelessWidget {
  MyApp({Key key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Color.fromRGBO(149, 123, 80,1),
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromRGBO(19, 13, 15,1),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Learn Arabic with Songs',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home:
        const MainScreen()
    );
  }
}


