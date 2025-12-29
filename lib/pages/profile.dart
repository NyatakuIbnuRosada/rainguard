import 'dart:async';
import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/premium_service.dart';
import 'payment.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  Timer? timer;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Setup animasi untuk premium badge
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _formatRemainingTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

 Widget _buildProfileHeader() {
  final username = SessionService.username;
  
  // Handle null atau empty username
  String getInitials() {
    if (username == null || username.isEmpty) {
      return "U";
    }
    return username.substring(0, 1).toUpperCase();
  }

  String getDisplayName() {
    if (username == null || username.isEmpty) {
      return "Guest User";
    }
    return username;
  }

  return Container(
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
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
             
            ],
          ),
          const SizedBox(height: 20),
          
          // Avatar dengan initials
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                getInitials(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            getDisplayName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 5),
          
          Text(
            "Rain IoT User",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPremiumCard(bool isPremium, int remainingSeconds) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [Colors.blue[800]!, Colors.purple[700]!]
              : [Colors.blueGrey[600]!, Colors.blueGrey[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? Colors.blue : Colors.blueGrey).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isPremium ? _pulseAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPremium ? Icons.star : Icons.star_border,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? "PREMIUM USER" : "FREE USER",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isPremium
                          ? "Akses penuh semua fitur"
                          : "Fitur terbatas",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (isPremium) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.yellow[200],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Sisa Waktu",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatRemainingTime(remainingSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureList(bool isPremium) {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.analytics,
        'title': 'Detail Analytics',
        'description': 'Akses data sensor lengkap',
        'isPremium': true,
      },
      {
        'icon': Icons.history,
        'title': 'Riwayat Data',
        'description': 'Histori monitoring 30 hari',
        'isPremium': true,
      },
      {
        'icon': Icons.notifications,
        'title': 'Notifikasi',
        'description': 'Alert hujan real-time',
        'isPremium': false,
      },
      {
        'icon': Icons.cloud,
        'title': 'Status Cuaca',
        'description': 'Monitoring real-time',
        'isPremium': false,
      },
      {
        'icon': Icons.download,
        'title': 'Ekspor Data',
        'description': 'Download laporan PDF/CSV',
        'isPremium': true,
      },
      {
        'icon': Icons.settings,
        'title': 'Pengaturan',
        'description': 'Konfigurasi sistem',
        'isPremium': false,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fitur Akses",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              final bool featureIsPremium = feature['isPremium'] as bool;
              final bool isLocked = featureIsPremium && !isPremium;

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isLocked
                          ? Colors.grey[300]!
                          : Colors.blue[50]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? Colors.grey[100]!
                                  : Colors.blue[50]!,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              feature['icon'] as IconData,
                              color: isLocked
                                  ? Colors.grey[400]!
                                  : Colors.blue[600]!,
                              size: 24,
                            ),
                          ),
                          if (featureIsPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? Colors.grey[100]!
                                    : Colors.amber[50]!,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: isLocked
                                        ? Colors.grey[400]!
                                        : Colors.amber[600]!,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Premium",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isLocked
                                          ? Colors.grey[600]!
                                          : Colors.amber[800]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? Colors.grey[500]!
                              : Colors.blueGrey[800]!,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        feature['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLocked
                              ? Colors.grey[400]!
                              : Colors.blueGrey[500]!,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Kunci",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Colors.amber.withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, size: 24),
                  SizedBox(width: 10),
                  Text(
                    "UPGRADE TO PREMIUM",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Premium membuka akses fitur detail sensor dan analisis lengkap",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = PremiumService.isPremiumActive();
    final remaining = PremiumService.remainingSeconds();

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan avatar
            _buildProfileHeader(),
            
            // Premium Card
            _buildPremiumCard(isPremium, remaining),
            
            // Fitur Akses
            _buildFeatureList(isPremium),
            
            // Upgrade Button (hanya untuk free user)
            if (!isPremium) _buildUpgradeButton(),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Divider(
                    color: Colors.blueGrey[200],
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "RainGuard IoT System v1.0",
                    style: TextStyle(
                      color: Colors.blueGrey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "© ${DateTime.now().year} All rights reserved",
                    style: TextStyle(
                      color: Colors.blueGrey[300],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}