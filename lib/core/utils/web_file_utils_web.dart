import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

void downloadBytesOnWeb(List<int> bytes, String mimeType, String fileName) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

void downloadJsonOnWeb(String jsonString, String fileName) {
  downloadBytesOnWeb(utf8.encode(jsonString), 'application/json', fileName);
}

Future<PlatformFile?> pickExcelFileOnWeb() async {
  final input = html.FileUploadInputElement()
    ..accept = '.xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  input.click();

  await input.onChange.first;
  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) return null;

  final reader = html.FileReader();
  final completer = Completer<Uint8List>();

  reader.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(Exception('Failed to read file in browser'));
    }
  });

  reader.onLoadEnd.listen((_) {
    if (completer.isCompleted) return;
    final result = reader.result;
    if (result is ByteBuffer) {
      completer.complete(Uint8List.view(result));
    } else {
      completer.completeError(Exception('Unexpected browser file payload'));
    }
  });

  reader.readAsArrayBuffer(file);
  final bytes = await completer.future;

  return PlatformFile(name: file.name, size: bytes.length, bytes: bytes);
}
