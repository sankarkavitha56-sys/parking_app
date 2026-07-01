// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/parking_lot.dart';
import 'add_lot_screen.dart';
import 'edit_lot_screen.dart';
import 'spot_details_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ParkingLot> lots = [];
  List<Map<String, dynamic>> spotsWithDetails = [];
  Map<String, dynamic> summary = {};
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({String? query}) async {
    if (!mounted || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthService>();
      final token = auth.token;
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication token missing. Please log in.'),
            ),
          );
        }
        return;
      }
      final fetchedLots = await ApiService.getParkingLots(
        query: query,
        token: token,
      );
      // Sort lots by ID for consistent sequential numbering
      final sortedLots = fetchedLots
        ..sort((a, b) => (a.id ?? '').compareTo(b.id ?? ''));
      // Assign sequential lot numbers
      lots = sortedLots.asMap().entries.map((entry) {
        final lot = entry.value;
        lot.lotNumber = (entry.key + 1).toString(); // 1, 2, 3...
        lot.code =
            lot.code ?? 'LOT-${lot.id?.substring(0, 4).toUpperCase() ?? 'N/A'}';
        return lot;
      }).toList();

      final fetchedSpots = await ApiService.getSpotsWithDetails(token: token);
      spotsWithDetails = fetchedSpots.map((spot) {
        // Find lot number
        final lotId = spot['lotId']?.toString() ?? '';
        final matchingLot = lots.firstWhere(
          (lot) => lot.id == lotId,
          orElse: () => ParkingLot(),
        );
        final lotNum = matchingLot.lotNumber ?? 'N/A';
        final spotIndex = spot['spotIndex'] ?? 1; // From backend, fallback 1
        spot['spotCode'] = '$lotNum-$spotIndex'; // e.g., "1-1"
        return spot;
      }).toList();

      summary = await ApiService.getSummary(token: token);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('LoadData error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load failed: $e. Check backend/DB seed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthService>();
    auth.logout();
    ApiService.logout(); // Clear API token
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar with logout
            Container(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome to Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.refresh, color: Colors.white),
                        ),
                        onPressed: _isLoading ? null : _loadData,
                        tooltip: 'Refresh Data',
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.logout, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // TabBar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue.shade700,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.blue.shade700,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                tabs: [
                  Tab(text: 'Parking Lots'),
                  Tab(text: 'Parking Spots'),
                  Tab(text: 'Revenue'),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade600,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLotsTab(),
                        _buildSpotsTab(),
                        _buildRevenueTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar (unchanged)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by lot or location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _loadData(query: value),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddLotScreen(onAdded: _loadData),
                  ),
                );
                _loadData();
              },
              icon: Icon(Icons.add_location_alt),
              label: Text('Add Lot'),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: lots.isEmpty
                ? _buildEmptyState('No Parking Lots', Icons.local_parking)
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text('Lot ID'),
                        ), // Sequential 1,2,3...
                        DataColumn(label: Text('Location Name')),
                        DataColumn(label: Text('Price/hr')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Pin Code')),
                        DataColumn(label: Text('Max Spots')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: lots.asMap().entries.map<DataRow>((entry) {
                        final index = entry.key + 1; // Sequential 1,2,3...
                        final lot = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text('$index')), // Sequential number
                            DataCell(Text(lot.primeLocationName ?? 'N/A')),
                            DataCell(Text('₹${lot.price ?? 0}')),
                            DataCell(
                              Text(
                                '${lot.address ?? 'N/A'}, ${lot.pinCode ?? 'N/A'}',
                              ),
                            ),
                            DataCell(Text(lot.pinCode ?? 'N/A')),
                            DataCell(Text('${lot.maximumNumberOfSpots ?? 0}')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditLotScreen(
                                            lot: lot,
                                            onUpdated: _loadData,
                                          ),
                                        ),
                                      );
                                      if (result == true) _loadData();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteLot(lot.id ?? ''),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar (unchanged)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search spots...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _loadData(query: value),
            ),
          ),
          Expanded(
            child: spotsWithDetails.isEmpty
                ? _buildEmptyState('No Parking Spots', Icons.grid_off)
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text('Spot Code'),
                        ), // Now 1-1, 2-1, etc.
                        DataColumn(label: Text('Lot Name')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Vehicle Number')),
                        DataColumn(label: Text('Parking Since')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: spotsWithDetails.map<DataRow>((spot) {
                        final spotCode =
                            spot['spotCode'] ?? 'N/A'; // Computed as "1-1"
                        final status = spot['status'] ?? 'Available';
                        final user = spot['username'] ?? '-';
                        final vehicle = spot['vehicleNumber'] ?? '-';
                        final parkingTime = spot['parkingTimestamp'] ?? '-';
                        return DataRow(
                          cells: [
                            DataCell(Text(spotCode)),
                            DataCell(Text(spot['primeLocationName'] ?? 'N/A')),
                            DataCell(Text(status)),
                            DataCell(Text(user)),
                            DataCell(Text(vehicle)),
                            DataCell(Text(parkingTime)),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.details, color: Colors.blue),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SpotDetailsScreen(
                                      spotId: spot['_id'] ?? spot['id'],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // In lib/screens/admin_dashboard_screen.dart, replace the _buildRevenueTab method with this (maps IDs to sequential numbers):

  Widget _buildRevenueTab() {
    final userRevenuesRaw = summary['userRevenues'] ?? [];
    final lotRevenuesRaw = summary['lotRevenues'] ?? [];
    final totalRevenue = (summary['totalRevenue'] ?? 0).toDouble();
    final occupiedSpots = (summary['occupiedSpots'] ?? 0).toDouble();
    final availableSpots = (summary['availableSpots'] ?? 0).toDouble();

    // Handle array format from backend
    final userList = userRevenuesRaw is List
        ? userRevenuesRaw.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    final lotList = lotRevenuesRaw is List
        ? lotRevenuesRaw.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green.shade600, size: 28),
                SizedBox(width: 12),
                Text(
                  'Revenue Statistics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                    SizedBox(height: 24),
                    // Occupied / Available spots overview
                    Row(
                      children: [
                        Icon(Icons.local_parking, color: Colors.blue.shade600, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Spot Occupancy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: DoughnutChart(
                            occupied: occupiedSpots,
                            available: availableSpots,
                          ),
                        ),
                        SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Occupied: ${occupiedSpots.toInt()}',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Available: ${availableSpots.toInt()}',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Users Revenue Table
                    Text(
                      'Registered Users Revenue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (userList.isEmpty)
                      Text('No user revenue data available.')
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(
                              label: Text(
                                'User #',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ), // Sequential number
                            DataColumn(
                              label: Text(
                                'Username',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Revenue',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: userList.asMap().entries.take(10).map<DataRow>((
                            entry,
                          ) {
                            final index = entry.key + 1; // Sequential 1,2,3...
                            final user = entry.value;
                            final username = user['username'] ?? 'Unknown';
                            final revenue =
                                (user['revenue'] as num?)?.toDouble() ?? 0.0;
                            return DataRow(
                              cells: [
                                DataCell(Text('$index')), // Sequential ID
                                DataCell(Text(username)),
                                DataCell(
                                  Text('₹${revenue.toStringAsFixed(2)}'),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(height: 24),
                    // Lots Revenue Table
                    Text(
                      'Lot Revenue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (lotList.isEmpty)
                      Text('No lot revenue data available.')
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(
                              label: Text(
                                'Lot #',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ), // Sequential number
                            DataColumn(
                              label: Text(
                                'Lot Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Revenue',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: lotList.asMap().entries.take(10).map<DataRow>((
                            entry,
                          ) {
                            final index = entry.key + 1; // Sequential 1,2,3...
                            final lot = entry.value;
                            final lotName = lot['lotName'] ?? 'Unknown';
                            final revenue =
                                (lot['revenue'] as num?)?.toDouble() ?? 0.0;
                            return DataRow(
                              cells: [
                                DataCell(Text('$index')), // Sequential ID
                                DataCell(Text(lotName)),
                                DataCell(
                                  Text('₹${revenue.toStringAsFixed(2)}'),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteLot(String id) async {
    final token = context.read<AuthService>().token;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lot?'),
        content: const Text(
          'This will delete the lot and all spots/reservations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ApiService.deleteParkingLot(id, token: token);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lot deleted!')));
        _loadData();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Delete failed.')));
      }
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey.shade400),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// Move DoughnutChart outside the main class
class DoughnutChart extends StatelessWidget {
  final double occupied;
  final double available;

  const DoughnutChart({
    super.key,
    required this.occupied,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: occupied,
            color: const Color(0xFFFF6B6B),
            title: '${occupied.toInt()}',
            titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          PieChartSectionData(
            value: available,
            color: const Color(0xFF4CAF50),
            title: '${available.toInt()}',
            titleStyle: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
