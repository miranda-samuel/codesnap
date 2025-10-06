import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'daily_challenge.dart';
import '../services/music_service.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  @override
  void initState() {
    super.initState();
    _ensureBackgroundMusic(); // ADD BACKGROUND MUSIC
  }

  // ADD THIS METHOD: Ensure background music is playing
  void _ensureBackgroundMusic() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicService = Provider.of<MusicService>(context, listen: false);

      if (!musicService.isBackgroundMusicPlaying() && musicService.isMusicEnabled) {
        print('🎵 SelectLanguageScreen: Starting background music...');
        await musicService.playBackgroundMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languages = ['C++', 'Java', 'Python', 'PHP', 'SQL'];
    final icons = [
      Icons.memory,       // C++
      Icons.coffee,       // Java
      Icons.code,         // Python
      Icons.php,          // PHP
      Icons.storage,      // SQL
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Choose Language',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.tealAccent),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background - Dark blue gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B263B),
                    Color(0xFF415A77),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Decorative elements - Updated colors
            Positioned(
              top: -80,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // App Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'CodeMaster Pro',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Master Programming Through Challenges',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Daily Challenge Button - Prominent Feature
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF00B4D8).withOpacity(0.8),
                              Color(0xFF0077B6).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.tealAccent.withOpacity(0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // ADD SOUND EFFECT
                              final musicService = Provider.of<MusicService>(context, listen: false);
                              musicService.playSoundEffect('click.mp3');

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DailyChallengeScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.tealAccent.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.emoji_events,
                                      color: Colors.tealAccent,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daily Challenge',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Solve today\'s coding puzzle!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_filled,
                                              color: Colors.tealAccent,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'New puzzle every day',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.tealAccent,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Languages Section Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded( // CHANGE TO EXPANDED
                          child: Text(
                            'Programming Languages',
                            style: TextStyle(
                              fontSize: 16, // SLIGHTLY SMALLER FONT
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        SizedBox(width: 8), // ADD SPACING
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.tealAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '5', // JUST SHOW THE NUMBER
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Languages List - FIXED OVERFLOW
                  Expanded(
                    child: ListView.builder(
                      itemCount: languages.length,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        return _buildLanguageCard(
                          context,
                          languages[index],
                          icons[index],
                          index,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20),

                  // Bottom Info - FIXED OVERFLOW
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Choose a language to start learning or try the daily challenge!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, // ADD MAX LINES TO PREVENT OVERFLOW
                      overflow: TextOverflow.ellipsis, // ADD OVERFLOW HANDLING
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, String language, IconData icon, int index) {
    List<Color> cardColors = [
      Color(0xFF415A77).withOpacity(0.6),
      Color(0xFF4A6FA5).withOpacity(0.6),
      Color(0xFF5E81AC).withOpacity(0.6),
      Color(0xFF6B8CBC).withOpacity(0.6),
      Color(0xFF7A9CC6).withOpacity(0.6),
    ];

    List<Color> iconColors = [
      Colors.tealAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColors[index],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // ADD SOUND EFFECT
            final musicService = Provider.of<MusicService>(context, listen: false);
            musicService.playSoundEffect('click.mp3');

            // ADD SPECIAL SOUND FOR DIFFERENT LANGUAGES (OPTIONAL)
            _playLanguageSound(language, musicService);

            Navigator.pushNamed(
              context,
              '/levels',
              arguments: language,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon with tap animation
                GestureDetector(
                  onTap: () {
                    // ADD ICON TAP SOUND EFFECT
                    final musicService = Provider.of<MusicService>(context, listen: false);
                    musicService.playSoundEffect('icon_click.mp3');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                        BoxShadow(
                          color: iconColors[index].withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: iconColors[index],
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        // ADD CONTAINER TO PREVENT TEXT OVERFLOW
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        child: Text(
                          _getLanguageDescription(language),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          maxLines: 2, // LIMIT TO 2 LINES
                          overflow: TextOverflow.ellipsis, // ADD ELLIPSIS IF TOO LONG
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow button with sound - FIXED OVERFLOW
                Container(
                  // ADD CONTAINER WITH FIXED WIDTH TO PREVENT OVERFLOW
                  width: 40,
                  child: GestureDetector(
                    onTap: () {
                      // ADD ARROW TAP SOUND EFFECT
                      final musicService = Provider.of<MusicService>(context, listen: false);
                      musicService.playSoundEffect('arrow_click.mp3');

                      // Navigate when arrow is tapped
                      musicService.playSoundEffect('click.mp3');
                      Navigator.pushNamed(
                        context,
                        '/levels',
                        arguments: language,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), // REDUCED PADDING
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.tealAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.tealAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageDescription(String language) {
    switch (language) {
      case 'C++':
        return 'System programming, games';
      case 'Java':
        return 'Enterprise, Android apps';
      case 'Python':
        return 'AI, web, data science';
      case 'PHP':
        return 'Web development';
      case 'SQL':
        return 'Database management';
      default:
        return 'Programming language';
    }
  }

  // OPTIONAL: Play different sounds for different languages
  void _playLanguageSound(String language, MusicService musicService) {
    switch (language) {
      case 'C++':
        musicService.playSoundEffect('cpp_select.mp3');
        break;
      case 'Java':
        musicService.playSoundEffect('java_select.mp3');
        break;
      case 'Python':
        musicService.playSoundEffect('python_select.mp3');
        break;
      case 'PHP':
        musicService.playSoundEffect('php_select.mp3');
        break;
      case 'SQL':
        musicService.playSoundEffect('sql_select.mp3');
        break;
      default:
        musicService.playSoundEffect('language_select.mp3');
        break;
    }
  }
}