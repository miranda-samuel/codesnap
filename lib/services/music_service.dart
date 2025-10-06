import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicService with ChangeNotifier {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal() {
    _init();
  }

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  double _musicVolume = 0.5;
  double _soundVolume = 0.7;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  double get musicVolume => _musicVolume;
  double get soundVolume => _soundVolume;

  // ADD THIS METHOD: Check if background music is playing
  bool isBackgroundMusicPlaying() {
    return _backgroundPlayer.state == PlayerState.playing;
  }

  Future<void> _init() async {
    await _loadSettings();
    _setupAudioPlayers();
  }

  void _setupAudioPlayers() {
    _backgroundPlayer.setVolume(_isMusicEnabled ? _musicVolume : 0.0);
    _soundEffectPlayer.setVolume(_isSoundEnabled ? _soundVolume : 0.0);

    _backgroundPlayer.onPlayerComplete.listen((event) {
      _backgroundPlayer.seek(Duration.zero);
      _backgroundPlayer.resume();
    });
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
      _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
      _soundVolume = prefs.getDouble('sound_volume') ?? 0.7;
      notifyListeners();
    } catch (e) {
      print('Error loading music settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_enabled', _isMusicEnabled);
      await prefs.setBool('sound_enabled', _isSoundEnabled);
      await prefs.setDouble('music_volume', _musicVolume);
      await prefs.setDouble('sound_volume', _soundVolume);
    } catch (e) {
      print('Error saving music settings: $e');
    }
  }

  // Play regular background music (for home screen, menus, etc.)
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) {
      print('🎵 Music is disabled, skipping background music');
      return;
    }

    try {
      print('🎵 Starting background music...');
      await _backgroundPlayer.stop();
      await _backgroundPlayer.setVolume(_musicVolume);
      await _backgroundPlayer.play(AssetSource('audio/background_music.mp3'));
      print('🎵 Background music started successfully');
      notifyListeners();
    } catch (e) {
      print('❌ Error playing background music: $e');
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    print('🎵 Stopping background music');
    await _backgroundPlayer.stop();
    notifyListeners();
  }

  // Pause background music (for when game music plays)
  Future<void> pauseBackgroundMusic() async {
    print('🎵 Pausing background music');
    await _backgroundPlayer.pause();
    notifyListeners();
  }

  // Resume background music (after game music stops)
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) {
      print('🎵 Music is disabled, skipping resume');
      return;
    }

    print('🎵 Resuming background music');
    await _backgroundPlayer.resume();
    notifyListeners();
  }

  // Play sound effects (separate from background music)
  Future<void> playSoundEffect(String soundFile) async {
    if (!_isSoundEnabled) return;

    try {
      await _soundEffectPlayer.stop();
      await _soundEffectPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      print('Error playing sound effect $soundFile: $e');
    }
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    await _backgroundPlayer.setVolume(_isMusicEnabled ? _musicVolume : 0.0);

    if (_isMusicEnabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }

    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    await _soundEffectPlayer.setVolume(_isSoundEnabled ? _soundVolume : 0.0);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _backgroundPlayer.setVolume(_isMusicEnabled ? volume : 0.0);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume;
    await _soundEffectPlayer.setVolume(_isSoundEnabled ? volume : 0.0);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> dispose() async {
    super.dispose();
    await _backgroundPlayer.dispose();
    await _soundEffectPlayer.dispose();
  }
}