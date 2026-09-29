import 'package:flutter/material.dart';
import '../models/milk_can.dart';
import '../services/mongodb_service.dart';
import '../services/milkora_ble_service.dart';
import '../localization/language_provider.dart';
import '../localization/app_strings.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import 'all_milk_cans_screen.dart';
import 'can_details_screen.dart';
import 'home_screen.dart';
import 'important_alerts_screen.dart';
import 'previous_records_screen.dart';
import 'profile_screen.dart';
import '../widgets/ble_connection_panel.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<MilkCan> _cans = [];
  MilkCan? _selectedCan;
  MilkCan? _viewingDetailCan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto-initiate BLE scanning for MILKORA-CAN-01
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MilkoraBleService().status == BleStatus.disconnected) {
        MilkoraBleService().startScan();
      }
    });
  }

  Future<void> _fetchData() async {
    final cans = await MongoDatabase.getCans();
    setState(() {
      _cans = cans;
      if (_cans.isNotEmpty) {
        _selectedCan = _cans.first;
      }
      _isLoading = false;
    });
  }

  void _navigateToDetail(MilkCan can) {
    setState(() {
      _viewingDetailCan = can;
    });
  }

  void _closeDetail() {
    setState(() {
      _viewingDetailCan = null;
    });
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  String _getTitle(AppStrings strings) {
    switch (_currentIndex) {
      case 0:
        return strings.appTitle;
      case 1:
        return strings.milkCansTitle;
      case 2:
        return strings.alertsTitle;
      case 3:
        return strings.historyTitle;
      default:
        return strings.appTitle;
    }
  }

  String _getSubtitle(AppStrings strings) {
    switch (_currentIndex) {
      case 0:
        return strings.smartMilkMonitoring;
      case 1:
        return strings.monitorAllCans;
      case 2:
        return strings.realTimeNotifications;
      case 3:
        return strings.trackTrends;
      default:
        return strings.smartMilkMonitoring;
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = LanguageProvider();

    return ListenableBuilder(
      listenable: langProvider,
      builder: (context, _) {
        final strings = langProvider.strings;

        if (_viewingDetailCan != null) {
          return CanDetailsScreen(
            can: _viewingDetailCan!,
            onBack: _closeDetail,
            onViewHistory: () {
              setState(() {
                _selectedCan = _viewingDetailCan;
                _viewingDetailCan = null;
                _currentIndex = 3; // Switch to History tab
              });
            },
            onMarkCollected: () {
              setState(() {
                final index = _cans.indexWhere((c) => c.id == _viewingDetailCan!.id);
                if (index != -1) {
                  // mark as collected
                }
              });
            },
          );
        }

        return Scaffold(
          appBar: AppHeader(
            title: _getTitle(strings),
            subtitle: _getSubtitle(strings),
            showBrandHeader: _currentIndex == 0,
            onBleTap: () => BleConnectionPanel.show(context),
            onNotificationTap: () {
              setState(() {
                _currentIndex = 2; // Switch to Alerts
              });
            },
            onProfileTap: _openProfile,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _cans.isEmpty
                  ? const Center(child: Text("No data found"))
                  : IndexedStack(
                      index: _currentIndex,
                      children: [
                        HomeScreen(
                          can: _selectedCan!,
                          onViewAllCans: () => setState(() => _currentIndex = 1),
                          onSelectCan: _navigateToDetail,
                        ),
                        AllMilkCansScreen(
                          cans: _cans,
                          onSelectCan: _navigateToDetail,
                        ),
                        ImportantAlertsScreen(
                          cans: _cans,
                          onSelectCan: _navigateToDetail,
                        ),
                        PreviousRecordsScreen(
                          selectedCan: _selectedCan!,
                          allCans: _cans,
                          onSelectCan: (can) {
                            setState(() {
                              _selectedCan = can;
                            });
                          },
                        ),
                      ],
                    ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            alertCount: 1,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
