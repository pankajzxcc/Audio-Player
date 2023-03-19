import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
         colorSchemeSeed: Colors.teal,
        textTheme: GoogleFonts.robotoMonoTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final player = AudioPlayer();
  Song _currentSong = songList.first;
  Duration _duration = const Duration();
  Duration _position = const Duration();

  ///Skip to next button function///
  void _skipToNext() {
    final currentSongIndex = songList.indexWhere((it) {
      return it.name == _currentSong.name;
    });

    var nextSongIndex = currentSongIndex + 1;
    if (nextSongIndex == songList.length) {
      nextSongIndex = 0;
    }

    final nextSong = songList[nextSongIndex];

    setState(() {
      _currentSong = nextSong;
      player.play(nextSong.source);
    });
  }

  ///Skip to previous button function///
  void _skipToPrevious() {
    final currentSongIndex = songList.indexWhere((it) {
      return it.name == _currentSong.name;
    });

    var previousSongIndex = currentSongIndex - 1;
    if (previousSongIndex == -1) {
      previousSongIndex = songList.length - 1;
    }

    final previousSong = songList[previousSongIndex];

    setState(() {
      _currentSong = previousSong;
      player.play(previousSong.source);
    });
  }

  @override
  void initState() {
    super.initState();
    player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        return _skipToNext();
      }
      setState(() {});
    });

    player.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

    player.onPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });
  }

  ///for showing which button song button we clicked///
  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  ...songList.map(
                    (song) {
                      final isCurrentSong = song.name == _currentSong.name;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _currentSong = song;
                            player.play(_currentSong.source);
                            toast(context, 'You Selected:   ${song.name}');
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (_) {
                                if (isCurrentSong) {
                                  return colorScheme.background;
                                }
                                return null; // Use the component's default.
                              },
                            ),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (_) {
                                if (isCurrentSong) {
                                  return colorScheme.primary;
                                }
                                return null; // Use the component's default.
                              },
                            ),
                          ),
                          child: ListTile(
                            title: Text(song.name),
                            subtitle: Text(song.singer),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Material(
              elevation: 48,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Currently playing: ${_currentSong.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      // color: colorScheme.surfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: ProgressBar(
                      progress: _position,
                      total: _duration,
                      // timeLabelTextStyle: theme.textTheme.bodyLarge?.copyWith(
                      //   color: colorScheme.surfaceVariant,
                      // ),
                      onSeek: player.seek,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded),
                        iconSize: 48,
                        onPressed: () => _skipToPrevious(),
                      ),
                      IconButton(
                          icon: (player.state == PlayerState.playing)
                              ? const Icon(Icons.pause_rounded)
                              : const Icon(Icons.play_arrow_rounded),
                          iconSize: 48,
                          onPressed: () async {
                            if (player.state == PlayerState.playing) {
                              await player.pause();
                            } else {
                              await player.play(_currentSong.source);
                            }
                          }),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded),
                        iconSize: 48,
                        onPressed: () => _skipToNext(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///songs List///
final songList = [
  Song(
    name: 'Theme 1',
    source: AssetSource('sounds/theme_01.mp3'),
    singer: 'xCream',
  ),
  Song(
    name: 'Theme 2',
    source: AssetSource('sounds/theme_02.mp3'),
    singer: 'Honey singh',
  ),
  Song(
    name: 'Theme 3',
    source: AssetSource('sounds/theme_03.mp3'),
    singer: 'Arijit singh',
  ),
  Song(
    name: 'Theme 4',
    source: AssetSource('sounds/theme_01.mp3'),
    singer: 'xCream',
  ),
  Song(
    name: 'Theme 5',
    source: AssetSource('sounds/theme_02.mp3'),
    singer: 'Honey singh',
  ),
  Song(
    name: 'Theme 6',
    source: AssetSource('sounds/theme_03.mp3'),
    singer: 'Arijit singh',
  ),
  Song(
    name: 'Theme 7',
    source: AssetSource('sounds/theme_01.mp3'),
    singer: 'xCream',
  ),
  Song(
    name: 'Theme 8',
    source: AssetSource('sounds/theme_02.mp3'),
    singer: 'Honey singh',
  ),
  Song(
    name: 'Theme 9',
    source: AssetSource('sounds/theme_03.mp3'),
    singer: 'Arijit singh',
  ),
];

///songs list constructer///
class Song {
  final String name;
  final Source source;
  final String singer;

  Song(
      {required this.name,
      required this.source,
      required this.singer});
}
