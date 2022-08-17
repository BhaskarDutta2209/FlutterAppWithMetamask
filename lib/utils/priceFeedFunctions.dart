import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:my_app/utils/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<DeployedContract> loadAggregatorContract(String crypto) async {
  String aggregatorContractDataString = await rootBundle
      .loadString('assets/blockchain/chainlinkAggregatorAbi.json');
  String address = getAggregatorAddress(crypto);
  final contract = DeployedContract(
      ContractAbi.fromJson(aggregatorContractDataString, "EACAggregatorProxy"),
      EthereumAddress.fromHex(address));

  return contract;
}

Future<String> getDecimal(String crypto, Web3Client web3client) async {
  final contract = await loadAggregatorContract(crypto);
  final ethFunction = contract.function('decimals');
  List<dynamic> args = [];
  final result = await web3client.call(
      contract: contract, function: ethFunction, params: args);
  return result[0].toString();
}

Future<double> getLatestRoundData(String crypto, Web3Client web3client) async {
  final contract = await loadAggregatorContract(crypto);
  final ethFunction = contract.function('latestRoundData');
  List<dynamic> args = [];
  final decimal = await getDecimal(crypto, web3client);
  final result = await web3client.call(
      contract: contract, function: ethFunction, params: args);
  double price =
      double.parse(result[1].toString()) / pow(10, double.parse(decimal));
  return price;
}

Future<double> fetchPrice(String currency) async {
  // String url =
  //     "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=${currency}&apikey=${dotenv.env['ALPHAVANTAGE_KEY'].toString()}";
  // final res = await http.get(Uri.parse(url));

  // final jsonPayload = jsonDecode(res.body);
  // print("Received from alphavantage => " + jsonPayload.toString());
  // final rate =
  //     jsonPayload["Realtime Currency Exchange Rate"]["5. Exchange Rate"];

  // // print("Rate => " + rate.toString());
  // // print("Alpha Vantage => " + res.body.toString());
  // return double.parse(rate);

  String url = "alpha-vantage.p.rapidapi.com";

  final queryParameters = {
    'to_currency': '${currency}',
    'function': 'CURRENCY_EXCHANGE_RATE',
    'from_currency': 'USD'
  };
  final headers = {
    'X-RapidAPI-Key': dotenv.env['X-RapidAPI-Key'].toString(),
    'X-RapidAPI-Host': 'alpha-vantage.p.rapidapi.com'
  };

  final res =
      await http.get(Uri.https(url, "/query", queryParameters), headers: headers);
  final jsonPayload = jsonDecode(res.body);
  print("Received from alphavantage => " + jsonPayload.toString());
  final rate =
      jsonPayload["Realtime Currency Exchange Rate"]["5. Exchange Rate"];

  // print("Rate => " + rate.toString());
  // print("Alpha Vantage => " + res.body.toString());
  return double.parse(rate);
}
