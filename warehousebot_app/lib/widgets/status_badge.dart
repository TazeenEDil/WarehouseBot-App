import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Badge widget for displaying status with color coding
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? customColor;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.customColor,
    this.showDot = true,
  });

  Color getStatusColor() {
    if (customColor != null) return customColor!;
    
    switch (status.toLowerCase()) {
      case "completed":
      case "busy":
      case "working":
      case "active":
        return AppTheme.success;
      case "pending":
      case "queued":
        return AppTheme.warning;
      case "in transit":
      case "idle":
        return AppTheme.primary;
      case "error":
      case "failed":
        return AppTheme.error;
      case "charging":
        return AppTheme.warning;
      default:
        return AppTheme.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}