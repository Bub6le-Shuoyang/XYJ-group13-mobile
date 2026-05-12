import 'package:flutter/material.dart';
import '../state/package_state.dart';
import '../package_detail_screen.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    this.actionLabel,
    this.actionIcon,
    this.onPressed,
  });

  final VillagePackage package;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onPressed;

  Color _statusColor(PackageStatus status) {
    return switch (status) {
      PackageStatus.pendingInbound => const Color(0xFF9E9E9E),
      PackageStatus.inStock => const Color(0xFF1677FF),
      PackageStatus.taskPublished => const Color(0xFFFF8C00),
      PackageStatus.assigned => const Color(0xFF4CAF50),
      PackageStatus.readyForPickup => const Color(0xFFFF6B35),
      PackageStatus.completed => const Color(0xFF8BC34A),
    };
  }

  IconData _statusIcon(PackageStatus status) {
    return switch (status) {
      PackageStatus.pendingInbound => Icons.inbox_rounded,
      PackageStatus.inStock => Icons.warehouse_rounded,
      PackageStatus.taskPublished => Icons.campaign_rounded,
      PackageStatus.assigned => Icons.local_shipping_rounded,
      PackageStatus.readyForPickup => Icons.markunread_mailbox_rounded,
      PackageStatus.completed => Icons.check_circle_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(package.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('package_card_${package.id}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackageDetailScreen(package: package),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _statusIcon(package.status),
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package.id,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      package.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline,
                      text: '${package.sender} → ${package.receiver}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      package.address,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '¥${package.reward}',
                    style: const TextStyle(
                      color: Color(0xFFFF8C00),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (package.timeline.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.timeline_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        package.timeline.last,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (actionLabel != null && onPressed != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: FilledButton.icon(
                    key: ValueKey('package_action_button_${package.id}'),
                    onPressed: onPressed,
                    icon: Icon(actionIcon, size: 18),
                    label: Text(actionLabel!),
                    style: FilledButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }
}
