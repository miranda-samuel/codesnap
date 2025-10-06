import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final musicService = Provider.of<MusicService>(context);

    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Settings Section
                Card(
                  color: Color(0xFF1B263B).withOpacity(0.8),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.tealAccent.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.volume_up, color: Colors.tealAccent, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Audio Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Music Toggle
                        _buildSettingItem(
                          icon: Icons.music_note,
                          title: 'Background Music',
                          value: musicService.isMusicEnabled,
                          onChanged: (value) => musicService.toggleMusic(),
                        ),

                        // Music Volume Slider
                        if (musicService.isMusicEnabled) ...[
                          SizedBox(height: 16),
                          _buildVolumeSlider(
                            label: 'Music Volume',
                            value: musicService.musicVolume,
                            onChanged: (value) => musicService.setMusicVolume(value),
                            icon: Icons.volume_up,
                          ),
                        ],

                        SizedBox(height: 20),

                        // Sound Effects Toggle
                        _buildSettingItem(
                          icon: Icons.games,
                          title: 'Sound Effects',
                          value: musicService.isSoundEnabled,
                          onChanged: (value) => musicService.toggleSound(),
                        ),

                        // Sound Volume Slider
                        if (musicService.isSoundEnabled) ...[
                          SizedBox(height: 16),
                          _buildVolumeSlider(
                            label: 'Sound Volume',
                            value: musicService.soundVolume,
                            onChanged: (value) => musicService.setSoundVolume(value),
                            icon: Icons.volume_down,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Test Sound Button
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow, color: Colors.white),
                  label: Text('Test Sound Effect', style: TextStyle(color: Colors.white)),
                  onPressed: () => musicService.playSoundEffect('click.mp3'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                Spacer(),

                // App Info
                Card(
                  color: Color(0xFF1B263B).withOpacity(0.6),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.tealAccent),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Adjust audio settings to enhance your gaming experience',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.tealAccent, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.tealAccent,
          activeTrackColor: Colors.tealAccent.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider({
    required String label,
    required double value,
    required Function(double) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.tealAccent, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          activeColor: Colors.tealAccent,
          inactiveColor: Colors.tealAccent.withOpacity(0.3),
          thumbColor: Colors.white,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Off', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${(value * 100).toInt()}%', style: TextStyle(color: Colors.tealAccent, fontSize: 12)),
            Text('Max', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}