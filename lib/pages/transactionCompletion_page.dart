import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class TransactionCompletionPage extends StatefulWidget {
  final txHash;
  const TransactionCompletionPage({Key? key, required this.txHash})
      : super(key: key);

  @override
  State<TransactionCompletionPage> createState() =>
      _TransactionCompletionPageState();
}

class _TransactionCompletionPageState extends State<TransactionCompletionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Transaction"),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Pop"))
        ],
      ),
    );
  }
}
