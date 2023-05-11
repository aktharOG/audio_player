import 'package:audio_demo/provider/audio_provider.dart';
import 'package:audio_demo/sharedPreference/shared_pref.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class DownloadPageDio extends StatefulWidget {
  const DownloadPageDio({super.key});

  @override
  State<DownloadPageDio> createState() => _DownloadPageDioState();
}

class _DownloadPageDioState extends State<DownloadPageDio> {
   //! fetchDownloadAudioFromDio
  fetchdata(context)async{
         final audioPro = Provider.of<AudioProvider>(context,listen: false);
         audioPro.downloadList = await getList();
          setState(() {
            
          });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       fetchdata(context);
      });
  }

  @override
  Widget build(BuildContext context) {
    final audioPro = Provider.of<AudioProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Download"),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Column(children: [
          ListView.builder(
            shrinkWrap: true,
            physics:const ScrollPhysics(),
            itemCount: audioPro.downloadList.length,
            itemBuilder: (context, index) {
              final data = audioPro.downloadList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${index+1}.  $data'),
              );
            },)
        ],),
      ),
    );
  }
}