import 'dart:async';
import 'dart:math';
import 'Loader.dart';
import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());
enum PlayerState { stopped, playing, paused }

Color subColor = Colors.pink;
Color themeColor = Colors.black87;
int a = 0;
Duration leftOver = new Duration(seconds: 0);
Duration seek = new Duration(seconds: 5);
List<Song> _songs;
List<Song> _recent;
List<Song> _temp;
double opacityLevel = 1.0;
int indx;
TimeOfDay temp;
TimeOfDay _time = new TimeOfDay.now();
bool _sleepTimer = false;
Duration duration;
Duration position;
MusicFinder audioPlayer;
bool _isPlaying = false;
bool _isShuffle;
bool _isLoop;
bool _firstTap = false;
String elapsed = "0:00";
String total = "0:00";
double radius=50;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
        theme: new ThemeData(
          fontFamily: 'Shadows',
          //  primarySwatch: subColor,
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: <String, WidgetBuilder>{
          "/player": (BuildContext context) => Player(),
          "/list": (BuildContext context) => MyHomePage(),
          '/sleeptimer': (BuildContext context) => SleepTimer(),
        });
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  Animation<double> animation_radius_in;
    double initialRad=50;

  navigate() {
    Navigator.of(context).pushReplacementNamed('/list');
  }

  initPlayer() async {
    audioPlayer = new MusicFinder();
    var songs;
    try {
      songs = await MusicFinder.allSongs();
    } catch (e) {
      print("Failed to get songs: '${e.message}'.");
    }

    setState(() {
      _songs = songs;
    });
  }

  @override
  Future initState() {
    super.initState();
    initPlayer();
    controller = new AnimationController(
        vsync: this, duration: new Duration(seconds: 4));
    animation_radius_in = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.5, 1.0, curve: Curves.elasticIn)));

    controller.addListener((){
      setState(() {
        if (controller.value >= 0.5 && controller.value <= 1.0){
          radius=animation_radius_in.value*initialRad;
        }
      });
    });
    controller.repeat();
   new Timer(new Duration(milliseconds: 4000), navigate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: themeColor,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'Music Player',
            style: new TextStyle(
              fontFamily: 'Amatic',
              fontSize: 35,
              letterSpacing: 3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      body: new Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/images/B2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: new Column(
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Container(
                  height: 350,
                 // height: 250,
                 // width: 250,
                  child: Container(
                    height: radius*5,
                    width: radius*5,
                    child: new RawMaterialButton(
                      onPressed: null,
                      shape: CircleBorder(),
                      fillColor: themeColor.withOpacity(0.6),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: ClipOval(
                          clipper: CircleClipper(),
                          child: Image(
                            image: new AssetImage('assets/images/Solid.jpg'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              new Expanded(child: new Container()),
              new CircularProgressIndicator(
                backgroundColor: Colors.grey,
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(subColor),
              ),
              new Expanded(child: new Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future selectNotification(String payload) {
    flutterLocalNotificationsPlugin.cancel(0);
  }

  @override
  Future initState() {
    super.initState();
    _recent = [];
    _temp = [];

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: selectNotification);

    WidgetsBinding.instance.addObserver(this);
    initPlayer();
  }

  titleNoti() {
    if (_isPlaying) {
      return _songs[indx].title;
    } else {
      return "Music Player";
    }
  }

  textNoti() {
    if (_isPlaying) {
      return _songs[indx].artist;
    } else {
      return "Tap to go to Player";
    }
  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription');
    var ios = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, ios);
    await flutterLocalNotificationsPlugin.show(
        0, titleNoti(), textNoti(), platform);
  }

  void initPlayer() async {
    /*   audioPlayer = new MusicFinder();
    var songs;
    try {
      songs = await MusicFinder.allSongs();
    } catch (e) {
      print("Failed to get songs: '${e.message}'.");
    }

    setState(() {
      _songs = songs;
    });
*/
    audioPlayer.setDurationHandler((d) => setState(() {
          duration = d;
        }));
    audioPlayer.setPositionHandler((p) => setState(() {
          position = p;
        }));
    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });
    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
    //  setState(() {
    //    print(songs.toString());
    //   });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('paused state');
        showNotification();
        break;
      case AppLifecycleState.resumed:
        print('resumed state');
        selectNotification("Random");
        break;
      case AppLifecycleState.inactive:
        print('inactive state');
        break;
      case AppLifecycleState.suspending:
        print('suspending state');
        selectNotification("Random");
        break;
    }
  }

  Future _playLocal(String url, int index) async {
    _isShuffle = false;
    _isLoop = false;
    _firstTap = true;
    indx = index;
    if (playerState == PlayerState.playing) {
      stop();
    }
    final result = await audioPlayer.play(url, isLocal: true);
    if (result == 1)
      setState(() {
        playerState = PlayerState.playing;
      });
    _isPlaying = true;
    if (_temp.contains(_songs[index])) {
      _temp.remove(_songs[index]);
    }
    _temp.add(_songs[index]);
    _recent = reverseList(_temp);
    setState(() {});
  }

  List<Song> reverseList(List<Song> a) {
    List<Song> temp = new List<Song>(a.length);
    for (int i = 0; i < a.length; i++) {
      temp[i] = a[a.length - i - 1];
    }
    return temp;
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
    _isPlaying = false;
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
    _isPlaying = false;
  }

  void onComplete() {
    if (_isLoop) {
      indx = indx;
      _playLocal(_songs[indx].uri, indx);
      //audioPlayer.play(_songs[indx].uri, isLocal: true);
      _isLoop = true;
    } else if (_isShuffle) {
      indx = new Random().nextInt(_songs.length);
      _playLocal(_songs[indx].uri, indx);
      //audioPlayer.play(_songs[indx].uri, isLocal: true);
      _isShuffle = true;
    } else {
      audioPlayer.pause();
      if (indx != _songs.length - 1) {
        audioPlayer.pause();
        indx++;
        //audioPlayer.play(_songs[indx].uri, isLocal: true);
        _playLocal(_songs[indx].uri, indx);
      } else {
        indx = 0;
      }
      _playLocal(_songs[indx].uri, indx);
    }
  }

  String roundedTextTitle(int index,List<Song> _list) {
    String s = _list[index].title;
    if (s.length > 25) {
      String s1 = s.substring(0, 20) + "...";
      return s1;
    } else {
      return s;
    }
  }


  String roundedTextArtist(int index,List<Song> _list) {
    String s = _list[index].artist;
    if (s.length > 25) {
      String s1 = s.substring(0, 20) + "...";
      return s1;
    } else {
      return s;
    }
  }

  navigate() {
    Navigator.of(context).pushNamed("/player");
  }

  widgetBuild() {
    if (_firstTap) {
      return new Container(
        width: double.infinity,
        child: new GestureDetector(
          //    onVerticalDragStart: onVerticalDragEnd(),
          onTap: navigate,
          child: BottomNavigationControlBar(),
        ),
      );
    }
  }

  String totalLength(int index) {
    return new Duration(milliseconds: _songs[index].duration)
        .toString()
        .substring(2, 7);
  }

  String totalLengthr(int index) {
    return new Duration(milliseconds: _recent[index].duration)
        .toString()
        .substring(2, 7);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer.stop();
  }

  push() {
    Navigator.of(context).pushNamed("/settings");
  }

  smartColor(int index) {
    if (index == indx) {
      return themeColor.withOpacity(0.7);
    }
  }

  Widget fav() {
    if (_recent != null) {
      return new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/images/B2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: new ListView.builder(
          itemCount: _recent.length,
          itemBuilder: (context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Container(
                color: smartColor(index),
                child: new ListTile(
                  leading: new ClipOval(
                    child: new Image(
                      image: new AssetImage('assets/images/AlbumArt.jpg'),
                      height: 45,
                      width: 45,
                    ),
                  ),
                  title: Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Text(
                            roundedTextTitle(index,_recent),
                            style: new TextStyle(
                                //color: Colors.white.withOpacity(0.8),
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                          new Expanded(child: new Container()),
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text(
                           roundedTextArtist(index, _recent),
                            style: new TextStyle(
                              //color: Colors.white.withOpacity(0.8),
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                          new Expanded(child: new Container()),
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text(
                            totalLengthr(index),
                            style: new TextStyle(
                              //color: Colors.white.withOpacity(0.8),
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                          new Expanded(child: new Container()),
                        ],
                      ),
                    ],
                  ),
                  //onTap: () => _playLocal(_songs[index].uri, index),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return new Container();
    }
  }

  static const String sleeptimer = "Sleep Timer";
  static const String themecolor = "Theme Color";
  static const String subcolor = "Sub Color";

  List<String> choices = <String>[
    sleeptimer,
    themecolor,
    subcolor,
  ];

  changeSimpleColor(Color color) => setState(() => themeColor = color);

  changeSimpleColor1(Color color) => setState(() => subColor = color);

  onSelected(String choice) {
    if (choice == 'Sleep Timer') {
      Navigator.of(context).pushNamed('/sleeptimer');
    } else if (choice == 'Theme Color') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: themeColor,
                onColorChanged: changeSimpleColor,
                colorPickerWidth: 1000.0,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: true,
              ),
            ),
          );
        },
      );
    } else if (choice == 'Sub Color') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: subColor,
                onColorChanged: changeSimpleColor1,
                colorPickerWidth: 1000.0,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: true,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: new Container(),
          backgroundColor: themeColor,
          actions: <Widget>[
            // new IconButton(icon: new Icon(Icons.settings), onPressed: push),
            new PopupMenuButton(
              onSelected: onSelected,
              itemBuilder: (BuildContext context) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
          bottom: TabBar(
            labelStyle: new TextStyle(
              fontSize: 22,
              fontFamily: 'Amatic',
            ),
            indicatorColor: subColor,
            tabs: [
              Tab(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: new Text('songs'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: new Text("Recently Played"),
                ),
              ),

              //Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Center(
              child: Text(
                'Music Player',
                style: new TextStyle(
                  fontFamily: 'Amatic',
                  fontSize: 35,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('assets/images/B2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                child: new ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Container(
                        color: smartColor(index),
                        child: new ListTile(
                          leading: new ClipOval(
                            child: new Image(
                              image:
                                  new AssetImage('assets/images/AlbumArt.jpg'),
                              height: 45,
                              width: 45,
                            ),
                          ),
                          title: Column(
                            children: <Widget>[
                              new Row(
                                children: <Widget>[
                                  new Text(
                                    roundedTextTitle(index,_songs),
                                    style: new TextStyle(
                                      //color: Colors.white.withOpacity(0.8),
                                      color: Colors.white,
                                      fontSize: 16,
                                      letterSpacing: 2,
                                      //         fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  new Expanded(child: new Container()),
                                ],
                              ),
                              new Row(
                                children: <Widget>[
                                  new Text(
                                    roundedTextArtist(index, _songs),
                                    style: new TextStyle(
                                      //color: Colors.white.withOpacity(0.8),
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  new Expanded(child: new Container()),
                                ],
                              ),
                              new Row(
                                children: <Widget>[
                                  new Text(
                                    totalLength(index),
                                    style: new TextStyle(
                                      //color: Colors.white.withOpacity(0.8),
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  new Expanded(child: new Container()),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _playLocal(_songs[index].uri, index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            fav(),
            // Icon(Icons.directions_bike),
          ],
        ),
        bottomNavigationBar: widgetBuild(),
      ),
    );
  }
}

class SleepTimer extends StatefulWidget {
  @override
  _SleepTimerState createState() => _SleepTimerState();
}

class _SleepTimerState extends State<SleepTimer> {
  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
      _sleepTimer = true;
    }
    temp = new TimeOfDay.now();
    code();
  }

  timerMethod() {
    new Timer(new Duration(seconds: 1), stop);
  }

  code() {
    timerMethod();
  }

  Future stop() async {
    temp = new TimeOfDay.now();

    if (_sleepTimer = true) {
      if (_time == temp) {
        audioPlayer.stop();
        setState(() {
          _isPlaying = false;
          _sleepTimer = false;
        });
      }
      else{
        timerMethod();
      }
    }
  }

  onChanged(value) {
    if (_sleepTimer) {
      setState(() {
        _sleepTimer = false;
      });
    } else {
      setState(() {
        _sleepTimer = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: themeColor,
        title: new Text("Sleep Timer"),
        actions: <Widget>[
          new Switch(
            value: _sleepTimer,
            onChanged: onChanged,
            activeColor: subColor,
          ),
        ],
      ),
      body: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            fit: BoxFit.fill,
            image: new AssetImage('assets/images/B2.jpg'),
          ),
        ),
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 13),
              child: new ListTile(
                onTap: () {
                  _selectTime(context);
                },
                title: new Text(
                  "Use DatePicker",
                  style: new TextStyle(
                    fontSize: 22,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: new ListTile(
                title: new Text(
                  "Time from now",
                  style: new TextStyle(
                    fontSize: 22,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BottomNavigationControlBar extends StatefulWidget {
  @override
  BottomNavigationControlBarState createState() {
    return new BottomNavigationControlBarState();
  }
}

class BottomNavigationControlBarState
    extends State<BottomNavigationControlBar> {
  Stopwatch sp = new Stopwatch();
  Duration temp = new Duration(seconds: 0);

  Icon iconPlay = new Icon(
    Icons.pause,
    size: 35,
  );

  playPause() {
    if (_isPlaying) {
      audioPlayer.pause();
      _isPlaying = false;
    } else {
      audioPlayer.play(_songs[indx].uri);
      _isPlaying = true;
    }
    iconUrl();
  }

  iconUrl() {
    if (_isPlaying) {
      setState(() {
        iconPlay = new Icon(Icons.pause, size: 33);
      });
    } else {
      setState(() {
        iconPlay = new Icon(
          Icons.play_arrow,
          size: 33,
        );
      });
    }
  }

  iconColorShuffle() {
    if (_isShuffle) {
      return Colors.white;
    } else {
      return Colors.white.withOpacity(0.5);
    }
  }

  iconColorLoop() {
    if (_isLoop) {
      return Colors.white;
    } else {
      return Colors.white.withOpacity(0.5);
    }
  }

  seekBack() {
    if (position.inSeconds != 0) {
      audioPlayer.stop();
      audioPlayer.play(_songs[indx].uri);
    } else {
      audioPlayer.stop();
      indx--;
      _temp.add(_songs[indx]);
      _recent = _temp;
      audioPlayer.play(_songs[indx].uri);
    }
  }

  seekForward() {
    audioPlayer.stop();
    indx++;
    audioPlayer.play(_songs[indx].uri);

    _temp.add(_songs[indx]);
    _recent = _temp;
  }

  shuffle() {
    if (_isShuffle) {
      _isShuffle = false;
    } else {
      _isShuffle = true;
    }
  }

  loop() {
    if (_isLoop) {
      _isLoop = false;
    } else {
      _isLoop = true;
    }
  }

  playerWindow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Player()),
    );
  }

  String roundedText(int index) {
    String s = _songs[index].title;
    if (s.length > 25) {
      String s1 = s.substring(0, 20) + "...";
      return s1;
    } else {
      return s;
    }
  }

  String roundedTextr(int index) {
    String s = _songs[index].title;
    if (s.length > 25) {
      String s1 = s.substring(0, 20) + "...";
      return s1;
    } else {
      return s;
    }
  }

  Duration temp1;

  onChange(double value) {
    audioPlayer.pause();
    position = new Duration(seconds: value.toInt());
  }

  onChangeEnd(double value) {
    position = new Duration(seconds: value.toInt());
    temp1 = new Duration(seconds: value.toInt());
    _isPlaying = true;
    iconUrl();
    audioPlayer.play(_songs[indx].uri);
    audioPlayer.seek(temp1.inSeconds.toDouble());
  }

  timeTotal() {
    if (duration.inHours == 0) {
      String c = duration.toString().substring(2, 7);
      return c;
    } else {
     String c = duration.toString().substring(0, 7);
      return c;
    }
  }

  getPosition() {
    if (position == null) {
      return 0;
    } else {
      return position.inSeconds.toDouble();
    }
  }

  getDuration() {
    if (duration == null) {
      return double.infinity;
    } else {
      return duration.inSeconds.toDouble();
    }
  }

  @override
  void initState() {
    super.initState();
    timeTotal();
    timeElapsed();
    iconUrl();
    new Timer(new Duration(seconds: 1), timeElapsed);
  }

  timeElapsed() {
//    if (position.inHours == 0) {
    setState(() {
      elapsed = position.toString().substring(2, 7);
    });
    //  }
    //  else {
    //    setState(() {
    //      elapsed = position.toString().substring(0, 7);
    //     });
    // }
    new Timer(new Duration(milliseconds: 1), timeElapsed);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 130,
      width: double.maxFinite,
      color: Colors.transparent,
      child: Material(
        color: themeColor,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.only(top: 1, bottom: 0, left: 15),
          child: new GestureDetector(
            onTap: null,
            child: Column(
              children: <Widget>[
                /* new Slider(
                  value: getPosition(),
                  onChanged: onChange,
                  activeColor: Colors.pink,
                  inactiveColor: Colors.pink.withOpacity(0.15),
                  max: getDuration(),
                  onChangeEnd: onChangeEnd,
                  onChangeStart: onChangeStart,
                ),*/
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        child: new Text(
                          elapsed,
                          style: new TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        width: 40,
                      ),
                      Container(
                        width: 310,
                        child: new Slider(
                          value: position.inSeconds.toDouble(),
                          onChanged: onChange,
                          activeColor: subColor,
                          inactiveColor: subColor.withOpacity(0.15),
                          max: getDuration(),
                          onChangeEnd: onChangeEnd,
                        ),
                      ),
                      new Container(
                        child: new Text(
                          timeTotal(),
                          style: new TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: new CircleAvatar(
                        child: ClipOval(
                          clipper: CircleClipper(),
                          child: new Image(
                            image: new AssetImage('assets/images/AlbumArt.jpg'),
                          ),
                        ),
                        radius: 23,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: new RichText(
                          text: new TextSpan(text: '', children: [
                        new TextSpan(
                            text: (roundedText(indx) + '\n'),
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Amatic',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              //4
                              height: 1.3,
                            )),
                        new TextSpan(
                            text: _songs[indx].artist + '\n',
                            style: new TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 24,
                              fontFamily: 'Amatic',
                              letterSpacing: 2,
                              //4
                              height: 1.3,
                            )),
                      ])),
                    ),
                    new Expanded(child: new Container()),
                    new RawMaterialButton(
                      onPressed: playPause,
                      shape: new CircleBorder(),
                      fillColor: Colors.white,
                      splashColor: subColor,
                      elevation: 10,
                      highlightElevation: 5,
                      child: new Padding(
                        padding: const EdgeInsets.all(8),
                        child: iconPlay,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Player extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Player",
      debugShowCheckedModeBanner: false,
      home: MyHomePage1(),
    );
  }
}

class MyHomePage1 extends StatefulWidget {
  @override
  _MyHomePage1State createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  timeElapsed() {
  //  if (position.inHours == 0) {
      String c = position.toString().substring(2, 7);
      return c;
  //  } else {
  //    String c = position.toString().substring(0, 7);
  //    return c;
  //  }
  }

  String url() {
    return "assets/images/AlbumArt.jpg";
  }

  @override
  Widget build(BuildContext context) {
    Widget home() {
      return new Scaffold(
        body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/B2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: new Column(
            children: <Widget>[
              //seekbar
              new Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: new Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: new Container(
                            height: 160,
                            width: 160,
                            child: new ClipOval(
                              clipper: CircleClipper(),
                              child: GestureDetector(
                                child: new Image(
                                  image: new AssetImage(
                                    url(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(child: Loader()),
                      ],
                    ),
                  ),
                ),
              ),
              new BottomControls(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: home(),
    );
  }
}

class BottomControls extends StatefulWidget {
  @override
  BottomControlsState createState() {
    return new BottomControlsState();
  }
}

class BottomControlsState extends State<BottomControls> {
  Icon iconPlay = new Icon(
    Icons.pause,
    size: 45,
  );

  playPause() {
    if (_isPlaying) {
      audioPlayer.pause();
      _isPlaying = false;
    } else {
      audioPlayer.play(_songs[indx].uri);
      _isPlaying = true;
    }
    iconUrl();
  }

  iconUrl() {
    if (_isPlaying) {
      setState(() {
        iconPlay = new Icon(Icons.pause, size: 45);
      });
    } else {
      setState(() {
        iconPlay = new Icon(
          Icons.play_arrow,
          size: 45,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    timeTotal();
    timeElapsed();
    iconUrl();
    new Timer(new Duration(seconds: 1), timeElapsed);
  }

  timeElapsed() {
   // if (position.inHours == 0) {
      setState(() {
        elapsed = position.toString().substring(2, 7);
      });
 //   } else {
  //    setState(() {
 //       elapsed = position.toString().substring(0, 7);
  //    });
   // }
    new Timer(new Duration(milliseconds: 1), timeElapsed);
  }

  Color shuffleColor = Colors.white.withOpacity(0.5);

  iconColorShuffle() {
    if (_isShuffle) {
      setState(() {
        shuffleColor = Colors.white;
      });
    } else {
      setState(() {
        shuffleColor = Colors.white.withOpacity(0.5);
      });
    }
  }

  Color loopColor = Colors.white.withOpacity(0.5);

  iconColorLoop() {
    if (_isLoop) {
      setState(() {
        loopColor = Colors.white;
      });
    } else {
      setState(() {
        loopColor = Colors.white.withOpacity(0.5);
      });
    }
  }

  seekBack() {
    if (position >= new Duration(seconds: 1)) {
      audioPlayer.stop();
      audioPlayer.play(_songs[indx].uri);
    } else {
      audioPlayer.stop();
      indx--;
      recall();
      audioPlayer.play(_songs[indx].uri);

      _temp.add(_songs[indx]);
      _recent = _temp;
      _isPlaying = true;
      recall();
    }
  }

  seekForward() {
    audioPlayer.stop();
    indx++;
    audioPlayer.play(_songs[indx].uri);

    _temp.add(_songs[indx]);
    _recent = _temp;
    _isPlaying = true;
    recall();
  }

  shuffle() {
    if (_isShuffle) {
      _isShuffle = false;
    } else {
      _isShuffle = true;
    }
    iconColorShuffle();
  }

  loop() {
    if (_isLoop) {
      _isLoop = false;
    } else {
      _isLoop = true;
    }
    iconColorLoop();
  }

  String roundedText(int index) {
    String s = _songs[index].title;
    if (s.length > 35) {
      String s1 = s.substring(0, 25) + "...";
      return s1;
    } else {
      return s;
    }
  }

  Duration temp1;

  onChange(double value) {
    audioPlayer.pause();
    position = new Duration(seconds: value.toInt());
  }

  onChangeEnd(double value) {
    position = new Duration(seconds: value.toInt());
    temp1 = new Duration(seconds: value.toInt());
    _isPlaying = true;
    iconUrl();
    audioPlayer.play(_songs[indx].uri);
    audioPlayer.seek(temp1.inSeconds.toDouble());
  }

  timeTotal() {
    if (duration.inHours == 0) {
      setState(() {
        total = duration.toString().substring(2, 7);
      });
    } else {
    setState(() {
        total = duration.toString().substring(0, 7);
      });
    }
  }

  double pos = 0;

  getDuration() {
    if (duration == null) {
      return double.infinity;
    } else {
      return duration.inSeconds.toDouble();
    }
  }

  recall() {
    getDuration();
    // getPosition();
    timeElapsed();
    timeTotal();
    iconUrl();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 290,
      width: double.maxFinite,
      child: Material(
        color: themeColor.withOpacity(0.7),
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 20),
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 13, bottom: 20),
                child: new Row(
                  children: <Widget>[
                    new Container(
                      width: 42,
                      child: new Text(
                        elapsed,
                        style: new TextStyle(
                          fontSize: 16,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Amatic',
                        ),
                      ),
                    ),
                    new Container(
                      width: 310,
                      child: new Slider(
                        value: position.inSeconds.toDouble(),
                        onChanged: onChange,
                        activeColor: subColor,
                        inactiveColor: subColor.withOpacity(0.15),
                        max: getDuration(),
                        onChangeEnd: onChangeEnd,
                      ),
                    ),
                    new Container(
                      child: new Text(
                        total,
                        style: new TextStyle(
                          fontSize: 16,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amatic',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 7),
                child: new RichText(
                    text: new TextSpan(text: '', children: [
                  new TextSpan(
                      text: (roundedText(indx) + '\n'),
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 28,

                        fontFamily: 'Amatic',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        //4
                        height: 1.3,
                      )),
                  new TextSpan(
                      text: _songs[indx].artist + '\n',
                      style: new TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 28,
                        fontFamily: 'Amatic',
                        letterSpacing: 3,
                        //4
                        height: 1.3,
                      )),
                ])),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: new Row(
                  children: <Widget>[
                    new Expanded(child: new Container()),
                    new IconButton(
                      icon: new Icon(
                        Icons.shuffle,
                        size: 25,
                      ),
                      onPressed: shuffle,
                      color: shuffleColor,
                    ),
                    new Expanded(child: new Container()),
                    new IconButton(
                      iconSize: 40,
                      splashColor: subColor,
                      highlightColor: Colors.transparent,
                      icon: new Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                      onPressed: seekBack,
                    ),
                    /* new Container(
                        child: new CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            child: new GestureDetector(
                              child: new Icon(
                                Icons.skip_previous,
                                size: 40,
                                color: Colors.white,
                              ),
                              onLongPress:null,
                              onTap: null,
                            )),
                      ),*/
                    new Expanded(child: new Container()),
                    new RawMaterialButton(
                      onPressed: playPause,
                      shape: new CircleBorder(),
                      fillColor: Colors.white,
                      splashColor: subColor,
                      // highlightColor: Colors.green.withOpacity(0.5),
                      elevation: 10,
                      highlightElevation: 5,
                      child: new Padding(
                        padding: const EdgeInsets.all(8),
                        child: iconPlay,
                      ),
                    ),
                    new Expanded(child: new Container()),
                    new IconButton(
                      iconSize: 40,
                      splashColor: subColor,
                      highlightColor: Colors.transparent,
                      icon: new Icon(
                        Icons.skip_next,
                        color: Colors.white,
                      ),
                      onPressed: seekForward,
                    ),
                    new Expanded(child: new Container()),
                    new IconButton(
                      icon: new Icon(
                        Icons.repeat,
                        size: 25,
                      ),
                      onPressed: loop,
                      color: loopColor,
                    ),
                    new Expanded(child: new Container()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: new Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class CircleClipper1 extends CustomClipper<Rect> {


  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: new Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}