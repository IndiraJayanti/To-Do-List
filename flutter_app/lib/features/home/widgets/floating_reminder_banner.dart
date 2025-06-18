import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FloatingReminderBanner extends StatefulWidget {
  final Map<String, dynamic> note;
  final VoidCallback onDismiss;
  final AnimationController animationController;

  const FloatingReminderBanner({
    Key? key,
    required this.note,
    required this.onDismiss,
    required this.animationController,
  }) : super(key: key);

  @override
  State<FloatingReminderBanner> createState() => _FloatingReminderBannerState();
}

class _FloatingReminderBannerState extends State<FloatingReminderBanner> {
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,
    ));
  }

  void _hideBanner() {
    widget.animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reminderTimeFormatted = widget.note['reminderTime'] != null
        ? DateFormat('HH:mm').format(DateTime.parse(widget.note['reminderTime']).toLocal())
        : '';

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: GestureDetector(
              onTap: _hideBanner,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blueAccent[400], size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'PLAN PAW',
                              style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          'now',
                          style: TextStyle(color: Colors.grey[700], fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.note['title'] ?? 'Pengingat',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today at $reminderTimeFormatted',
                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}