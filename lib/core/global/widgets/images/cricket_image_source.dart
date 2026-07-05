import 'package:cricket_scorer/core/enums/cricket_image_type.dart';

class CricketImageSource {
  final CricketImageType type;
  final String path;

  const CricketImageSource._(this.type, this.path);

  const CricketImageSource.asset(String path)
      : this._(CricketImageType.asset, path);

  const CricketImageSource.network(String url)
      : this._(CricketImageType.network, url);

  const CricketImageSource.svg(String path)
      : this._(CricketImageType.svg, path);

  const CricketImageSource.file(String path)
      : this._(CricketImageType.file, path);
}