import 'dart:typed_data';

/// Stub implementation for platforms that don't support this functionality
Future<void> savePdfWeb(Uint8List bytes, String filename) async {
  throw UnsupportedError('PDF download is not supported on this platform');
}
