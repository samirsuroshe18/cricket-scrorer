import 'dart:async';
import 'dart:io';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class CompressionService extends GetxService {
  final ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  Session? videoSession;

  /// Compresses an image using FFmpeg, scaling it down and re-encoding as JPEG.
  ///
  /// Mirrors an Instagram-style compression pipeline: downscale to [scale]px
  /// on the longest edge (never upscales) and re-encode at the given [quality]
  /// (FFmpeg's `-q:v`, lower is better; typical range 2–31).
  ///
  /// Returns `Either.result(File)` on success or `Either.fallback(CricketFailure)`
  /// on failure. Never throws — all exceptions are caught and converted.
  Future<Either<File, CricketFailure>> imageCompression({
    required String inputPath,
    String? outputPath,
    int quality = 2,
    int scale = 1080,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final inputFile = File(inputPath);

      if (!await inputFile.exists()) {
        return Either.fallback(
          CricketFailure(
            message: '❌  ${TranslationKeys.inputFileNotExists.tr}: $inputPath',
            statusCode: null,
          ),
        );
      }

      final originalSize = await inputFile.length();
      if (kDebugMode) {
        print('📥 Original size: ${(originalSize / (1024 * 1024)).toStringAsFixed(2)} MB');
      }

      final dir = await getTemporaryDirectory();
      final op = outputPath ??
          '${dir.path}/womaty_${DateTime.now().microsecondsSinceEpoch}.jpeg';

      // Scale the image to `scale` resolution (never upscale) and set
      // compression quality. Instagram-standard command. Paths are quoted
      // to safely handle spaces/special characters.
      final command =
          '-i "$inputPath" -vf "scale=\'min($scale,iw)\':-1" -q:v $quality -map_metadata -1 "$op"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (returnCode?.isValueSuccess() ?? false) {
        final file = File(op);

        if (!await file.exists()) {
          return Either.fallback(
            CricketFailure(
              message: '❌ ${TranslationKeys.compressionMissingOutput.tr}',
              statusCode: returnCode?.getValue(),
            ),
          );
        }

        if (kDebugMode) {
          final stat = await file.stat();
          print('✅ Compression successful');
          print('💿 Compressed size: ${(stat.size / (1024 * 1024)).toStringAsFixed(2)} MB');
        }

        return Either.result(file);
      }

      // Compression failed — log FFmpeg's own diagnostics and clean up any
      // partial output file so it doesn't linger in the temp directory.
      final logs = await session.getLogsAsString();
      if (kDebugMode) {
        print('❌ Compression failed (code: ${returnCode?.getValue()})');
        print('FFmpeg logs: $logs');
      }

      final partialFile = File(op);
      if (await partialFile.exists()) {
        await partialFile.delete();
      }

      return Either.fallback(
        CricketFailure(
          message: '❌ ${TranslationKeys.compressionFailed.tr}',
          statusCode: returnCode?.getValue(),
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Compression threw an exception: $e');
        print(stackTrace);
      }
      return Either.fallback(
        CricketFailure(message: '❌ Compression error: $e', statusCode: null),
      );
    } finally {
      stopwatch.stop();
      debugPrint('Stopwatch: ${stopwatch.elapsed}');
    }
  }

  /// Read-only access to progress (0.0–1.0) for widgets to listen to.
  ValueListenable<double> get videoProgress => progressNotifier;

  Future<Either<File, CricketFailure>> compressingVideo({
    required String inputPath,
  }) async {
    await videoSession?.cancel();
    progressNotifier.value = 0.0;

    final completer = Completer<Either<File, CricketFailure>>();
    final dir = await getTemporaryDirectory();
    final outputPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final totalDurationMs = await _getVideoDurationMs(inputPath);
    if (totalDurationMs <= 0) {
      debugPrint('Could not determine video duration');
      return Either.fallback(
        CricketFailure(
          message: 'Could not determine video duration',
          statusCode: null,
        ),
      );
    }

    final command =
        '-i "$inputPath" '
        '-vf "scale=min(1280\\,iw):-2" '
        '-r 30 '
        '-c:v libx264 '
        '-preset medium '
        '-b:v 1200k '
        '-maxrate 1200k '
        '-bufsize 2400k '
        '-profile:v baseline '
        '-level 3.1 '
        '-pix_fmt yuv420p '
        '-movflags +faststart '
        '-vsync cfr '
        '-c:a aac '
        '-b:a 96k '
        '-ac 2 '
        '"$outputPath"';

    videoSession = await FFmpegKit.executeAsync(
      command,
          (session) async {
        final rc = await session.getReturnCode();

        if (ReturnCode.isSuccess(rc)) {
          progressNotifier.value = 1.0;
          completer.complete(Either.result(File(outputPath)));
        } else if (ReturnCode.isCancel(rc)) {
          completer.complete(
            Either.fallback(
              CricketFailure(message: 'Video compression cancelled', statusCode: null),
            ),
          );
        } else {
          completer.complete(
            Either.fallback(
              CricketFailure(
                message: 'Something went wrong',
                statusCode: rc?.getValue(),
              ),
            ),
          );
        }
      },
          (log) {},
          (statistics) {
        final processedMs = statistics.getTime();
        final progress = (processedMs / totalDurationMs).clamp(0.0, 1.0);
        progressNotifier.value = progress;
      },
    );

    return completer.future;
  }

  /// Get video duration (milliseconds)
  Future<int> _getVideoDurationMs(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();

    if (info == null) return 0;

    final durationStr = info.getDuration();
    final durationSeconds = double.tryParse(durationStr ?? '0') ?? 0;

    return (durationSeconds * 1000).toInt();
  }

  @override
  void onClose() {
    videoSession?.cancel();
    progressNotifier.dispose();
    super.onClose();
  }
}
