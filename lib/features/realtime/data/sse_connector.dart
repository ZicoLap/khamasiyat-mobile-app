import 'dart:async';

import 'package:dio/dio.dart';
import 'package:khamasiyat_mobile_app/features/realtime/data/sse_decoder.dart';
import 'package:khamasiyat_mobile_app/features/realtime/domain/realtime_models.dart';

abstract class SseConnector {
  Stream<SseEvent> connect({
    required String path,
    required Map<String, dynamic> queryParameters,
    required CancelToken cancelToken,
  });
}

class DioSseConnector implements SseConnector {
  DioSseConnector(this._dio);

  final Dio _dio;

  @override
  Stream<SseEvent> connect({
    required String path,
    required Map<String, dynamic> queryParameters,
    required CancelToken cancelToken,
  }) async* {
    final response = await _dio.get<ResponseBody>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: const {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },
      ),
    );
    final body = response.data;
    if (body == null) return;
    yield* _untilCancelled(decodeSseStream(body.stream), cancelToken);
  }
}

Stream<SseEvent> _untilCancelled(
  Stream<SseEvent> source,
  CancelToken cancelToken,
) {
  if (cancelToken.isCancelled) {
    return const Stream.empty();
  }
  final controller = StreamController<SseEvent>();
  late final StreamSubscription<SseEvent> sub;
  sub = source.listen(
    controller.add,
    onError: controller.addError,
    onDone: controller.close,
    cancelOnError: true,
  );
  cancelToken.whenCancel.then((_) async {
    await sub.cancel();
    if (!controller.isClosed) {
      await controller.close();
    }
  });
  controller.onCancel = () => sub.cancel();
  return controller.stream;
}
