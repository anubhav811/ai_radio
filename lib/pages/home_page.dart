import 'package:ai_radio/utils/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:ai_radio/model/radio.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State {
  List<MyRadio> radios = [];
  bool isPlaying = false;
  late MyRadio _selectedRadio;
  late Color _selectedColor;

  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        isPlaying = true;
      } else {
        isPlaying = false;
      }
      setState(() {});
    });
  }

  _playMusic(String url) {
    UrlSource urlSource = UrlSource(url);
    audioPlayer.play(urlSource);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    setState(() {});
  }

  void fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/files/radio.json");
    final decodedData = jsonDecode(radioJson);
    var radiosData = decodedData["radios"];
    radios = List.from(radiosData)
        .map<MyRadio>((item) => MyRadio.fromMap(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 18, 47, 61),
                    Color.fromARGB(255, 18, 47, 61)
                  ],
                  // begin: Alignment.topLeft,
                  // end: Alignment.bottomRight,
                ),
              )
              .make(),
          AppBar(
            title: "Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Color.fromARGB(255, 201, 201, 201),
                  secondaryColor: Vx.white,
                ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ).h(100).p16(),
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1,
                  enlargeCenterPage: true,
                  itemBuilder: (context, index) {
                    final rad = radios[index];
                    return VxBox(
                      child: ZStack([
                        Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: VxBox(
                            child: rad.category.text
                                .size(6)
                                .uppercase
                                .white
                                .make(),
                          )
                              .height(65)
                              .width(65)
                              .black
                              .alignCenter
                              .withRounded(value: 360)
                              .make(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VStack(
                            [
                              rad.name.text.xl3.white.bold.make(),
                              5.heightBox,
                              rad.tagline.text.sm.white.semiBold.make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: [
                            if (isPlaying)
                              "Playing Now - ${_selectedRadio.name} FM"
                                  .text
                                  .white
                                  .makeCentered(),
                            Icon(
                              isPlaying
                                  ? CupertinoIcons.stop_circle
                                  : CupertinoIcons.play_circle,
                              color: Colors.white,
                            ).onInkTap(() {
                              if (isPlaying) {
                                audioPlayer.stop();
                              } else {
                                _playMusic(rad.url);
                              }
                            }),
                            10.heightBox,
                            "Double tap to play".text.gray300.make(),
                          ].vStack(),
                        ),
                      ]),
                    )
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                          image: NetworkImage(rad.image),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3), BlendMode.darken),
                        ))
                        .border(color: Colors.black, width: 2.0)
                        .make()
                        .p12()
                        .onInkDoubleTap(() {
                      _playMusic(rad.url);
                    });
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ).centered(),
        ],
      ),
    );
  }
}
