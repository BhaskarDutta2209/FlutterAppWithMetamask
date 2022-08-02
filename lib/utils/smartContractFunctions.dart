import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:my_app/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

// class SmartContractHelper {
//   Client client = Client();
//   late Web3Client web3client;

//   SmartContractHelper() {
//     web3client = new Web3Client(dotenv.env['RPC_ENDPOINT'].toString(), client);
//   }

//   Future<DeployedContract> loadContract() async {
//     String contractDataString = await rootBundle.loadString(
//         'smartcontracts/artifacts/contracts/UPIToAddress.sol/UPIToAddress.json');
//     final contractDataJSON = await jsonDecode(contractDataString);
//     final abi = contractDataJSON['abi'];
//     String address = Constants.contractAddress;
//     final contract = DeployedContract(
//         ContractAbi.fromJson(abi.toString(), 'UPIToAddress'),
//         EthereumAddress.fromHex(address));

//     return contract;
//   }

//   Future<List<dynamic>> getAddress(String uri) async {
//     print("Finding the address");
//     final contract = await loadContract();
//     final ethFunction = contract.function('getAddress');
//     List<dynamic> args = [];
//     final result = await web3client.call(
//         contract: contract, function: ethFunction, params: args);
//     print("Found address" + result.toString());
//     return result;
//   }
// }

Future<DeployedContract> loadContract() async {
  String contractDataString = await rootBundle.loadString(
      'smartcontracts/artifacts/contracts/UPIToAddress.sol/UPIToAddress.json');
  final contractDataJSON = await jsonDecode(contractDataString);
  final abi = jsonEncode(contractDataJSON['abi']);
  print(abi.toString());
  String address = Constants.contractAddress;
  final contract = DeployedContract(
      ContractAbi.fromJson(abi.toString(), "UPIToAddress"),
      EthereumAddress.fromHex(address));

  return contract;
}

Future<List<dynamic>> getAddress(String uri, Web3Client web3client) async {
  print("Finding the address");
  final contract = await loadContract();
  final ethFunction = contract.function('getAddress');
  List<dynamic> args = [uri];
  final result = await web3client.call(
      contract: contract, function: ethFunction, params: args);
  print("Found address" + result.toString());
  return result;
}
