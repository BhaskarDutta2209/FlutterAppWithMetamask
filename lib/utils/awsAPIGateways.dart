import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/utils/constants.dart';

Future<void> registerAddress(String deviceToken, String accountAddress) async {
  final body = jsonEncode({
    "deviceToken": deviceToken.toString(),
    "accountAddress": accountAddress.toLowerCase()
  });
  final headers = {
    'x-api-key': dotenv.env['LAMBDA_REGISTER_ADDRESS'].toString()
  };

  final response = await http.post(
      Uri.https(Constants.awsAPIGateway, "/dev/Lambda_RegisterAddress"),
      body: body,
      headers: headers);

  print(response.body);
  // final jsonPayload = jsonDecode(response.body);

  // print(jsonPayload);
  // return true;
}

Future<void> sendNotification(
    String targetAddress, String amountReceived, String crypto) async {
  final body = jsonEncode({
    "targetAddress": targetAddress.toLowerCase(),
    "message":
        "{ \"notification\": { \"body\": \"Payment received of amount $amountReceived INR in $crypto\", \"title\": \"Crypto Payment Received\" } }"
  });
  final headers = {
    'x-api-key': dotenv.env['LAMBDA_SEND_NOTIFICATION'].toString()
  };

  final response = await http.post(
      Uri.https(Constants.awsAPIGateway, "/dev/Lambda_SendNotification"),
      body: body,
      headers: headers);  

  final jsonPayload = jsonDecode(response.body);

  print("sendNotification");
  print(jsonPayload);
}

Future<void> loginSuccessNotification(String targetAddress) async {
  final body = jsonEncode({
    "targetAddress": targetAddress.toLowerCase(),
    "message":
        "{ \"notification\": { \"body\": \"You are successfully logged in\", \"title\": \"Login Successfull\" } }"
  });
  final headers = {
    'x-api-key': dotenv.env['LAMBDA_SEND_NOTIFICATION'].toString()
  };

  final response = await http.post(
      Uri.https(Constants.awsAPIGateway, "/dev/Lambda_SendNotification"),
      body: body,
      headers: headers);

  final jsonPayload = jsonDecode(response.body);

  print("sendNotification");
  print(jsonPayload);
}
