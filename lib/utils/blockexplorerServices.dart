import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/datastructures/enums.dart';
import 'package:my_app/utils/constants.dart';

Future<TransactionState> isTransactionConfirmed(String tx) async {
  String url =
      "https://api-testnet.polygonscan.com/api?module=transaction&action=gettxreceiptstatus&txhash=${tx}&apikey=${dotenv.env['POLYGONSCAN_API_KEY'].toString()}";

  final res = await http.get(Uri.parse(url));
  final jsonBody = jsonDecode(res.body);
  final status = jsonBody['result']['status'].toString();
  print("status => " + status.toString());
  if (status.toString() == "1") {
    return TransactionState.success;
  } else if (status.toString() == "0") {
    return TransactionState.failed;
  } else {
    return TransactionState.undefined;
  }
}

Future<TransactionState> waitForTransactionConfirmation(String tx) async {
  var counter = 10; // Number of blocks to check

  TransactionState transactionState = TransactionState.undefined;
  while (counter > 0) {
    transactionState = await isTransactionConfirmed(tx);
    if (transactionState == TransactionState.success ||
        transactionState == TransactionState.failed) {
      return transactionState;
    }
    await Future.delayed(Duration(seconds: 2 * Constants.blockTimeInSeconds));
    counter -= 1;
  }

  if (counter == 0) {
    return TransactionState.timeout;
  } else {
    return TransactionState.undefined;
  }
}
