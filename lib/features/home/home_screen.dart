import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fcm_service.dart';
import '../../core/providers.dart';
import '../messages/messages_screen.dart';
import '../news/news_list_screen.dart';
import '../notifications/notifications_screen.dart';
import 'dashboard_tab.dart';

/// Bottom-nav shell mirroring the web portal's four sections (dashboard / رسائلي / الإشعارات /
/// أخبار النقابة, see AshrafBack.Members.Web/Views/Home/Index.cshtml's nav links).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  static const _tabs = [
    DashboardTab(),
    MessagesScreen(),
    NotificationsScreen(),
    NewsListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Registers this device's FCM token for the signed-in member - covers both a fresh login
    // and a resumed session (HomeScreen mounts either way), and is a harmless no-op upsert if
    // the token is already registered.
    ref.read(fcmServiceProvider).registerToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة الأعضاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => ref.read(authTokenProvider.notifier).clear(),
          ),
        ],
      ),
      body: IndexedStack(index: _tabIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
          NavigationDestination(icon: Icon(Icons.mail), label: 'رسائلي'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'الإشعارات'),
          NavigationDestination(icon: Icon(Icons.article), label: 'أخبار النقابة'),
        ],
      ),
    );
  }
}
