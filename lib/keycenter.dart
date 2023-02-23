class KeyCenter {
  static final KeyCenter instance = KeyCenter._internal();
  KeyCenter._internal();

  // Developers can get appID from admin console.
  // https://console.zego.im/dashboard
  // for example: 123456789
  int appID = 1647670150;

  // This value only needs to be filled in when running on native (non-web).
  // AppSign only meets simple authentication requirements.
  // If you need to upgrade to a more secure authentication method,
  // please refer to [Guide for upgrading the authentication mode from using the AppSign to Token](https://docs.zegocloud.com/faq/token_upgrade)
  // Developers can get AppSign from admin [console](https://console.zego.im/dashboard)
  // for example: "abcdefghijklmnopqrstuvwxyz0123456789abcdegfhijklmnopqrstuvwxyz01"
  String appSign =
      'ed521f0267d540a25da3965acd8a3862879ec65da7dceca224bc3fdd4bf5a3f0';

  // This value only needs to be filled in when running on web browser.
  // Developers can get token from admin console: https://console.zego.im/dashboard
  // Note: The user ID used to generate the token needs to be the same as the userID filled in above!
  // for example: "04AAAAAxxxxxxxxxxxxxx"
  String token = "";

  //"04AAAAAGPNelgAEHlpaHdvdGNkdzd2eW90cmYAsKHd/arJk3EDSFYGFnowsXzy5D4c/yhsnMXQjtG40xRIFtEtgiu4w6RmhfGby2Owo37X0I3qTUCsITmvZBI8WDPTSgyxePTGvimO9Ia1VoqG7dsBxLc3J4qLr2WndYRRmyNExMtJl37Bn6oLVsPRNGwrxmgJn9uXKX3nYz0IneyXfmM+NnYoY5XBApY7revRYrbKnMBBE3LZuxaTXFADpHtvwYQFm8haEeTfBucyXN8N";

  String token2 =
      "04AAAAAGPNelgAEHlpaHdvdGNkdzd2eW90cmYAsKHd/arJk3EDSFYGFnowsXzy5D4c/yhsnMXQjtG40xRIFtEtgiu4w6RmhfGby2Owo37X0I3qTUCsITmvZBI8WDPTSgyxePTGvimO9Ia1VoqG7dsBxLc3J4qLr2WndYRRmyNExMtJl37Bn6oLVsPRNGwrxmgJn9uXKX3nYz0IneyXfmM+NnYoY5XBApY7revRYrbKnMBBE3LZuxaTXFADpHtvwYQFm8haEeTfBucyXN8N";
  // For internal testing on web (No need to fill in this value, just ignore it).
  String tokenServer =
      "https://stream-git-main-wertyu1344.vercel.app/api/get_access_token?userID=flutter_user&expired_ts=999999999";
}
