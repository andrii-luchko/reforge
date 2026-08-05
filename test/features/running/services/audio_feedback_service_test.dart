import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/features/running/data/services/audio_feedback_service.dart';

void main() {
  late MockAudioPlayer singlePlayer;
  late MockAudioPlayer triplePlayer;
  late MockAudioSession audioSession;
  late AudioFeedbackService service;

  setUpAll(() {
    registerFallbackValue(const AudioSessionConfiguration.music());
  });

  setUp(() {
    singlePlayer = MockAudioPlayer();
    triplePlayer = MockAudioPlayer();
    audioSession = MockAudioSession();

    when(() => audioSession.configure(any())).thenAnswer((_) async {});
    when(() => audioSession.setActive(true)).thenAnswer((_) async => true);
    when(
      () => audioSession.setActive(
        false,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ),
    ).thenAnswer((_) async => true);
    when(() => singlePlayer.setAsset(any())).thenAnswer((_) async => const Duration(seconds: 1));
    when(() => triplePlayer.setAsset(any())).thenAnswer((_) async => const Duration(seconds: 1));
    when(() => singlePlayer.seek(Duration.zero)).thenAnswer((_) async {});
    when(() => triplePlayer.seek(Duration.zero)).thenAnswer((_) async {});
    when(singlePlayer.play).thenAnswer((_) async {});
    when(triplePlayer.play).thenAnswer((_) async {});
    when(singlePlayer.pause).thenAnswer((_) async {});
    when(triplePlayer.pause).thenAnswer((_) async {});
    when(singlePlayer.dispose).thenAnswer((_) async {});
    when(triplePlayer.dispose).thenAnswer((_) async {});

    service = AudioFeedbackService(
      singlePlayer: singlePlayer,
      triplePlayer: triplePlayer,
      audioSessionProvider: () async => audioSession,
    );
  });

  test('ducks only for the duration of a lap completion cue', () async {
    await service.init();
    await service.playLapCompleted();

    verifyInOrder([
      () => singlePlayer.seek(Duration.zero),
      () => audioSession.setActive(true),
      singlePlayer.play,
      singlePlayer.pause,
      () => audioSession.setActive(
        false,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ),
    ]);
  });

  test('restores other audio when cue playback fails', () async {
    when(singlePlayer.play).thenThrow(Exception('playback failed'));

    await service.init();
    await service.playLapCompleted();

    verify(singlePlayer.pause).called(1);
    verify(
      () => audioSession.setActive(
        false,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ),
    ).called(1);
  });

  test('serializes cues so their audio focus lifetimes cannot overlap', () async {
    final firstCueFinished = Completer<void>();
    when(singlePlayer.play).thenAnswer((_) => firstCueFinished.future);

    await service.init();
    final firstPlayback = service.playLapCompleted();
    await untilCalled(singlePlayer.play);

    final secondPlayback = service.playWorkoutCompleted();
    await Future<void>.delayed(Duration.zero);
    verifyNever(triplePlayer.play);

    firstCueFinished.complete();
    await firstPlayback;
    await secondPlayback;

    verify(triplePlayer.play).called(1);
    verify(() => audioSession.setActive(true)).called(2);
  });

  test('does not play when audio focus request is denied', () async {
    when(() => audioSession.setActive(true)).thenAnswer((_) async => false);

    await service.init();
    await service.playLapCompleted();

    verifyNever(singlePlayer.play);
    verifyNever(singlePlayer.pause);
    verifyNever(
      () => audioSession.setActive(
        false,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ),
    );
  });
}

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockAudioSession extends Mock implements AudioSession {}
