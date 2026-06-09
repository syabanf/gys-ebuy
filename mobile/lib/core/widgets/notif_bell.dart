import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../notif_state.dart';
import '../theme/app_colors.dart';

class NotifBell extends StatefulWidget {
  const NotifBell({super.key});

  @override
  State<NotifBell> createState() => _NotifBellState();
}

class _NotifBellState extends State<NotifBell> {
  final _store = NotifState();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChange);
  }

  @override
  void dispose() {
    _store.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final unread = _store.unread;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications')),
        if (unread > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(color: GysColors.danger, borderRadius: BorderRadius.circular(8)),
              child: Text('$unread', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}
