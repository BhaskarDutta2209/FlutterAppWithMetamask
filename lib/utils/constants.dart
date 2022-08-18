class Constants {
  static String contractAddress = "0x6bb06385cFa489480F5163558F437fa0Ff541a5C";
  static int blockTimeInSeconds = 3;
  static String awsAPIGateway =
      "bliy7xvp86.execute-api.ap-south-1.amazonaws.com";
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

String getTokenContractAddress(String crypto) {
  switch (crypto) {
    case "LINK":
      return "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
    case "DAI":
      return "0xcB1e72786A6eb3b44C2a2429e317c8a2462CFeb1";
    case "USDC":
      return "0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747";
    case "USDT":
      return "0xA02f6adc7926efeBBd59Fd43A84f4E0c0c91e832";
    default:
      return "";
  }
}
