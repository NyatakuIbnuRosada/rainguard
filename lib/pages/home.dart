import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'detail.dart';
import 'profile.dart';
import '../services/session_service.dart';
import '../services/premium_service.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String status = "-";
  String intensity = "-";
  String lastStatus = "-";
  Timer? timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isRefreshing = false;

  final String apiUrl = "http://192.168.3.253/rain_iot/get_latest.php";

  @override
  void initState() {
    super.initState();
    
    // Setup animasi
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    getData();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      getData();
    });
  }

  Future<void> getData() async {
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (status != data['status'] && data['status'] == "HUJAN") {
          await NotificationService.showRainAlert(
            data['intensity'].toString(),
          );
        }

        setState(() {
          status = data['status'];
          intensity = data['intensity'].toString();
        });
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await getData();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void logout() async {
    await SessionService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  void openDetail() {
    if (!PremiumService.isPremiumActive()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text("Fitur premium, silakan upgrade")),
            ],
          ),
          backgroundColor: Colors.blue[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DetailPage()),
    );
  }

  Widget _buildWeatherCard() {
    final bool isRaining = status == "HUJAN";
    final Color primaryColor = isRaining ? Colors.blue[700]! : Colors.orange[700]!;
    final Color secondaryColor = isRaining ? Colors.lightBlue[100]! : Colors.orange[50]!;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isRaining ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              isRaining ? Colors.blue[500]! : Colors.orange[500]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Icon dengan animasi
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRaining ? Icons.cloud : Icons.wb_sunny,
                size: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // Status Text
            Text(
              status,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            
            // Intensitas dengan progress bar
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Intensitas Hujan",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        "$intensity%",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: double.tryParse(intensity) != null 
                        ? double.parse(intensity) / 100 
                        : 0,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isRaining ? Colors.lightBlue[200]! : Colors.orange[200]!,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            
            // Update Time
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.update,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "Update real-time",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          elevation: 3,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isPremium && !PremiumService.isPremiumActive())
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[700],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Premium",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.blue[600],
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header dengan gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[700]!,
                      Colors.lightBlue[400]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "RainGuard",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Smart Rain Monitoring",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: logout,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Status Cuaca Saat Ini",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Weather Card
              _buildWeatherCard(),
              
              // Action Buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.analytics,
                          title: "Detail Data",
                          subtitle: "Analisis lengkap",
                          color: Colors.purple,
                          onTap: openDetail,
                          isPremium: true,
                        ),
                        _buildActionButton(
                          icon: Icons.person,
                          title: "Profile",
                          subtitle: "Akun & pengaturan",
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            );
                          },
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
              
              // Info Panel
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Informasi Sistem",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoItem(
                      icon: Icons.cloud_queue,
                      title: "Mode Deteksi",
                      value: "Real-time Monitoring",
                    ),
                    _buildInfoItem(
                      icon: Icons.update,
                      title: "Update Interval",
                      value: "1 Detik",
                    ),
                    _buildInfoItem(
                      icon: Icons.shield,
                      title: "Keamanan",
                      value: "System Active",
                    ),
                    _buildInfoItem(
                      icon: PremiumService.isPremiumActive() 
                          ? Icons.star 
                          : Icons.star_border,
                      title: "Premium Status",
                      value: PremiumService.isPremiumActive() 
                          ? "Active" 
                          : "Not Active",
                      valueColor: PremiumService.isPremiumActive()
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(15),
                child: Text(
                  "RainGuard IoT System • ${DateTime.now().year}",
                  style: TextStyle(
                    color: Colors.blueGrey[400],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating Action Button untuk refresh manual
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 5,
        child: _isRefreshing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = Colors.blueGrey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blueGrey[400],
            size: 20,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}