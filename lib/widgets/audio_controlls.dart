import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioControlls extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const AudioControlls({super.key, required this.audioPlayer});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              audioPlayer.setSpeed(1);
            },
            icon: Icon(Icons.arrow_back_ios_new_sharp)),
        IconButton(
            onPressed: audioPlayer.seekToPrevious,
            icon: Icon(Icons.skip_previous_rounded)),
        StreamBuilder<PlayerState>(
          stream: audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            log((snapshot.data.toString()));

            final playerState = snapshot.data;
            final proccessingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (!(playing ?? false)) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Center(
                  child: IconButton(
                      onPressed: audioPlayer.play,
                      icon: const Icon(Icons.play_arrow)),
                ),
              );
            } else if (proccessingState != ProcessingState.completed) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Center(
                  child: IconButton(
                      onPressed: audioPlayer.pause,
                      icon: const Icon(Icons.pause)),
                ),
              );
            }
            return const Icon(Icons.play_arrow_outlined);
          },
        ),
        IconButton(
            onPressed: audioPlayer.seekToNext,
            icon: Icon(Icons.skip_next_rounded)),
        IconButton(
            onPressed: () {
              audioPlayer.setSpeed(1.5);
            },
            icon: Icon(Icons.arrow_forward_ios))
      ],
    );
  }
}

// for progress bar
class PositionData {
  final Duration position;
  final Duration bufferedPostion;
  final Duration duration;

  PositionData(this.position, this.bufferedPostion, this.duration);
}

//! playlist

class MediaMetaData extends StatefulWidget {
  const MediaMetaData(
      {Key? key,
      required this.imageUrl,
      required this.title,
      required this.artist,
      required this.audio})
      : super(key: key);
  final String imageUrl;
  final String title;
  final String artist;
  final String audio;

  @override
  State<MediaMetaData> createState() => _MediaMetaDataState();
}

class _MediaMetaDataState extends State<MediaMetaData> {
   ReceivePort _port = ReceivePort();
   
//     void _bindBackgroundIsolate() {
// bool isSuccess = IsolateNameServer.registerPortWithName(
// _port.sendPort, 'downloader_send_port');
// if (!isSuccess) {
// _unbindBackgroundIsolate();
// _bindBackgroundIsolate();
// return;
// }
// _port.listen((dynamic data) {
// String id = data[0];
// DownloadTaskStatus status = data[1];
// int progress = data[2];
// var task = downloadsListMaps?.where((element) => element['id'] == id);
// task.forEach((element) {
// element['progress'] = progress;
// element['status'] = status;
// setState(() {});
// });
// });
// }
// static void downloadCallback(
// String id, DownloadTaskStatus status, int progress) {
// final SendPort send =
// IsolateNameServer.lookupPortByName('downloader_send_port') as SendPort;
// send.send([id, status, progress]);
// }
// void _unbindBackgroundIsolate() {
// IsolateNameServer.removePortNameMapping('downloader_send_port');
// }

    
  void bindgroundIsolate(){
     bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      bindgroundIsolate();
      return;
    }
  }
   void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   bindgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
   // IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port') as SendPort;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, offset: Offset(2, 4), blurRadius: 4),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          widget.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          widget.artist,
          textAlign: TextAlign.center,
        ),
        InkWell(
            onTap: () async {
              final directory = await getApplicationSupportDirectory();
             // File file2 = File(directory.path);
              // if (!await Directory(file2.path).exists()) {
              //   await Directory(file2.path).create(recursive: true);
              // }
              final taskId = await FlutterDownloader.enqueue(
                url: widget.audio,
                headers: {}, // optional: header send with url (auth token etc)
                savedDir: directory.path,
                showNotification:
                    true, // show download progress in status bar (for Android)
                openFileFromNotification:
                    true, // click on notification to open downloaded file (for Android)
                     saveInPublicStorage: true 
              );
          
              await FlutterDownloader.registerCallback(downloadCallback);
              bindgroundIsolate();
            },
            child: const Icon(Icons.download))
      ],
    );
  }
}
