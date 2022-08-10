import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<bool> isTransactionConfirmed(String tx) async {
  String url =
      "https://api-testnet.polygonscan.com/api?module=transaction&action=gettxreceiptstatus&txhash=${tx}&apikey=${dotenv.env['POLYGONSCAN_API_KEY'].toString()}";

  final res = await http.get(Uri.parse(url));
  final jsonBody = jsonDecode(res.body);
  final status = jsonBody['result']['status'].toString();
  print("status => " + status);

  print("Received transactionStatus");
  print(tx);
  print(jsonBody);
  return status == "1";
}
