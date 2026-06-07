import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/business_models.dart';
import '../../services/app_data_service.dart';
import '../../shared/widgets/app_map_tile_layer.dart';

class NearbyStationMapScreen extends StatefulWidget {
  const NearbyStationMapScreen({super.key});

  @override
  State<NearbyStationMapScreen> createState() => _NearbyStationMapScreenState();
}

class _NearbyStationMapScreenState extends State<NearbyStationMapScreen> {
  final _appDataService = AppDataService();
  List<StationVO> _stations = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final result = await _appDataService.getNearbyStations();
    if (!mounted) {
      return;
    }
    setState(() {
      _stations = result.data ?? const [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = _stations.isEmpty
        ? const LatLng(39.9499, 116.3420)
        : LatLng(_stations.first.lat, _stations.first.lng);

    return Scaffold(
      appBar: AppBar(title: const Text('附近驿站')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(initialCenter: center, initialZoom: 14),
                  children: [
                    const AppMapTileLayer(),
                    MarkerLayer(
                      markers: _stations
                          .map(
                            (station) => Marker(
                              point: LatLng(station.lat, station.lng),
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

class _StationMarker extends StatelessWidget {
  const _StationMarker({required this.station});

  final StationVO station;

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

  final List<StationVO> stations;

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

  final StationVO station;

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
