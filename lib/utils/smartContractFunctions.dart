import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:my_app/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

Future<DeployedContract> loadContract() async {
  String contractDataString = await rootBundle.loadString(
      'smartcontracts/artifacts/contracts/UPIToAddress.sol/UPIToAddress.json');
  final contractDataJSON = await jsonDecode(contractDataString);
  final abi = jsonEncode(contractDataJSON['abi']);
  String address = Constants.contractAddress;
  final contract = DeployedContract(
      ContractAbi.fromJson(abi.toString(), "UPIToAddress"),
      EthereumAddress.fromHex(address));

  return contract;
}

Future<List<dynamic>> getAddress(String uri, Web3Client web3client) async {
  print("Finding the address");
  final contract = await loadContract();
  ContractFunction ethFunction = contract.function('getAddress');
  List<dynamic> args = [uri];
  final result = await web3client.call(
      contract: contract, function: ethFunction, params: args);
  print("Found address" + result.toString());
  return result;
}

Future<List<dynamic>> getUserDetails(String uri, Web3Client web3client) async {
  try {
    final contract = await loadContract();
    final ethFunction = contract.function('getUserDetails');
    List<dynamic> args = [uri];
    final result = await web3client.call(
        contract: contract, function: ethFunction, params: args);
    print("Found address" + result.toString());
    return result;
  } catch (exp) {
    print("Exception while getting User Details");
    print(exp);
    return [];
  }
}
