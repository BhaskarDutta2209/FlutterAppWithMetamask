import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/pages/transactionCompletion_page.dart';
import 'package:my_app/widgets/home_widget.dart';
import 'package:my_app/widgets/paymentDetails_widget.dart';
import 'package:my_app/pages/second_page.dart';
import 'package:my_app/utils/routes.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:web3dart/web3dart.dart';

Future<void> main(List<String> args) async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = Client();
    final web3client =
        Web3Client(dotenv.env['RPC_ENDPOINT'].toString(), client);
    return MaterialApp(
      initialRoute: MyRoutes.loginRoute,
      // initialRoute: MyRoutes.testingPage,
      routes: {
        MyRoutes.loginRoute: (context) => const LoginPage(),
        // MyRoutes.testingPage: (context) => const TransactionCompletionPage(txHash: "0x0a8e1c864eaffaed6563ab57d2614788fb1126cf1e933bf7d8f25d539841f906")
        // MyRoutes.secondPage: (context) => const SecondPage(),
        // MyRoutes.testingPage: (context) => Scaffold(
        //     appBar: AppBar(
        //       title: const Text("Testing page"),
        //     ),
        //     body: HomeWidget())
      },
      theme: ThemeData(
          textTheme: TextTheme(
              headline2: GoogleFonts.merriweather(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
              headline3: GoogleFonts.inconsolata(
                  fontSize: 16, color: Colors.black87))),
    );
  }
}
