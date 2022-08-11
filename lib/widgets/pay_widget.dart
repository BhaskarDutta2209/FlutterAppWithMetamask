import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:my_app/widgets/paymentDetails_widget.dart';
import 'package:my_app/utils/helperfunctions.dart';
import 'package:my_app/utils/priceFeedFunctions.dart';
import 'package:my_app/utils/smartContractFunctions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io' show Platform;

import 'package:web3dart/web3dart.dart';

class PayWidget extends StatefulWidget {
  final connector, session, uri;

  const PayWidget(
      {Key? key,
      required this.connector,
      required this.session,
      required this.uri})
      : super(key: key);

  @override
  State<PayWidget> createState() => _PayWidgetState();
}

class _PayWidgetState extends State<PayWidget> {
  Barcode? result;
  String upiId = "";
  bool upiIdFound = false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _formKey = GlobalKey<FormState>();

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      if (checkUPI(scanData.code.toString())) {
        setState(() {
          result = scanData;
          upiId = obtainUPIId(scanData.code.toString());
          upiIdFound = true;
        });
      } else {
        setState(() {
          result = scanData;
          upiIdFound = false;
        });
      }
    });
  }

  @override
  void reassemble() {
    print("reassemble Is called");
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void readQr(context) async {
    print("readQr Is called");
    if (result != null) {
      controller!.pauseCamera();
      controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Client();
    final web3client =
        Web3Client(dotenv.env['RPC_ENDPOINT'].toString(), client);

    readQr(context);
    if (!upiIdFound) {
      return Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.all(10),
            child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onSaved: (value) {
                          setState(() {
                            upiId = value.toString();
                            upiIdFound = true;
                          });
                        },
                        decoration: const InputDecoration(
                            hintText: "Enter UPI Id",
                            labelText: "Receiver UPI Id"),
                      ),
                    ),
                    Container(
                      width: 50,
                      child: ElevatedButton(
                        child: const Icon(Icons.send),
                        onPressed: () {
                          _formKey.currentState!.save();
                        },
                      ),
                    )
                  ],
                )),
          ),
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderColor: Colors.purple,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250),
            ),
          )
        ],
      );
    } else {
      return FutureBuilder<List>(
          future: getUserDetails(upiId, web3client),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            print("Snapshot => " + snapshot.data!.toString());
            if (snapshot.data![0][3].toString() == "false") {
              return AlertDialog(
                title: const Text("Unregistered UPI"),
                content:
                    const Text("This UPI is not registered. Please try again"),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          result = null;
                          upiId = "";
                          upiIdFound = false;
                        });
                      },
                      child: const Text("Ok"))
                ],
              );
            } else {
              return PaymentDetailsPage(
                  connector: widget.connector,
                  uri: widget.uri,
                  senderAddress: widget.session.accounts[0],
                  receiverName: snapshot.data![0][0].toString(),
                  receiverUPI: snapshot.data![0][1].toString(),
                  receiverAddress: snapshot.data![0][2].toString(),
                  web3Client: web3client);
            }
          });
    }
  }

  @override
  void dispose() {
    print("Dispose Is called");
    controller?.dispose();
    super.dispose();
  }
}
