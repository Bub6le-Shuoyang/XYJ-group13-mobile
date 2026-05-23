import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearbyStationMapScreen extends StatelessWidget {
  const NearbyStationMapScreen({super.key});

  static const _stations = [
    _Station(
      name: '清河村中心驿站',
      address: '清河村村委会旁 20 米',
      distance: '0.6km',
      point: LatLng(30.5100, 114.3100),
    ),
    _Station(
      name: '村口便民寄取点',
      address: '清河村村口小卖部',
      distance: '1.2km',
      point: LatLng(30.5180, 114.3190),
    ),
    _Station(
      name: '卫生室临时取件点',
      address: '清河村卫生室对面',
      distance: '1.8km',
      point: LatLng(30.5030, 114.3020),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('附近驿站')),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(30.5100, 114.3100),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.group13.mobile',
              ),
              MarkerLayer(
                markers: _stations
                    .map(
                      (station) => Marker(
                        point: station.point,
                        width: 54,
                        height: 54,
                        child: _StationMarker(station: station),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: _StationListCard(stations: _stations),
          ),
        ],
      ),
    );
  }
}

class _Station {
  const _Station({
    required this.name,
    required this.address,
    required this.distance,
    required this.point,
  });

  final String name;
  final String address;
  final String distance;
  final LatLng point;
}

class _StationMarker extends StatelessWidget {
  const _StationMarker({required this.station});

  final _Station station;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: station.name,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.store_rounded, color: Color(0xFF9C27B0), size: 34),
        ),
      ),
    );
  }
}

class _StationListCard extends StatelessWidget {
  const _StationListCard({required this.stations});

  final List<_Station> stations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '附近可用驿站',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stations.map((station) => _StationListItem(station: station)),
        ],
      ),
    );
  }
}

class _StationListItem extends StatelessWidget {
  const _StationListItem({required this.station});

  final _Station station;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: Color(0xFF9C27B0),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  station.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            station.distance,
            style: const TextStyle(
              color: Color(0xFF9C27B0),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
