class Constants {
  static String contractAddress = "0x6bb06385cFa489480F5163558F437fa0Ff541a5C";
}

String getAggregatorAddress(String crypto) {
  switch (crypto) {
    case "MATIC":
      return "0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada";
    case "1INCH":
      return "0x443C5116CdF663Eb387e72C688D276e702135C87";
    case "DAI":
      return "0x4746DeC9e833A82EC7C2C1356372CcF2cfcD2F3D";
    default:
      return "";
  }
}
