import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class IoUtils {
  static Future<Map<String, dynamic>?> importData(String filePath,
      {bool showDialog = false}) async {
    String? filename;

    if (showDialog) {
      filename = await showImportFileDialog(filePath);
      if (filename == null || filename.isEmpty) {
        debugPrint('filePath is empty');
        return Future.value(null);
      }
    } else {
      filename = filePath;
    }

    final File file = File(filename);
    String json = file.readAsStringSync();

    try {
      if (json.isNotEmpty) {
        Map<String, dynamic> map = jsonDecode(json);
        return Future.value(map);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return Future.value(null);
  }

// ---------------------------------------------------------
  // Imports
  // ---------------------------------------------------------
  static Future<String?> showImportFileDialog(String filePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      initialDirectory: filePath,
      // onFileLoading: (FilePickerStatus status) =>
      //     debugPrint('Pick status: $status'),
      allowedExtensions: ['json'],
    );

    if (result != null) {
      return result.paths[0];
    }

    return Future.value(null);
  }
}
