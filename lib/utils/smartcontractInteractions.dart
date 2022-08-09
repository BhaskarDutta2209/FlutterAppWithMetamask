import 'dart:math';

import 'package:flutter/services.dart';
import 'package:my_app/utils/constants.dart';
import 'package:my_app/utils/smartContractFunctions.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

sendEther(WalletConnect connector, String uri, String senderAddress,
    String receiverAddress, BigInt value) async {
  try {
    EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);
    launchUrlString(uri, mode: LaunchMode.externalApplication);
    var res = await provider.sendTransaction(
        to: receiverAddress, from: senderAddress, value: value);
  } catch (exp) {
    print("Error while transfering Ether");
    print(exp);
  }
}

linkUPI(WalletConnect connector, String uri, String receiverAddress,
    String upiId, String name) async {
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
  } catch (exp) {
    print("Error while linking UPI");
    print(exp);
  }
}

transferERC20Token(
    WalletConnect connector,
    String uri,
    Web3Client web3Client,
    String tokenName,
    String senderAddress,
    String receiverAddress,
    double value) async {
  print("transfering ERC20 token");
  try {
    // // Load the erc20 token contract
    String erc20ContractABI = await rootBundle
        .loadString('assets/blockchain/erc20TokenContractABI.json');
    String contractAddress = getTokenContractAddress(tokenName);
    final contract = DeployedContract(
        ContractAbi.fromJson(erc20ContractABI, "LinkToken"),
        EthereumAddress.fromHex(contractAddress));

    // // Get the decimal value
    // ContractFunction function = contract.function('decimals');
    // List<dynamic> args = [];

    // Calculate the amount to send

    // Send the tokens
    EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);
    ContractFunction function = contract.function('transfer');
    List<dynamic> args = [
      EthereumAddress.fromHex(receiverAddress),
      BigInt.from(value * pow(10, 18))
    ];
    final data = function.encodeCall(args);

    EtherAmount gasPrice = await web3Client.getGasPrice();

    launchUrlString(uri, mode: LaunchMode.externalApplication);
    var res = await provider.sendTransaction(
        from: senderAddress,
        to: contractAddress,
        data: data,
        // gas: int.parse(gas.getInEther.toString()),
        gasPrice: BigInt.from(int.parse(gasPrice.getInWei.toString())));

    print("transfering ERC20 token");
    print(res.toString());
  } catch (exp) {
    print("Error while transfering ERC20 token");
    print(exp);
  }
}
