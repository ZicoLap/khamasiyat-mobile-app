import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tiny valid 1x1 PNG used to mock stadium photography in widget tests.
final Uint8List kMockStadiumPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0xD4, 0xEF, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest();

  @override
  bool autoUncompress = true;
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}
}

class _MockHttpHeaders extends Fake implements HttpHeaders {}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => kMockStadiumPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  Future<Socket> detachSocket() async => throw UnimplementedError();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([kMockStadiumPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void installMockStadiumImages() {
  debugNetworkImageHttpClientProvider = () => _MockHttpClient();
  PaintingBinding.instance.imageCache.clear();
}

void uninstallMockStadiumImages() {
  debugNetworkImageHttpClientProvider = null;
}
