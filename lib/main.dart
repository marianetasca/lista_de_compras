import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_trabalho/views/login_register.dart';
import 'package:flutter_trabalho/views/login_page.dart';
import 'package:flutter_trabalho/views/home_page.dart';
import 'package:flutter_trabalho/firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor:  Color.fromARGB(255, 116, 167, 209),
              primary: Color.fromARGB(255, 17, 66, 107),
              secondary: Colors.blue,
              surface: Colors.grey.shade200),
              scaffoldBackgroundColor: Colors.grey[200],
          useMaterial3: false
        ),
        home: MainPage(),
        routes: {
          "/loginRegister": (context) => LoginRegister(),
        });
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(stream: FirebaseAuth.instance.userChanges(), 
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return HomePage( user: snapshot.data!);
      }
      else {
        return LoginPage();
      }
    });
  }
}
