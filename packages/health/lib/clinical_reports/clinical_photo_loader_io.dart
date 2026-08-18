import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> loadClinicalPhoto(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  } on Object {
    return null;
  }
}
