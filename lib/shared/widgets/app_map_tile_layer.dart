import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class AppMapTileLayer extends StatelessWidget {
  const AppMapTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate:
          'https://webrd0{s}.is.autonavi.com/appmaptile'
          '?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
      subdomains: const ['1', '2', '3', '4'],
      userAgentPackageName: 'com.group13.mobile',
    );
  }
}
