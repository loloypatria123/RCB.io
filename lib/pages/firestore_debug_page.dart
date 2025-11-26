import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_verification_service.dart';

class FirestoreDebugPage extends StatefulWidget {
  const FirestoreDebugPage({super.key});

  @override
  State<FirestoreDebugPage> createState() => _FirestoreDebugPageState();
}

class _FirestoreDebugPageState extends State<FirestoreDebugPage> {
  String _output = '';
  bool _isLoading = false;

  void _addOutput(String text) {
    setState(() {
      _output += '$text\n';
    });
    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Scroll to bottom
      }
    });
  }

  Future<void> _verifyFirestore() async {
    setState(() {
      _output = '';
      _isLoading = true;
    });

    try {
      _addOutput('🔍 Starting Firestore verification...\n');
      await FirestoreVerificationService.verifyAndFixFirestore();
      _addOutput('\n✅ Verification completed!');
    } catch (e) {
      _addOutput('❌ Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _printSummary() async {
    setState(() {
      _output = '';
      _isLoading = true;
    });

    try {
      _addOutput('📊 Fetching Firestore summary...\n');
      await FirestoreVerificationService.printSummary();
      _addOutput('\n✅ Summary completed!');
    } catch (e) {
      _addOutput('❌ Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        title: Text(
          'Firestore Debug',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _verifyFirestore,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Verify & Fix Firestore'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _printSummary,
                  icon: const Icon(Icons.info),
                  label: const Text('Print Summary'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _output = '';
                          });
                        },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Output'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
          // Output
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _output.isEmpty
                            ? 'Output will appear here...'
                            : _output,
                        style: GoogleFonts.robotoMono(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
