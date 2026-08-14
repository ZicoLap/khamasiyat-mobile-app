import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Solid-color [ImageProvider] for widget tests / goldens (no PNG codec).
class SolidColorImageProvider extends ImageProvider<SolidColorImageProvider> {
  const SolidColorImageProvider(this.color, {this.dimension = 24});

  final Color color;
  final int dimension;

  @override
  Future<SolidColorImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    SolidColorImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, dimension.toDouble(), dimension.toDouble()),
      Paint()..color = color,
    );
    final image = recorder.endRecording().toImageSync(dimension, dimension);
    return OneFrameImageStreamCompleter(
      SynchronousFuture(ImageInfo(image: image, scale: 1)),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SolidColorImageProvider &&
        other.color == color &&
        other.dimension == dimension;
  }

  @override
  int get hashCode => Object.hash(color, dimension);
}
