import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_app/pages/second_page.dart';
import 'package:my_app/utils/awsAPIGateways.dart';
import 'package:my_app/utils/helperfunctions.dart';
import 'package:my_app/utils/routes.dart';
import 'package:my_app/utils/smartContractInteractions.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slider_button/slider_button.dart';
import 'package:web3dart/credentials.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
          name: 'My App',
          description: 'An app for converting pictures to NFT',
          url: 'https://walletconnect.org',
          icons: [
            'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ]));

  var _session, _uri, _signature, deviceToken;
  bool showSlider = true;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin fltNotification =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((value) => {deviceToken = value});
    initMessaging().then((value) => null);
  }

  Future<void> initMessaging() async {
    var androidInit =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInit = const IOSInitializationSettings();
    var initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await fltNotification.initialize(initSettings);
    var androidDetails = const AndroidNotificationDetails('1', 'channelName',
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high);
    var iosDetails = const IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _firebaseMessagingBackgroundHandler(message, generalNotificationDetails);
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message, var _generalNotificationDetails) async {
    print("Message Received => " + message.notification!.body.toString());
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      fltNotification.show(notification.hashCode, notification.title,
          notification.body, _generalNotificationDetails);
    }
  }

  loginUsingMetamask(BuildContext context) async {
    if (!connector.connected) {
      try {
        var session = await connector.createSession(onDisplayUri: (uri) async {
          _uri = uri;
          await launchUrlString(uri, mode: LaunchMode.externalApplication);
        });
        setState(() {
          _session = session;
        });
      } catch (exp) {
        print(exp);
      }
    }
  }

  signMessageWithMetamask(BuildContext context, String message) async {
    if (connector.connected) {
      try {
        EthereumWalletConnectProvider provider =
            EthereumWalletConnectProvider(connector);
        launchUrlString(_uri, mode: LaunchMode.externalApplication);
        Map<String, dynamic> data = {
          "types": {
            "EIP712Domain": [
              {"name": "name", "type": "string"},
              {"name": "version", "type": "string"},
              {"name": "chainId", "type": "uint256"},
            ],
            "data": [
              {"name": "user", "type": "string"},
              {"name": "appname", "type": "string"},
              {"name": "acknowledgement", "type": "string"},
              {"name": "github", "type": "string"}
            ]
          },
          "primaryType": "data",
          "domain": {
            "name": "CryptoPay",
            "version": "1.0",
            "chainId": _session.chainId,
          },
          "message": {
            "user": _session.accounts[0],
            "appname": "CryptoPay",
            "acknowledgement":
                "I acknowledge that this app is just a POC and prone to various bugs",
            "github":
                "https://github.com/BhaskarDutta2209/FlutterAppWithMetamask"
          }
        };
        var signature = await provider.signTypeData(
            address: _session.accounts[0], typedData: data);
        setState(() {
          _signature = signature;
        });
      } catch (exp) {
        print("Error while signing transaction");
        print(exp);
      }
    }
  }

  sendingTransaction(BuildContext context) async {
    if (connector.connected) {
      try {
        EthereumWalletConnectProvider provider =
            EthereumWalletConnectProvider(connector);
        launchUrlString(_uri, mode: LaunchMode.externalApplication);
        var res = await provider.sendTransaction(
          to: "0x18a3370A06e3F83C9Ad8C488A7F02E735a95A484",
          from: _session.accounts[0],
          value: BigInt.from(100000000000000000),
        );
        print(res);
      } catch (exp) {
        print("Error while sending transaction");
        print(exp);
      }
    }
  }

  getNetworkName(chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goreli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      case 80001:
        return 'Mumbai Testnet';
      default:
        return 'Unknown Chain';
    }
  }

  @override
  Widget build(BuildContext context) {
    connector.on(
        'connect',
        (session) => setState(
              () {
                _session = _session;
              },
            ));
    connector.on(
        'session_update',
        (payload) => setState(() {
              _session = payload;
            }));
    connector.on(
        'disconnect',
        (payload) => setState(() {
              _session = null;
            }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/polygon.png',
              fit: BoxFit.fitHeight,
            ),
            (_session != null)
                ? Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: GoogleFonts.merriweather(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${_session.accounts[0]}',
                          style: GoogleFonts.inconsolata(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Chain: ',
                              style: GoogleFonts.merriweather(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              getNetworkName(_session.chainId),
                              style: GoogleFonts.inconsolata(fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        (_session.chainId != 80001)
                            ? Row(
                                children: const [
                                  Icon(Icons.warning,
                                      color: Colors.redAccent, size: 15),
                                  Text('Network not supported. Switch to '),
                                  Text(
                                    'Mumbai Testnet',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                            : (_signature == null)
                                ? Container(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                        onPressed: () =>
                                            signMessageWithMetamask(
                                                context,
                                                generateSessionMessage(
                                                    _session.accounts[0])),
                                        child: const Text('Sign Message')),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Signature: ",
                                            style: GoogleFonts.merriweather(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Text(
                                              truncateString(
                                                  _signature.toString(), 4, 2),
                                              style: GoogleFonts.inconsolata(
                                                  fontSize: 16))
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // ElevatedButton(
                                      //     onPressed: () async {
                                      //       await sendNotification(
                                      //           "0x3310A13F37Ac2FC7A932C4f1a5fE15F342f4E048",
                                      //           "100",
                                      //           "DOGECOIN");
                                      //       await sendNotification(
                                      //           "0x6ef91a90C46201da680430B49583Bf3b47FfAc26",
                                      //           "100",
                                      //           "DOGECOIN");
                                      //     },
                                      //     child:
                                      //         const Text("Send Notificaiton")),
                                      (showSlider)
                                          ? SliderButton(
                                              action: () async {
                                                setState(() {
                                                  showSlider = false;
                                                });
                                                await registerAddress(
                                                    deviceToken,
                                                    _session.accounts[0]
                                                        .toString());
                                                await loginSuccessNotification(
                                                    _session.accounts[0]
                                                        .toString());
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            SecondPage(
                                                                connector:
                                                                    connector,
                                                                session:
                                                                    _session,
                                                                uri: _uri)));
                                                setState(() {
                                                  showSlider = true;
                                                });
                                              },
                                              label:
                                                  const Text('Slide to login'),
                                              icon: const Icon(Icons.check),
                                            )
                                          : const CircularProgressIndicator()
                                    ],
                                  )
                      ],
                    ))
                : ElevatedButton(
                    onPressed: () => loginUsingMetamask(context),
                    child: const Text("Connect with Metamask"))
          ],
        ),
      ),
    );
  }
}
