import 'package:web3dart/crypto.dart';

String truncateString(String text, int front, int end) {
  int size = front + end;

  if (text.length > size) {
    String finalString =
        "${text.substring(0, front)}...${text.substring(text.length - end)}";
    return finalString;
  }

  return text;
}

String generateSessionMessage(String accountAddress) {
  String message =
      'Hello $accountAddress, welcome to our app. By signing this message you agree to learn and have fun with blockchain';
  print(message);

  var hash = keccakUtf8(message);
  final hashString = '0x${bytesToHex(hash).toString()}';

  return hashString;
}

bool checkUPI(String text) {
  // NOTE: THIS DOESN"T PERFORM PROPER AUTHENTICATION OF THE UPI ID
  return (text.substring(0, 13) == "upi://pay?pa=");
}

String obtainUPIId(String text) {
  text = text.substring(13);
  int size = text.length;

  String result = "";

  for (int i = 0; i < size; i++) {
    if (text[i] == '&') {
      break;
    } else {
      result = result + text[i];
    }
  }

  return result;
}
