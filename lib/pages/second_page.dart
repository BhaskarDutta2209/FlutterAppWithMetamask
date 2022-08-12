import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/widgets/cards_widget.dart';
import 'package:my_app/widgets/home_widget.dart';
import 'package:my_app/widgets/pay_widget.dart';
import 'package:my_app/widgets/receive_widget.dart';

class SecondPage extends StatefulWidget {
  final connector, session, uri;
  const SecondPage(
      {Key? key,
      required this.connector,
      required this.session,
      required this.uri})
      : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int _currentIndex = 0;

  final appBarTitles = ['Home', 'Cards', 'Pay', 'Receive'];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = [
      HomeWidget(
        connector: widget.connector,
        uri: widget.uri,
        receiverAddress: widget.session.accounts[0],
      ),
      CardsWidget(),
      PayWidget(
          connector: widget.connector,
          session: widget.session,
          uri: widget.uri),
      ReceiveWidget(
        session: widget.session,
        uri: widget.uri,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_currentIndex]),
        automaticallyImplyLeading: false,
      ),
      body: _widgetOptions.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_rounded), label: 'cards'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded), label: 'pay'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_rounded), label: 'receive')
        ],
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
      ),
    );
  }
}
