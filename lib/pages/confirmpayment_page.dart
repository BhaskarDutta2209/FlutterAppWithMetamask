import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/utils/helperfunctions.dart';
import 'package:my_app/utils/priceFeedFunctions.dart';
import 'package:web3dart/web3dart.dart';

class ConfirmPaymentPage extends StatefulWidget {
  final receiverName;
  final receiverUPI;
  final accountAddress;
  final Web3Client web3Client;
  const ConfirmPaymentPage(
      {Key? key,
      @required this.receiverName,
      @required this.receiverUPI,
      @required this.accountAddress,
      required this.web3Client})
      : super(key: key);

  @override
  State<ConfirmPaymentPage> createState() => _ConfirmPaymentPageState();
}

class _ConfirmPaymentPageState extends State<ConfirmPaymentPage> {
  final _formKey = GlobalKey<FormState>();

  double fiatAmount = 0;
  double cryptoAmount = 0;
  String crypto = "";
  double exchangeRate = 0;

  final List<String> _items = [
    'MATIC',
    'UNI',
    'BAT',
    '1INCH',
    'CAKE',
    'USDC',
    'USDT'
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
    double inrToUSD = await fetchPrice('INR');
    print("INR to USD => " + inrToUSD.toString());
    double _exchangeRate = usdPrice * inrToUSD;
    print("Exchange Rate");
    print(exchangeRate);
    setState(() {
      exchangeRate = _exchangeRate;
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
                truncateString(widget.accountAddress, 10, 3),
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
                          Expanded(
                              child: TextFormField(
                            controller: TextEditingController(
                                text: cryptoAmount.toString()),
                            // initialValue: cryptoAmount.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          )),
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
                              print("onChanged executed");
                              await calculateExchangePrice(
                                  context, value.toString());
                              setState(() {
                                crypto = value.toString();
                              });
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
                                  onPressed: () {},
                                  child: const Text(
                                    "Pay",
                                  )))
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () => loadPrice(context, 'MATIC'),
                          child: const Text("Load Price"))
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}
