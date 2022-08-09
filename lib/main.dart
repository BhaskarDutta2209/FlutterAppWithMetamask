import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/pages/confirmpayment_page.dart';
import 'package:my_app/pages/second_page.dart';
import 'package:my_app/utils/routes.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:web3dart/web3dart.dart';

Future<void> main(List<String> args) async {
  await dotenv.load();
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
        // MyRoutes.secondPage: (context) => const SecondPage(),
        // MyRoutes.testingPage: (context) => Scaffold(
        //       appBar: AppBar(
        //         title: const Text("Testing page"),
        //       ),
        //       body: ConfirmPaymentPage(
        //           receiverName: "Bhaskar Dutta",
        //           receiverUPI: "bhaskar220999@oksbi",
        //           accountAddress: "0x3310A13F37Ac2FC7A932C4f1a5fE15F342f4E048",
        //           web3Client: web3client),
        //     )
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
