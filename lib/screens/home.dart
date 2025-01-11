import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MonitorWithAutomation.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  bool _canExit = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playAudio();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _playAudio() async {
    String audioPath = "assets/sound.mp3";
    await _audioPlayer.setAsset(audioPath);
    _audioPlayer.setLoopMode(LoopMode.one); // Set loop mode
    _audioPlayer.play();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Stop audio on dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_canExit) {
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          _canExit = true;
          Future.delayed(const Duration(seconds: 2), () {
            _canExit = false;
          });
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // Full-screen background image using Container

              Positioned.fill(
                top: -MediaQuery.of(context).size.height * 0.6,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/background.png'), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // First half
                  Expanded(
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Use Positioned.fill to ensure background image fills the container

                            // Positioned.fill(
                            //   top: -MediaQuery.of(context).size.height * 0.6,
                            //   child: SizedBox(
                            //     height: constraints.maxHeight * 0.79,
                            //     width: constraints.maxWidth,
                            //     child: Image.asset(
                            //       'assets/images/bg_left.png',
                            //       fit: BoxFit.cover,
                            //     ),
                            //   ),
                            // ),
                            // // Middle image positioned
                            Positioned(
                              top: constraints.maxHeight * 0.15,
                              left: -31,
                              child: SizedBox(
                                height: constraints.maxHeight * 0.83,
                                width: constraints.maxWidth,
                                child: Image.asset(
                                  'assets/images/Best Gamer Gear (6).png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Bottom image positioned
                            Positioned(
                              right: -43,
                              bottom: -32,
                              child: SizedBox(
                                width: constraints.maxWidth * 0.6,
                                height: constraints.maxHeight * 0.68,
                                child: Image.asset(
                                  'assets/images/gardro_device.png',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Second half
                  Expanded(
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Positioned.fill(
                            //   top: -MediaQuery.of(context).size.height * 0.6,
                            //   child: Image.asset(
                            //     'assets/images/bg_r.png',
                            //     fit: BoxFit.cover,
                            //   ),
                            // ),

                            // Column containing the text image and GameIdInput
                            Positioned.fill(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: constraints.maxWidth,
                                          height: constraints.maxWidth * 0.45,
                                          child: Image.asset(
                                            "assets/images/gardro_text.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                          constraints.maxHeight * 0.00001),
                                      child: GameIdInput(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameIdInput extends StatefulWidget {
  @override
  _GameIdInputState createState() => _GameIdInputState();
}

class _GameIdInputState extends State<GameIdInput> {
  TextEditingController _urlController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadLastEnteredText();
  }

  void _loadLastEnteredText() async {
    _prefs = await SharedPreferences.getInstance();
    String? lastText = _prefs.getString('lastEnteredText');
    if (lastText != null) {
      setState(() {
        _urlController.text = lastText;
      });
    }
  }

  void _saveLastEnteredText(String text) {
    _prefs.setString('lastEnteredText', text);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _urlController,
            onChanged: (text) {
              _saveLastEnteredText(text);
            },
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Enter IP Address',
              hintText: 'eg: 193.38.18',
              filled: true,
              labelStyle: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontFamily: 'VarelaRound',
              ),
              helperStyle: const TextStyle(
                color: Color.fromRGBO(200, 198, 188, 1),
              ),
              hintStyle: const TextStyle(
                color: Color.fromRGBO(200, 198, 188, 1),
              ),
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.videogame_asset,
                color: Color.fromRGBO(200, 198, 188, 1),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color.fromRGBO(200, 198, 188, 1),
                ),
                onPressed: () {
                  _urlController.clear();
                },
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(25.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            style: const TextStyle(
              color: Color.fromRGBO(200, 198, 188, 1),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .04266,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_urlController.text != "") {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MonitoringPageAutomate(
                        ipAddres: _urlController.text,
                      ), // Replace with your home screen widget
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromRGBO(200, 198, 188, 1),
                backgroundColor: Colors.grey[900],
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.height * .0175,
                ),
                child: const Text(
                  'Explore',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
