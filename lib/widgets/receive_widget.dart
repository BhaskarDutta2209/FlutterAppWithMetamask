import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveWidget extends StatefulWidget {
  final session, uri;

  const ReceiveWidget({Key? key, @required this.session, @required this.uri})
      : super(key: key);

  @override
  State<ReceiveWidget> createState() => _ReceiveWidgetState();
}

class _ReceiveWidgetState extends State<ReceiveWidget> {
  @override
  Widget build(BuildContext context) {
    var payload = {
      'chainId': widget.session.chainId,
      'accountAddress': widget.session.accounts[0]
    };

    print(payload);

    return Column(children: [
      QrImage(
        data: "This is a simple data",
        version: QrVersions.auto,
        size: 200,
      )
    ]);
  }
}
