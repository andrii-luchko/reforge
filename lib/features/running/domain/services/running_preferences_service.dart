abstract class RunningPreferencesService {
  bool get hasSeenAudioHint;
  Future<void> markAudioHintSeen();
}
