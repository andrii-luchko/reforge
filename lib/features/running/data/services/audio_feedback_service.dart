import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:reforge/app/utils/logger/logger.dart';

/// Service responsible for playing short audio feedback cues during workouts.
///
/// Ensures proper audio session configuration (ducking other audio like Spotify)
/// and preloads assets to eliminate latency during playback.
class AudioFeedbackService {
  AudioFeedbackService({
    AudioPlayer? singlePlayer,
    AudioPlayer? triplePlayer,
    Future<AudioSession> Function()? audioSessionProvider,
  }) : _singlePlayer = singlePlayer ?? AudioPlayer(handleAudioSessionActivation: false),
       _triplePlayer = triplePlayer ?? AudioPlayer(handleAudioSessionActivation: false),
       _audioSessionProvider = audioSessionProvider ?? (() => AudioSession.instance);

  final AudioPlayer _singlePlayer;
  final AudioPlayer _triplePlayer;
  final Future<AudioSession> Function() _audioSessionProvider;

  AudioSession? _audioSession;
  Future<void> _playbackQueue = Future<void>.value();
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
      final session = await _audioSessionProvider();
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

      // 2. Preload the sounds.
      // We load it once and keep it in memory. Subsequent plays will just seek to 0.
      await _singlePlayer.setAsset('assets/audio/single_heavy_hummer.wav');
      await _triplePlayer.setAsset('assets/audio/triple-heavy-hammer.wav');

      _audioSession = session;
      _isInitialized = true;
      logger.d('AudioFeedbackService: initialized and assets preloaded');
    } on Exception catch (e, st) {
      logger.e('AudioFeedbackService: initialization failed', e, st);
    }
  }

  /// Plays the lap completion sound (single heavy hammer).
  Future<void> playLapCompleted() {
    if (!_isInitialized) {
      logger.w('AudioFeedbackService: playLapCompleted called before init()');
      return Future<void>.value();
    }

    return _enqueuePlayback(
      _singlePlayer,
      errorMessage: 'AudioFeedbackService: failed to play single lap sound',
    );
  }

  /// Plays the workout completion sound (triple heavy hammer).
  Future<void> playWorkoutCompleted() {
    if (!_isInitialized) {
      logger.w('AudioFeedbackService: playWorkoutCompleted called before init()');
      return Future<void>.value();
    }

    return _enqueuePlayback(
      _triplePlayer,
      errorMessage: 'AudioFeedbackService: failed to play workout completed sound',
    );
  }

  Future<void> _enqueuePlayback(AudioPlayer player, {required String errorMessage}) {
    final playback = _playbackQueue.then((_) async {
      try {
        await _playWithDucking(player);
      } on Exception catch (e, st) {
        logger.e(errorMessage, e, st);
      }
    });

    // Keep cues serialized so one cue cannot release audio focus while another
    // one is still playing.
    _playbackQueue = playback;
    return playback;
  }

  Future<void> _playWithDucking(AudioPlayer player) async {
    final session = _audioSession;
    if (session == null) return;

    // Position the preloaded cue before taking focus, so background audio is
    // ducked only for the actual playback window.
    await player.seek(Duration.zero);

    final wasActivated = await session.setActive(true);
    if (!wasActivated) {
      logger.w('AudioFeedbackService: audio focus request was denied');
      return;
    }

    try {
      await player.play();
    } finally {
      try {
        // `play()` remains in the playing state after natural completion.
        // Pause it while retaining the preloaded decoder for the next cue.
        await player.pause();
      } finally {
        await session.setActive(
          false,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        );
      }
    }
  }

  /// Disposes of the audio player resources.
  Future<void> dispose() async {
    _isInitialized = false;
    await _playbackQueue;
    await _singlePlayer.dispose();
    await _triplePlayer.dispose();
    _audioSession = null;
  }
}
