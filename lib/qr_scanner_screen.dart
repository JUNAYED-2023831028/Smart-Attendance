import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'db_service.dart';

class QrScannerScreen extends StatefulWidget {
  final String studentUid;
  const QrScannerScreen({super.key, required this.studentUid});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final DbService _dbService = DbService();
  bool isScanned = false;

  void onDetect(BarcodeCapture capture) async {
    if (isScanned == true) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() { isScanned = true; });

        await _dbService.markAttendance(code, widget.studentUid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance Marked!")),
        );
        
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code'), backgroundColor: Colors.blue),
      body: MobileScanner(
        onDetect: onDetect,
      ),
    );
  }
}