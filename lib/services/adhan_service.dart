import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AdhanService {
  final AudioPlayer _player = AudioPlayer()
    ..setAndroidAudioAttributes(const AndroidAudioAttributes(
      usage: AndroidAudioUsage.alarm,
      contentType: AndroidAudioContentType.music,
    ));

  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));

  Future<void> play(String path, {double volume = 1.0}) async {
    if (path.isEmpty) return;

    final file = File(path);
    if (!await file.exists()) return;

    try {
      await _player.stop();
      await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.setFilePath(path);
      await _player.play();
    } catch (_) {}
  }

  Future<void> preview(String path, {double volume = 1.0}) async {
    if (_player.playing) {
      await _player.stop();
    } else {
      await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.setFilePath(path);
      await _player.play();
    }
  }

  Future<String?> pickAndCopy(String prayerName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) return null;

      final src = result.files.single.path!;
      final dir = await getApplicationDocumentsDirectory();
      final ext = _ext(src);
      final dest = '${dir.path}/adhan_$prayerName$ext';

      await File(src).copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }

  String _ext(String p) {
    final i = p.lastIndexOf('.');
    return i == -1 ? '.mp3' : p.substring(i);
  }

  void dispose() => _player.dispose();
}