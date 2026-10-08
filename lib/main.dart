import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import 'const.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StreamVideo(
    AppConst.streamAPIKey, // Replace with your Stream API key
    userToken: AppConst.userToken, // Replace with your user token
    user: User(
      info: UserInfo(
        id: AppConst.userId,
        name: 'Talaat Mohamed',
        role: 'admin',
      ),
    ), // Replace with your user info  // ID Rq.
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
