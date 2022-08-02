part of 'dio_client.dart';

class Logging extends Interceptor {
  final log = getLogger('Response');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log.i('REQUEST[${options.method}] => PATH: ${options.uri}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log.i(
      '''RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path} => ${response.data}''',
    );
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    log.e(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    return super.onError(err, handler);
  }
}
