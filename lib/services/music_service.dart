import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicService with ChangeNotifier {
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  double _musicVolume = 0.5;
  double _soundVolume = 0.7;
  bool _wasPlayingBeforePause = false;
  bool _isInitialized = false;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  double get musicVolume => _musicVolume;
  double get soundVolume => _soundVolume;

  MusicService() {
    _init();
  }

  bool isBackgroundMusicPlaying() {
    return _backgroundPlayer.state == PlayerState.playing;
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    try {
      await _loadSettings();
      _setupAudioPlayers();
      _isInitialized = true;
      print('🎵 Music Service Initialized');
    } catch (e) {
      print('❌ Error initializing Music Service: $e');
    }
  }

  void _setupAudioPlayers() {
    _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    _backgroundPlayer.setVolume(_isMusicEnabled ? _musicVolume : 0.0);
    _soundEffectPlayer.setVolume(_isSoundEnabled ? _soundVolume : 0.0);

    // Add error handling
    _backgroundPlayer.onPlayerStateChanged.listen((state) {
      print('🎵 Background Player State: $state');
    });

    _backgroundPlayer.onLog.listen((log) {
      print('🎵 Audio Log: $log');
    });
  }

  void setWasPlaying(bool wasPlaying) {
    _wasPlayingBeforePause = wasPlaying;
    print('🎵 Remembering music state: $_wasPlayingBeforePause');
  }

  bool shouldResumeMusic() {
    return _wasPlayingBeforePause && _isMusicEnabled;
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

  // Play regular background music - IMPROVED VERSION
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) {
      print('🎵 Music is disabled, skipping background music');
      return;
    }

    try {
      print('🎵 Starting background music...');

      // Check if already playing
      if (_backgroundPlayer.state == PlayerState.playing) {
        print('🎵 Background music is already playing');
        return;
      }

      await _backgroundPlayer.setVolume(_musicVolume);
      await _backgroundPlayer.play(AssetSource('audio/background_music.mp3'));
      print('🎵 Background music started successfully');
      _wasPlayingBeforePause = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error playing background music: $e');
    }
  }

  // Stop background music - COMPLETE STOP
  Future<void> stopBackgroundMusic() async {
    print('🎵 Stopping background music');
    await _backgroundPlayer.stop();
    _wasPlayingBeforePause = false;
    notifyListeners();
  }

  // Pause background music - TEMPORARY STOP
  Future<void> pauseBackgroundMusic() async {
    print('🎵 Pausing background music');
    await _backgroundPlayer.pause();
    notifyListeners();
  }

  // Resume background music - FIXED VERSION
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) {
      print('🎵 Music is disabled, skipping resume');
      return;
    }

    print('🎵 Attempting to resume background music...');

    try {
      final currentState = _backgroundPlayer.state;
      print('🎵 Current player state: $currentState');

      if (currentState == PlayerState.paused) {
        // If paused, resume it
        await _backgroundPlayer.resume();
        print('🎵 Music resumed from pause');
        _wasPlayingBeforePause = true;
      } else if (currentState == PlayerState.stopped) {
        // If stopped, restart it
        print('🎵 Music was stopped, restarting...');
        await playBackgroundMusic();
      } else if (currentState == PlayerState.playing) {
        print('🎵 Music is already playing');
      } else {
        // If in other state, try to play
        print('🎵 Music in unknown state, attempting to play...');
        await playBackgroundMusic();
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error resuming music: $e');
      // Fallback: restart the music
      await playBackgroundMusic();
    }
  }

  // COMPLETELY STOP ALL MUSIC
  Future<void> stopAllMusic() async {
    print('🛑 Stopping all music completely');
    _wasPlayingBeforePause = false;
    await _backgroundPlayer.stop();
    await _soundEffectPlayer.stop();
    notifyListeners();
  }

  // Play sound effects
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

    if (_isMusicEnabled && _wasPlayingBeforePause) {
      // If enabling music and it was playing before, resume it
      await resumeBackgroundMusic();
    } else if (!_isMusicEnabled) {
      await pauseBackgroundMusic();
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

  @override
  Future<void> dispose() async {
    print('💀 Music Service Disposing');
    await stopAllMusic();
    await _backgroundPlayer.dispose();
    await _soundEffectPlayer.dispose();
    super.dispose();
  }
}