import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:my_app/pages/transactionCompletion_page.dart';
import 'package:my_app/utils/smartcontractInteractions.dart';

class HomeWidget extends StatefulWidget {
  final connector, uri, receiverAddress;
  const HomeWidget(
      {Key? key,
      required this.connector,
      required this.uri,
      required this.receiverAddress})
      : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String name = "";
    String upi = "";

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top Features"),
          const SizedBox(height: 5),
          SizedBox(
            height: 200,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(10)),
                              // isDismissible: false,
                              // isScrollControlled: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Link your UPI",
                                    style: TextStyle(
                                        fontFamily: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .fontFamily,
                                        fontSize: 16),
                                  ),
                                  content: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            onChanged: (value) => setState(() {
                                              name = value;
                                            }),
                                            validator: (String? value) {
                                              return (value!.isEmpty)
                                                  ? "Name can't be empty"
                                                  : null;
                                            },
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                hintText: "Enter Name",
                                                labelText: "Enter Your Name"),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            onChanged: ((value) => setState(() {
                                                  upi = value;
                                                })),
                                            validator: (String? value) {
                                              return (value!.isEmpty ||
                                                      !value.contains('@'))
                                                  ? "Not valid UPI Id"
                                                  : null;
                                            },
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                hintText: "Enter Your UPI",
                                                labelText: "Enter Your UPI"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            String txHash = await linkUPI(
                                                widget.connector,
                                                widget.uri,
                                                widget.receiverAddress,
                                                upi,
                                                name);
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        TransactionCompletionPage(
                                                          isCryptoTransfer: false,
                                                            txHash: txHash)));
                                          }
                                        },
                                        child: const Text("Link")),
                                  ],
                                );
                              });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/register_icon.png",
                              width: 40,
                            ),
                            const Text(
                              "Link UPI",
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
