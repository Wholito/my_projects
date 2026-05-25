import 'package:flutter/foundation.dart';

bool get isGuessOnlyPlatform {
  if (kIsWeb) return true;
  return switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS =>
      true,
    _ => false,
  };
}
