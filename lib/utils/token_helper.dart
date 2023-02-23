import 'dart:convert';

import 'package:universal_io/io.dart';

import '../keycenter.dart';

class TokenHelper {
  static final TokenHelper instance = TokenHelper._internal();
  TokenHelper._internal();

  Future<String> getToken(String roomId) async {
    if (KeyCenter.instance.token.isNotEmpty) {
      return Future.value(KeyCenter.instance.token2);
    } else {
      if (KeyCenter.instance.tokenServer.isEmpty) {
        throw Exception(
            'You should fill in the "token" value in "keycenter.dart" file when running on web!');
      }
      print(
          "serverdan token alacm ${await _getTokenFromServer(KeyCenter.instance.appID, "flutter_user", roomId)}");
      return await _getTokenFromServer(
          KeyCenter.instance.appID, "flutter_user", roomId);
    }
  }

  Future<String> _getTokenFromServer(
      int appId, String userId, String roomId) async {
    Map params = {
      'appId': appId,
      'userId': userId,
      'idName': userId,
      'roomId': roomId,
      'version': '04',
      'privilege': {'1': 1, '2': 1},
      'expire_time': 7 * 24 * 60 * 60
    };

    String url = KeyCenter.instance.tokenServer;
    HttpClientRequest request = await HttpClient().getUrl(Uri.parse(url));
    //request.headers.set('content-type', 'application/json');
    //request.add(utf8.encode(json.encode(params)));

    HttpClientResponse response = await request.close();
    String result = '';
    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == HttpStatus.ok) {
      print("başarıyla aldım abii");
      result = jsonDecode(responseBody)['token'];
    }
    print(responseBody);

    print("token aldım token şu $result");
    return result;
  }
}
