import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveWidget extends StatelessWidget {
  const ReceiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      QrImage(
        data: "This is a simple data",
        version: QrVersions.auto,
        size: 200,
      )
    ]);
  }
}
