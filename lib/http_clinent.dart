import 'package:dio/dio.dart';

final dio = Dio();
Future<Response?> post(String url, String sdp) async {
  try {
    var response = await dio.request(
      url,
      options:
          Options(method: "POST", headers: {'Content-Type': 'application/sdp'}),
      data: sdp,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    }
    return null;
  } catch (e) {}
  return null;
}
