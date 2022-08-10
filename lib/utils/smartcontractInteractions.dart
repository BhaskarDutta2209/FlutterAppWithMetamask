import 'dart:math';

import 'package:flutter/services.dart';
import 'package:my_app/utils/constants.dart';
import 'package:my_app/utils/smartContractFunctions.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

Future<String> sendEther(WalletConnect connector, String uri,
    String senderAddress, String receiverAddress, BigInt value) async {
  try {
    EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);
    launchUrlString(uri, mode: LaunchMode.externalApplication);
    var res = await provider.sendTransaction(
        to: receiverAddress, from: senderAddress, value: value);
    print("Result of sending Ether");
    print(res.toString());
    return res.toString();
  } catch (exp) {
    print("Error while transfering Ether");
    print(exp);
    return "";
  }
}

Future<String> linkUPI(WalletConnect connector, String uri,
    String receiverAddress, String upiId, String name) async {
  try {
    final contract = await loadContract();
    ContractFunction ethFunction = contract.function('linkUPI');
    List<dynamic> args = [upiId, name];
    final data = ethFunction.encodeCall(args);

    EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);
    launchUrlString(uri, mode: LaunchMode.externalApplication);
    var res = await provider.sendTransaction(
        from: receiverAddress, to: Constants.contractAddress, data: data);
    print("linkUPI");
    print(res.toString());
    return res.toString();
  } catch (exp) {
    print("Error while linking UPI");
    print(exp);
    return "";
  }
}

Future<String> transferERC20Token(
    WalletConnect connector,
    String uri,
    Web3Client web3Client,
    String tokenName,
    String senderAddress,
    String receiverAddress,
    double value) async {
  try {
    // Load the erc20 token contract
    String erc20ContractABI = await rootBundle
        .loadString('assets/blockchain/erc20TokenContractABI.json');
    String contractAddress = getTokenContractAddress(tokenName);
    final contract = DeployedContract(
        ContractAbi.fromJson(erc20ContractABI, "ERC20"),
        EthereumAddress.fromHex(contractAddress));

    EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);

    // Get the decimal
    ContractFunction decimalFunction = contract.function('decimals');
    final decimalResult = await web3Client
        .call(contract: contract, function: decimalFunction, params: []);
    double decimal = double.parse(decimalResult[0].toString());
    print("Decimal => " + decimal.toString());

    // Generate data for the transactio
    ContractFunction function = contract.function('transfer');
    List<dynamic> args = [
      EthereumAddress.fromHex(receiverAddress),
      BigInt.from(value * pow(10, decimal))
    ];
    final data = function.encodeCall(args);

    // Get the gasPrice
    EtherAmount gasPrice = await web3Client.getGasPrice();

    // Send the transaction
    launchUrlString(uri, mode: LaunchMode.externalApplication);
    var res = await provider.sendTransaction(
        from: senderAddress,
        to: contractAddress,
        data: data,
        gasPrice: BigInt.from(int.parse(gasPrice.getInWei.toString())));

    return res.toString();
  } catch (exp) {
    print("Error while transfering ERC20 token");
    print(exp);
    return "";
  }
}
