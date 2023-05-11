import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:audio_demo/provider/audio_provider.dart';
import 'package:audio_demo/screens/audio_players.dart';
import 'package:audio_demo/screens/download_page2.dart';
import 'package:audio_demo/screens/downloads.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  bool isloading = false;
  List audiolist = [];
  final List<String> durations = [];

  //late AudioPlayer audioPlayer;
  //! playlist
  // final List<AudioSource> audiosouce = [];
  final AudioPlayer audioPlayer = AudioPlayer();

  var url = "https://my-node-server-akthar.onrender.com/api/booknest/audio";

  fetchAudio() async {
    isloading = true;
    final response = await http.get(Uri.parse(url), headers: {});
    print(response.body);

    audiolist = jsonDecode(response.body);
    isloading = false;
    setState(() {});
   // getDuration();
    //  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    // final List<SongInfo> songs = await audioQuery.getSongs();
    // final String durationInMilliseconds = songs[0].duration;

    return audiolist;
  }
//   Future<void> getAudioDuration(String url) async {

//   final duration = await audioPlayer.setUrl(url).then((_) => audioPlayer.duration);

//   print('Audio duration: ${duration?.inSeconds} seconds');

// }
// Future<void> getAudioDuration(String url) async {
//   final flutterSound = FlutterSound();

//   // open the audio file from its URL
//   final audioTrack = await flutterSound.thePlayer.getPlayerState().then((_) => flutterSound.thePlayer.startPlayer());

//   // get the duration of the audio file in milliseconds
//   final duration = await flutterSound.thePlayer.setSubscriptionDuration(audioTrack!);

//   print('Audio duration: ${duration.inSeconds} seconds');

//   // close the audio session
//   await flutterSound.stopPlayer();
//   await flutterSound.closeAudioSession();
// }

  getDuration() async {
    for (final url in audiolist) {
      final Completer<Duration> completer = Completer<Duration>();

      // Wait for the metadata to be loaded
      final durationSubscription =
          audioPlayer.onDurationChanged.listen((duration) {
        completer.complete(duration);

        // Unsubscribe from the duration subscription
        // durationSubscription.cancel();
      });
      await audioPlayer.setUrl(url['audio']);
      final Duration duration = await completer.future;
      final String durationString = duration.toString().split('.').first;
      if (durations.contains(durationString)) {
        log("exists");
      } else {
        durations.add(durationString);
        log(durations.length.toString());
        setState(() {});
      }

      durationSubscription.cancel();
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAudio();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await fetchAudio();
      },
      child:
      //  audiolist.length != durations.length
      //     ? const Scaffold(
      //         body: Center(
      //           child: CircularProgressIndicator(),
      //         ),
      //       )
      //     :
           isloading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "Sample Audios",
                      style: TextStyle(color: Colors.black),
                    ),
                    elevation: 0,
                    backgroundColor: const Color(0xffFFD654),
                    centerTitle: true,
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: audiolist.length,
                            // physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final audio = audiolist[index];
                              // getAudioDuration(audio['audio']);\
                             // final duration = durations[index];
                              return SubjectWithBookMark(
                                index: index,
                              //  duration: duration,
                                id: audio["id"].toString(),
                                name: audio["title"],
                                audio:audio['audio'],
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AudioPlayerPage(
                                          url: audio['audio'],
                                          title: audio['title'],
                                          image: audio['icon'],
                                          index: index,
                                        ),
                                      ));
                                },
                              );
                            }),
                      )
                    ],
                  ),
                  bottomNavigationBar: BottomAppBar(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DownloadPageDio(),
                                ));
                          },
                          child: Text("Downloads")),
                    ),
                  ),
                ),
    );
  }
}

class SubjectWithBookMark extends StatefulWidget {
  final String id, name,audio;
  final int index;
  void Function()? onTap;
  SubjectWithBookMark(
      {Key? key,
      this.onTap,
      required this.name,
      required this.id,
    //  required this.duration,
      required this.audio,
      required this.index
      })
      : super(key: key);

  @override
  State<SubjectWithBookMark> createState() => _SubjectWithBookMarkState();
}

class _SubjectWithBookMarkState extends State<SubjectWithBookMark> {
    int selectedIndex = 0;
     String durationString = "";
      final AudioPlayer audioPlayer = AudioPlayer();

      getDuration() async {
   
      final Completer<Duration> completer = Completer<Duration>();

      // Wait for the metadata to be loaded
      final durationSubscription =
          audioPlayer.onDurationChanged.listen((duration) {
        completer.complete(duration);

        // Unsubscribe from the duration subscription
        // durationSubscription.cancel();
      });
      await audioPlayer.setUrl(widget.audio);
      final Duration duration = await completer.future;
      durationString = duration.toString().split('.').first;
        log(durationString);
        setState(() {});
      

      durationSubscription.cancel();
      setState(() {});
    
  }
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.index;
    getDuration();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final audioPro = Provider.of<AudioProvider>(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 20, left: 20, top: 10),
        width: size.width,
        constraints: const BoxConstraints(minHeight: 70),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey[600]!),
          color: const Color(0xff616F83),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: .5,
              //blurStyle: BlurStyle.outer,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [
              0.0,
              0.6,
              0.9,
            ],
            tileMode: TileMode.clamp,
            colors: [
              Colors.white38,
              Colors.white24,
              Colors.white24,
            ],
          ),
        ),
        // color: Colors.white,
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${widget.id} ${widget.name}",
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                ?.copyWith(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(durationString),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.play_arrow)
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              audioPro.isDownloading
                  ?StreamBuilder<double>(
                      stream: audioPro.progressController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if(selectedIndex==widget.index){
                               return Column(
                            children: [
                              CircularProgressIndicator(value: snapshot.data,color: Colors.black,),
                           //   LinearProgressIndicator(value: snapshot.data),
                           //   Align(child: Text('${(snapshot.data! * 100).toStringAsFixed(0)}%'))
                            ],
                          );
                          }else{
                            return Container();
                          }
                         
                        } else {
                          return const LinearProgressIndicator();
                        }
                      },
                    )
                  : InkWell(
                      onTap: () {
                        audioPro.dioDownload(context, widget.name, widget.audio);
                      },
                      child: const Text(
                        "Download",
                        style: TextStyle(color: Colors.red),
                      ))
            ],
          ),
        ),
      ),
    );
  }
}
