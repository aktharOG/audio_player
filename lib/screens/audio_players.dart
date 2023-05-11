import 'dart:convert';

import 'package:audio_demo/screens/downloads.dart';
import 'package:audio_demo/widgets/audio_controlls.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class AudioPlayerPage extends StatefulWidget {
  final String url, title, image;
  final int index;
  const AudioPlayerPage(
      {Key? key,
      required this.url,
      required this.title,
      required this.image,
      required this.index})
      : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayerPage> {
  //! playlist
  List<AudioSource> child = [];

  // List audio = [
  //   'https://res.cloudinary.com/diqwddfh0/video/upload/v1681373416/nbw4qfvgauzgectaqywy.mp3',
  //   'https://res.cloudinary.com/diqwddfh0/video/upload/v1681373414/d03orrhjxhsrql6hbkha.mp3',
  //   'https://res.cloudinary.com/diqwddfh0/video/upload/v1681373412/vza3s4ocjzuvps4uz6ag.mp3',
  //   'https://res.cloudinary.com/diqwddfh0/video/upload/v1681373412/hbxvreg7ciwpyg7swgqk.mp3',
  //   'https://res.cloudinary.com/diqwddfh0/video/upload/v1681373410/iohhzqdugtuxkp7im6b2.mp3'
  // ];
  //! playlist
  List audiolist = [];
  late final ConcatenatingAudioSource _playlist;
  var url = "https://my-node-server-akthar.onrender.com/api/booknest/audio";

  fetchAudio() async {
    final response = await http.get(Uri.parse(url), headers: {});
    print(response.body);

    audiolist = jsonDecode(response.body);
    setState(() {
      child = audiolist
          .map((e) => AudioSource.uri(Uri.parse(e["audio"]),
              tag: MediaItem(
                  id: '0',
                  title: e['title'],
                  artist: e['category'],
                  artUri: Uri.parse(e['icon'],),
                  extras: {
                'audioUri': e['audio'],
                }
                  )))
          .toList();
    });
    return audiolist;
  }
  //!

  //!------------------------
  late AudioPlayer _audioPlayer;

  //! progress bar posion
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
          (position, bufferedPostion, duration) => PositionData(
              position, bufferedPostion, duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    init();
  }

  @override
  void dispose() {
        _audioPlayer.dispose();
    super.dispose();
  }

  bool isLoading = false;
  Future init() async {
    isLoading = true;
    setState(() {});
    await fetchAudio();

    _playlist = ConcatenatingAudioSource(children: child);
        isLoading = false;


    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setAudioSource(_playlist, initialIndex: widget.index);
    //   await _audioPlayer.setUrl(widget.url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.blue,
            appBar: AppBar(
              backgroundColor: Colors.amberAccent,
              actions: [
                IconButton(onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => DownloadsPage(audioPlayer: _audioPlayer,),));
                }, icon:const Icon(Icons.download))
              ],
            ),
            body: ListView(
              children: [
                StreamBuilder<SequenceState?>(
                    stream: _audioPlayer.sequenceStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      if (state?.sequence.isEmpty ?? true) {
                        return const SizedBox();
                      }
                      final metaData = state!.currentSource!.tag as MediaItem;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 25, right: 25, top: 10, bottom: 10),
                          height: size.height,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFD654),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 10.0, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.close))
                                  ],
                                ),
                              ),
                              StreamBuilder<SequenceState?>(
                                stream: _audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) {
                                  final state = snapshot.data;
                                  if (state?.sequence.isEmpty ?? true) {
                                    return const SizedBox();
                                  }
                                  final metaData =
                                      state!.currentSource!.tag as MediaItem;
                                  return MediaMetaData(
                                    audio: metaData.extras!['audioUri'],
                                      imageUrl: metaData.artUri.toString(),
                                      title: metaData.title,
                                      artist: metaData.artist ?? '');
                                },
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Column(
                                children: [
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Padding(
                                  //         padding: const EdgeInsets.only(
                                  //             left: 25.0, right: 25),
                                  //         child: Text(
                                  //           widget.title,
                                  //           style: Theme.of(context)
                                  //               .textTheme
                                  //               .headline4
                                  //               ?.copyWith(fontSize: 22),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Padding(
                                  //         padding:
                                  //             const EdgeInsets.only(left: 25.0),
                                  //         child: Text(
                                  //           "Chemistry | Chapter 1",
                                  //           style: Theme.of(context)
                                  //               .textTheme
                                  //               .headline6
                                  //               ?.copyWith(fontSize: 14),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     Padding(
                                  //       padding:
                                  //           const EdgeInsets.only(right: 25),
                                  //       child: InkWell(
                                  //           onTap: () {},
                                  //           child: Icon(Icons.bookmark)),
                                  //     ),
                                  //   ],
                                  // ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  StreamBuilder(
                                    stream: _positionDataStream,
                                    builder: (context, snapshot) {
                                      final positionData = snapshot.data;
                                      return ProgressBar(
                                        progress: positionData?.position ??
                                            Duration.zero,
                                        total: positionData?.duration ??
                                            Duration.zero,
                                        buffered:
                                            positionData?.bufferedPostion ??
                                                Duration.zero,
                                        onSeek: _audioPlayer.seek,
                                      );
                                    },
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 25, right: 25),
                                  //   child: ProgressIndicatorTime(
                                  //     minHeight: 7,
                                  //     color: Colors.black,
                                  //     fontSize: 13,
                                  //     backgroundColor: Colors.black26,
                                  //     space: 6,
                                  //   ),
                                  // ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      AudioControlls(audioPlayer: _audioPlayer),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.download),
                                        iconSize: 35,
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.skip_next),
                                        iconSize: 35,
                                      ),
                                      const CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 25,
                                        // child: Center(
                                        //   child: IconButton(
                                        //       onPressed: () {},
                                        //       icon: const Icon(Icons.pause)),
                                        // ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.ten_k),
                                        iconSize: 35,
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.play_arrow),
                                        iconSize: 35,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20.0,
                                            right: 20,
                                            top: 5,
                                          ),
                                          child: Text(
                                            "Description:  dataassasasasasasasaasa",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                ?.copyWith(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 15.0, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.share),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ],
            ),
          );
  }
}
