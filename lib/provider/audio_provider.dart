import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_demo/sharedPreference/shared_pref.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AudioProvider extends ChangeNotifier {
  List<String> downloadList = [];
  bool isDownloading = false;
  dioDownload(context, name, url) async {
    isDownloading= true;
    notifyListeners();
    String filename = name; // file name that you desire to keep

    try {
      String savePath = await getFilePath(filename);
      var file = await Dio().download(url, savePath,
          onReceiveProgress: (received, total) {
            isDownloading =true; 
        if (total != -1) {
          log("${(received / total * 100).toStringAsFixed(0)}%");
                final double progress = received / total;

          progressController.add(progress);
          notifyListeners();
          //you can build progressbar feature too
          //   customSnackbar(context, "${(received / total * 100).toStringAsFixed(0)}%");
        }
      });
      log("File is saved to download folder.");

      log("download completed");
      isDownloading = false;
      downloadList.add(savePath);
      saveList(downloadList);
      notifyListeners();
      log(downloadList.length.toString());
      print(file.data);
      print(savePath);
    } on DioError catch (e) {
      print(e.message);
    }
  }

  //get file path
  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName.mp3';

    return path;
  }

  //streeaming
  final StreamController<double> progressController =
      StreamController<double>.broadcast();
}
