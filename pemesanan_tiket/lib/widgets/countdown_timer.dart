import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {
  final int seconds;
  final VoidCallback? onExpired;
  
  const CountdownTimer({
    super.key,
    required this.seconds,
    this.onExpired,
  });
  
  @override
  Widget build(BuildContext context) {
    if (seconds <= 0) {
      onExpired?.call();
      return _buildExpired();
    }
    
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 6),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpired() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_off, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            'Promo berakhir',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}