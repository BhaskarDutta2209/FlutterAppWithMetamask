class Constants {
  static String contractAddress = "0x6bb06385cFa489480F5163558F437fa0Ff541a5C";
}

String getAggregatorAddress(String crypto) {
  switch (crypto) {
    case "MATIC":
      return "0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada";
    case "LINK":
      return "0x12162c3E810393dEC01362aBf156D7ecf6159528";
    case "DAI":
      return "0x0FCAa9c899EC5A91eBc3D5Dd869De833b06fB046";
    case "USDC":
      return "0x572dDec9087154dC5dfBB1546Bb62713147e0Ab0";
    case "USDT":
      return "0x92C09849638959196E976289418e5973CC96d645";
    default:
      return "";
  }
}
