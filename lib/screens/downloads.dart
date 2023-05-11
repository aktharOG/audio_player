import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_demo/widgets/audio_controlls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class DownloadsPage extends StatefulWidget {
   final AudioPlayer audioPlayer;
  const DownloadsPage({super.key,required this.audioPlayer});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {

    List<AudioSource> child = [];
  late final ConcatenatingAudioSource _playlist;

  List<DownloadTask> tasklist = [];
  List<Map> downloadsListMaps = [];
  ReceivePort _port = ReceivePort();

  void _bindBackgroundIsolate() {
   
    _port.listen((dynamic data) {
      log(data);
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      var task = downloadsListMaps.where((element) => element['id'] == id);
      task.forEach((element) {
        element['progress'] = progress;
        element['status'] = status;
        setState(() {});
        log((downloadsListMaps.toString()));
      });
    });
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port') as SendPort;
    send.send([id, status, progress]);
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _unbindBackgroundIsolate();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _bindBackgroundIsolate();
    loadtask();
     init();
   
  }

  loadtask() async {
    final tasks = await FlutterDownloader.loadTasks();
    tasklist = tasks!;
    tasklist.forEach((task) {
      Map map = Map();
      map['path'] = task.savedDir+task.filename!;
      map['status'] = task.status;
      map['progress'] = task.progress;
      map['id'] = task.taskId;
      map['filename'] = task.filename;
      map['savedDirectory'] = task.savedDir;
      map['url'] = task.url;
      downloadsListMaps.add(map);
      log("${task.savedDir}${task.filename!}");
    });
    child = downloadsListMaps
          .map((e) => AudioSource.uri(Uri.parse(e['path']),
              tag: MediaItem(
                  id: e['id'],
                  title: e['filename'],
                  artist: e['progress'].toString(),
                  
                  extras: {
                'audioUri': e['audio'],
                }
                  )))
          .toList();
    setState(() {});
    
    log(tasklist.length.toString());
  }
   bool isLoading = false;
  Future init() async {
    isLoading = true;
    setState(() {});
    setState(() {
      
    });

    _playlist = ConcatenatingAudioSource(children: child);
        isLoading = false;


    await widget.audioPlayer.setLoopMode(LoopMode.all);
    await widget.audioPlayer.setAudioSource(_playlist,initialIndex: 5);
    
    //   await _audioPlayer.setUrl(widget.url);
    setState(() {});
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloads"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: downloadsListMaps.length,
              itemBuilder: (context, index) {
                // final data = tasklist[index];
                // DownloadTaskStatus status = tasklist[index].status;
                Map _map = downloadsListMaps[index];
                String _filename = _map['filename'];
                int _progress = _map['progress'];
                DownloadTaskStatus _status = _map['status'];
                String _id = _map['id'];
                String _savedDirectory = _map['savedDirectory'];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(_filename),
                      subtitle: downloadStatusWidget(_status),
                      trailing: SizedBox(
                        child: buttons(_status, _id, index),
                      ),
                    ),
                    _status == DownloadTaskStatus.complete
                        ? Container()
                        : SizedBox(height: 5),
                    _status == DownloadTaskStatus.complete
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text('$_progress%'),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: _progress / 100,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 10)
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buttons(DownloadTaskStatus _status, String taskid, int index) {
    void changeTaskID(String taskid, String newTaskID) {
      Map task = downloadsListMaps.firstWhere(
        (element) => element['taskId'] == taskid,
        orElse: () => {},
      );
      task['taskId'] = newTaskID;
      setState(() {});
    }

    return _status == DownloadTaskStatus.canceled
        ? GestureDetector(
            child: Icon(Icons.cached, size: 20, color: Colors.green),
            onTap: () {
              FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
                changeTaskID(taskid, newTaskID!);
              });
            },
          )
        : _status == DownloadTaskStatus.failed
            ? GestureDetector(
                child: Icon(Icons.cached, size: 20, color: Colors.green),
                onTap: () {
                  FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
                    changeTaskID(taskid, newTaskID!);
                  });
                },
              )
            : _status == DownloadTaskStatus.paused
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        child: Icon(Icons.play_arrow,
                            size: 20, color: Colors.blue),
                        onTap: () {
                          FlutterDownloader.resume(taskId: taskid).then(
                            (newTaskID) => changeTaskID(taskid, newTaskID!),
                          );
                        },
                      ),
                      GestureDetector(
                        child: Icon(Icons.close, size: 20, color: Colors.red),
                        onTap: () {
                          FlutterDownloader.cancel(taskId: taskid);
                        },
                      )
                    ],
                  )
                : _status == DownloadTaskStatus.running
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            child: Icon(Icons.pause,
                                size: 20, color: Colors.green),
                            onTap: () {
                              FlutterDownloader.pause(taskId: taskid);
                              setState(() {});
                            },
                          ),
                          GestureDetector(
                            child:
                                Icon(Icons.close, size: 20, color: Colors.red),
                            onTap: () {
                              setState(() {});
                              FlutterDownloader.cancel(taskId: taskid);
                            },
                          )
                        ],
                      )
                    : _status == DownloadTaskStatus.complete
                        ? SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              GestureDetector(
                                  child:
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                  onTap: () {
                                    downloadsListMaps.removeAt(index);
                                    FlutterDownloader.remove(
                                        taskId: taskid, shouldDeleteContent: true);
                                   // loadtask();
                                    setState(() {});
                                  },
                                ),
                               StreamBuilder<PlayerState>(
          stream: widget.audioPlayer.playerStateStream,
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
                      onPressed: widget.audioPlayer.play,
                      icon: const Icon(Icons.play_arrow)),
                ),
              );
            } else if (proccessingState != ProcessingState.completed) {
              return CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Center(
                  child: IconButton(
                      onPressed: widget.audioPlayer.pause,
                      icon: const Icon(Icons.pause)),
                ),
              );
            }
            return const Icon(Icons.play_arrow_outlined);
          },
        ),
                            ],
                          ),
                        )
                        : Container();
  }
}

Widget downloadStatusWidget(DownloadTaskStatus _status) {
  return _status == DownloadTaskStatus.canceled
      ? Text("‘Download canceled’")
      : _status == DownloadTaskStatus.complete
          ? Text("‘Download completed’")
          : _status == DownloadTaskStatus.failed
              ? Text("‘Download failed’")
              : _status == DownloadTaskStatus.paused
                  ? Text("‘Download paused’")
                  : _status == DownloadTaskStatus.running
                      ? Text("‘Downloading..’")
                      : Text("‘Download waiting’");
}
