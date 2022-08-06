import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:my_app/pages/confirmpayment_page.dart';
import 'package:my_app/utils/helperfunctions.dart';
import 'package:my_app/utils/priceFeedFunctions.dart';
import 'package:my_app/utils/smartContractFunctions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io' show Platform;

import 'package:web3dart/web3dart.dart';

class PayWidget extends StatefulWidget {
  final session, uri;

  const PayWidget({Key? key, @required this.session, @required this.uri})
      : super(key: key);

  @override
  State<PayWidget> createState() => _PayWidgetState();
}

class _PayWidgetState extends State<PayWidget> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
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
    if (result == null) {
      return Center(
          child: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.purple,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ));
    } else if (checkUPI(result!.code.toString())) {
      return FutureBuilder<List>(
          future:
              getUserDetails(obtainUPIId(result!.code.toString()), web3client),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ConfirmPaymentPage(
                receiverName: snapshot.data![0][0].toString(),
                receiverUPI: snapshot.data![0][1].toString(),
                accountAddress: snapshot.data![0][2].toString(),
                web3Client: web3client);
          });
    } else {
      return const Text("Not Valid UPI");
    }
  }

  @override
  void dispose() {
    print("Dispose Is called");
    controller?.dispose();
    super.dispose();
  }
}
