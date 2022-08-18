import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/pages/transactionCompletion_page.dart';
import 'package:my_app/utils/blockexplorerServices.dart';
import 'package:my_app/utils/helperfunctions.dart';
import 'package:my_app/utils/priceFeedFunctions.dart';
import 'package:my_app/utils/smartContractInteractions.dart';
import 'package:web3dart/web3dart.dart';

class PaymentDetailsPage extends StatefulWidget {
  final connector;
  final uri;
  final senderAddress;
  final receiverName;
  final receiverUPI;
  final receiverAddress;
  final Web3Client web3Client;
  const PaymentDetailsPage(
      {Key? key,
      required this.connector,
      required this.uri,
      required this.senderAddress,
      required this.receiverName,
      required this.receiverUPI,
      required this.receiverAddress,
      required this.web3Client})
      : super(key: key);

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  double fiatAmount = 0;
  String crypto = "";
  double cryptoAmount = 0;
  bool cryptoPriceSet = false;
  double exchangeRate = 0;
  double inrToUSD = 0;
  // bool paymentTransactionMade = false;
  // String paymentTransactionHash = "";
  // bool paymentTransactionSuccess = false;

  final List<String> _items = [
    'MATIC',
    'DAI',
    'LINK',
    'USDC',
    'USDT',
  ];

  loadPrice(BuildContext context, String token) async {
    double price = await getLatestRoundData(token, widget.web3Client);
    print(price);

    double inrToUSD = await fetchPrice('INR');
    print(inrToUSD);
    return price;
  }

  calculateExchangePrice(BuildContext context, String crypto) async {
    // Calculate Crypto to INR

    double usdPrice = await loadPrice(context, crypto);
    if (inrToUSD == 0) {
      inrToUSD = await fetchPrice('INR');
    }

    double _exchangeRate = usdPrice * inrToUSD;
    setState(() {
      exchangeRate = _exchangeRate;
      cryptoAmount = fiatAmount / exchangeRate;
      cryptoPriceSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Paying To"),
              const SizedBox(
                height: 5,
              ),
              Text(
                widget.receiverName,
                style: TextStyle(
                    fontFamily:
                        Theme.of(context).textTheme.headline2!.fontFamily,
                    fontSize: 20),
              ),
              Text(
                truncateString(widget.receiverAddress, 10, 3),
                style: TextStyle(
                    fontFamily:
                        Theme.of(context).textTheme.headline3!.fontFamily,
                    fontSize: 18),
              ),
              const SizedBox(
                height: 5,
              ),
              Text("UPI: ${widget.receiverUPI}"),
              const SizedBox(
                height: 20,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ],
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Enter Amount",
                              labelText: 'Amount',
                              prefixText: '\u{20B9} '),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                fiatAmount = double.parse(value);
                                cryptoAmount = fiatAmount / exchangeRate;
                              });
                            } else {
                              setState(() {
                                print("SetState is called");
                                fiatAmount = 0;
                                cryptoAmount = 0;
                              });
                            }
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          (cryptoPriceSet)
                              ? Expanded(
                                  child: TextFormField(
                                  controller: TextEditingController(
                                      text: cryptoAmount.toString()),
                                  enabled: cryptoAmount != 0,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ))
                              : (crypto.isNotEmpty)
                                  ? const Expanded(child: Text("Loading Price"))
                                  : const Expanded(
                                      child: Text("Choose Crypto")),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: DropdownSearch<String>(
                            items: _items,
                            // selectedItem: _items[0],
                            popupProps: const PopupProps.modalBottomSheet(
                                showSearchBox: true),
                            onChanged: (value) async {
                              setState(() {
                                crypto = value.toString();
                                cryptoPriceSet = false;
                              });
                              await calculateExchangePrice(
                                  context, value.toString());
                            },

                            dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    labelText: 'Crypto',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            // selectedItem: _items[0],
                          ))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    String tx = "";
                                    if (cryptoAmount != 0 && cryptoAmount.isFinite) {
                                      if (crypto == 'MATIC') {
                                        tx = await sendEther(
                                            widget.connector,
                                            widget.uri,
                                            widget.senderAddress,
                                            widget.receiverAddress,
                                            BigInt.from(
                                                cryptoAmount * pow(10, 18)));
                                      } else {
                                        tx = await transferERC20Token(
                                            widget.connector,
                                            widget.uri,
                                            widget.web3Client,
                                            crypto,
                                            widget.senderAddress,
                                            widget.receiverAddress,
                                            cryptoAmount);
                                      }
                                      // TODO: Navigate to next page
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  TransactionCompletionPage(
                                                    amountReceived: fiatAmount,
                                                    crypto: crypto,
                                                    targetAddress: widget.receiverAddress,
                                                    isCryptoTransfer: true,
                                                      txHash: tx)));
                                    }
                                  },
                                  child: const Text(
                                    "Pay",
                                  ))),
                        ],
                      ),
                    ],
                  )),
            ],
          )
        ],
      ),
    );
  }
}
