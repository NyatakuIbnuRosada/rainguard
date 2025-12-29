import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/premium_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Timer? timer;
  List<dynamic> _historyData = [];
  bool _isLoading = true;
  bool _hasError = false;

  final String apiUrl = "http://192.168.3.253/rain_iot/get_history.php";

  Future<void> fetchHistory() async {
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _historyData = data;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
    
    // Auto refresh setiap 5 detik
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (PremiumService.isPremiumActive()) {
        fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _buildPremiumRequiredScreen() {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[700]!,
                      Colors.lightBlue[400]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              
              // Title
              Text(
                "Premium Required",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Message
              Text(
                "Akses fitur lengkap analisis data hujan dengan upgrade ke Mode Pro",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[600],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Features List
              Container(
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
                  children: [
                    _buildFeatureItem(
                      icon: Icons.analytics,
                      title: "Analisis Lengkap",
                      description: "Data historis detail",
                    ),
                    _buildFeatureItem(
                      icon: Icons.timeline,
                      title: "Grafik Real-time",
                      description: "Visualisasi data interaktif",
                    ),
                    _buildFeatureItem(
                      icon: Icons.download,
                      title: "Ekspor Data",
                      description: "Download laporan PDF/CSV",
                    ),
                    _buildFeatureItem(
                      icon: Icons.notifications_active,
                      title: "Notifikasi Canggih",
                      description: "Alert & prediksi hujan",
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Upgrade Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Tambahkan navigasi ke halaman upgrade premium
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
                    
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Back Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Kembali ke Beranda",
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green[400],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data, int index) {
    final bool isRaining = data['status'] == "HUJAN";
    final DateTime dateTime = DateTime.parse(data['created_at']);
    final String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final String formattedTime = DateFormat('HH:mm:ss').format(dateTime);
    final String intensity = data['intensity']?.toString() ?? "0";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Tampilkan detail lebih lanjut
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isRaining
                    ? Colors.blue[100]!
                    : Colors.orange[100]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Status Indicator
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isRaining
                        ? Colors.blue[50]!
                        : Colors.orange[50]!,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRaining ? Icons.cloud : Icons.wb_sunny,
                    color: isRaining ? Colors.blue[600] : Colors.orange[600],
                    size: 30,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['status'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isRaining
                                  ? Colors.blue[800]
                                  : Colors.orange[800],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isRaining
                                  ? Colors.blue[50]!
                                  : Colors.orange[50]!,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$intensity%",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isRaining
                                    ? Colors.blue[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.blueGrey[400],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey[500],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.blueGrey[400],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey[500],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Progress Bar
                      LinearProgressIndicator(
                        value: double.tryParse(intensity) != null
                            ? double.parse(intensity) / 100
                            : 0,
                        backgroundColor: Colors.blueGrey[100],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isRaining
                              ? Colors.blue[400]!
                              : Colors.orange[400]!,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Chevron Icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.blueGrey[300],
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTimer() {
    final remainingSeconds = PremiumService.remainingSeconds();
    final int hours = remainingSeconds ~/ 3600;
    final int minutes = (remainingSeconds % 3600) ~/ 60;
    final int seconds = remainingSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[700]!,
            Colors.lightBlue[500]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Premium: ${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 100,
              color: Colors.blueGrey[300],
            ),
            const SizedBox(height: 20),
            Text(
              "Belum Ada Data Riwayat",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Data riwayat akan muncul setelah sistem melakukan monitoring",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[500],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: fetchHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text("Refresh Data"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!PremiumService.isPremiumActive()) {
      return _buildPremiumRequiredScreen();
    }

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
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
                      _buildPremiumTimer(),
                      IconButton(
                        onPressed: fetchHistory,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Riwayat Data Hujan",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Analisis detail data historis cuaca",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Statistics Summary
                  
                ],
              ),
            ),
          ),
          
          // History List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Memuat data riwayat...",
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Gagal memuat data",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: fetchHistory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Coba Lagi"),
                            ),
                          ],
                        ),
                      )
                    : _historyData.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: fetchHistory,
                            color: Colors.blue[600],
                            backgroundColor: Colors.white,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _historyData.length,
                              itemBuilder: (context, index) =>
                                  _buildHistoryItem(
                                _historyData[index],
                                index,
                              ),
                            ),
                          ),
          ),
        ],
      ),
      
      // Floating Action Button untuk filter/ekspor
     
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}