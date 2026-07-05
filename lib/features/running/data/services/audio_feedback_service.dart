import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:reforge/app/utils/logger/logger.dart';

/// Service responsible for playing short audio feedback cues during workouts.
///
/// Ensures proper audio session configuration (ducking other audio like Spotify)
/// and preloads assets to eliminate latency during playback.
class AudioFeedbackService {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  /// Initializes the audio session and preloads assets.
  ///
  /// Why do we call this explicitly before usage?
  /// 1. `AudioSession.configure` sets up the OS-level audio focus. We want
  ///    our sounds to "duck" (lower the volume of) background music instead
  ///    of pausing it or playing over it at full volume.
  /// 2. `_player.setAsset` decodes the WAV/MP3 file into memory. If we don't
  ///    preload it, calling `play()` for the first time will have a noticeable
  ///    latency (100-300ms) while the OS decodes the file.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Configure the OS Audio Session for short notifications (sonification)
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers | AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            flags: AndroidAudioFlags.audibilityEnforced,
            usage: AndroidAudioUsage.notificationEvent,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: true,
        ),
      );

      // 2. Preload the lap completion sound.
      // We load it once and keep it in memory. Subsequent plays will just seek to 0.
      await _player.setAsset('assets/audio/single_heavy_hummer.wav');

      _isInitialized = true;
      logger.d('AudioFeedbackService: initialized and asset preloaded');
    } on Exception catch (e, st) {
      logger.e('AudioFeedbackService: initialization failed', e, st);
    }
  }

  /// Plays the lap completion sound (single heavy hammer).
  Future<void> playLapCompleted() async {
    if (!_isInitialized) {
      logger.w('AudioFeedbackService: playLapCompleted called before init()');
      return;
    }

    try {
      // Since we reuse the same player and asset, we must rewind to the start.
      await _player.seek(Duration.zero);
      // play() returns a Future that completes when playback finishes.
      // Usually we unawait this from the caller side so it doesn't block.
      await _player.play();
    } on Exception catch (e, st) {
      logger.e('AudioFeedbackService: failed to play lap sound', e, st);
    }
  }

  /// Disposes of the audio player resources.
  Future<void> dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }
}
