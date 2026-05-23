import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectedPickupAddress {
  const SelectedPickupAddress({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;
}

class AddressPickerScreen extends StatefulWidget {
  const AddressPickerScreen({super.key, this.initialAddress});

  final String? initialAddress;

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final _mapController = MapController();
  late final TextEditingController _addressController;
  LatLng _selectedPoint = const LatLng(30.5100, 114.3100);

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _locateAddress() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先输入取件地址')));
      return;
    }

    final hash = address.runes.fold<int>(0, (value, rune) => value + rune);
    final offsetLat = (hash % 18 - 9) * 0.0018;
    final offsetLng = (hash % 22 - 11) * 0.0016;
    final nextPoint = LatLng(30.5100 + offsetLat, 114.3100 + offsetLng);

    setState(() => _selectedPoint = nextPoint);
    _mapController.move(nextPoint, max(_mapController.camera.zoom, 15));
  }

  void _confirmAddress() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写取件地址')));
      return;
    }

    Navigator.pop(
      context,
      SelectedPickupAddress(
        address: address,
        lat: _selectedPoint.latitude,
        lng: _selectedPoint.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择取件地址')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPoint,
              initialZoom: 15,
              onTap: (_, point) => setState(() => _selectedPoint = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.group13.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFE53935),
                      size: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: _AddressSearchCard(
              controller: _addressController,
              onLocate: _locateAddress,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: _AddressConfirmCard(
              point: _selectedPoint,
              onConfirm: _confirmAddress,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSearchCard extends StatelessWidget {
  const _AddressSearchCard({required this.controller, required this.onLocate});

  final TextEditingController controller;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('pickup_address_map_field'),
              controller: controller,
              decoration: const InputDecoration(
                hintText: '输入取件地址，如：清河村 3 组 18 号',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onLocate(),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            key: const ValueKey('locate_address_button'),
            onPressed: onLocate,
            style: FilledButton.styleFrom(
              minimumSize: const Size(78, 48),
              padding: EdgeInsets.zero,
            ),
            child: const Text('定位'),
          ),
        ],
      ),
    );
  }
}

class _AddressConfirmCard extends StatelessWidget {
  const _AddressConfirmCard({required this.point, required this.onConfirm});

  final LatLng point;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            '拖动地图或点击地图微调取件点',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '当前坐标：${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const ValueKey('confirm_pickup_address_button'),
            onPressed: onConfirm,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('确认取件地址'),
          ),
        ],
      ),
    );
  }
}
