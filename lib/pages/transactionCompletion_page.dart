import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/datastructures/enums.dart';
import 'package:my_app/utils/awsAPIGateways.dart';
import 'package:my_app/utils/blockexplorerServices.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TransactionCompletionPage extends StatefulWidget {
  final txHash, targetAddress, amountReceived, crypto;
  final bool isCryptoTransfer;
  const TransactionCompletionPage(
      {Key? key,
      required this.txHash,
      required this.isCryptoTransfer,
      @required this.targetAddress,
      @required this.amountReceived,
      @required this.crypto})
      : super(key: key);

  @override
  State<TransactionCompletionPage> createState() =>
      _TransactionCompletionPageState();
}

class _TransactionCompletionPageState extends State<TransactionCompletionPage> {
  @override
  Widget build(BuildContext context) {
    String blockexplorerUrl =
        "https://mumbai.polygonscan.com/tx/${widget.txHash}";

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Transaction"),
      //   automaticallyImplyLeading: false,
      // ),
      // backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<TransactionState>(
              future: waitForTransactionConfirmation(widget.txHash),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: Colors.purple,
                  );
                } else {
                  print("received status => " + snapshot.data!.toString());
                  if (snapshot.data == TransactionState.failed) {
                    return Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/lottie/transactionfailed.json",
                            width: 200),
                        Text(
                          "Transaction Failed",
                          style: TextStyle(
                              fontFamily: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .fontFamily,
                              fontSize: 18,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            launchUrlString(blockexplorerUrl,
                                mode: LaunchMode.externalApplication);
                          },
                          child: const Text(
                            "Check in block explorer",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Back"))
                      ],
                    ));
                  } else if (snapshot.data == TransactionState.success) {
                    if (widget.isCryptoTransfer) {
                      sendNotification(
                              widget.targetAddress.toString(),
                              widget.amountReceived.toString(),
                              widget.crypto.toString())
                          .then((value) => {});
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/lottie/success.json", width: 200),
                        Text(
                          "Transaction Successfull",
                          style: TextStyle(
                              fontFamily: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .fontFamily,
                              fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            launchUrlString(blockexplorerUrl,
                                mode: LaunchMode.externalApplication);
                          },
                          child: const Text(
                            "View in block explorer",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Done"))
                      ],
                    );
                  } else if (snapshot.data == TransactionState.timeout) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/lottie/timeout.json", width: 200),
                        Text(
                          "Verification Timeout",
                          style: TextStyle(
                              fontFamily: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .fontFamily,
                              fontSize: 18,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            launchUrlString(blockexplorerUrl,
                                mode: LaunchMode.externalApplication);
                          },
                          child: const Text(
                            "Check in block explorer",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Back"))
                      ],
                    );
                  } else {
                    return const Text("Error in transaction verification");
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
