import 'package:ai_radio/utils/utils.dart';
import 'package:alan_voice/alan_voice.dart';
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
  MyRadio? _selectedRadio;
  Color? _selectedColor;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setUpAlan();
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

  setUpAlan() {
    AlanVoice.addButton(
        "487066de63d893e1246ea64f97594c1f2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => handleCommand(command.data));
  }

  handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;
      default:
        break;
    }
  }

  void fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/files/radio.json");
    final decodedData = jsonDecode(radioJson);
    var radiosData = decodedData["radios"];
    radios = List.from(radiosData)
        .map<MyRadio>((item) => MyRadio.fromMap(item))
        .toList();
    _selectedRadio = radios[0];
    _selectedColor = Color(int.tryParse(_selectedRadio.color));
    setState(() {});
  }

  _playMusic(String url) {
    UrlSource urlSource = UrlSource(url);
    audioPlayer.play(urlSource);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: Stack(
        fit: StackFit.expand,
        // ignore: sort_child_properties_last
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor2,
                    _selectedColor ?? AIColors.primaryColor1,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          AppBar(
            title: "Radio".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ).h(100).p16(),
          // ignore: unnecessary_null_comparison
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1,
                  onPageChanged: (index) {
                    final colorHex = radios[index].color;
                    _selectedColor = Color(int.parse(colorHex));
                    setState(() {});
                  },
                  enlargeCenterPage: true,
                  itemBuilder: (context, index) {
                    final rad = radios[index];
                    return VxBox(
                            child: ZStack(
                      [
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
                              const Icon(
                                CupertinoIcons.play_circle,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "Double tap to play".text.gray300.make(),
                            ].vStack())
                      ],
                    ))
                        .clip(Clip.antiAlias)
                        .bgImage(
                          DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)),
                        )
                        .border(color: Colors.black, width: 2.0)
                        .withRounded(value: 0.0)
                        .make()
                        .onInkDoubleTap(() {
                      _playMusic(rad.url);
                    }).px1();
                  },
                ).centered()
              : const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
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
                size: 50.0,
              ).onInkTap(() {
                if (isPlaying) {
                  audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio.url);
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
