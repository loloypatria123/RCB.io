import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _cardBg = Color(0xFF131820);
const Color _accentPrimary = Color(0xFF00D9FF);
const Color _accentSecondary = Color(0xFF1E90FF);
const Color _warningColor = Color(0xFFFF6B35);
const Color _successColor = Color(0xFF00FF88);
const Color _errorColor = Color(0xFFFF3333);
const Color _textPrimary = Color(0xFFE8E8E8);
const Color _textSecondary = Color(0xFF8A8A8A);

class AdminConnectivitySettings extends StatefulWidget {
  const AdminConnectivitySettings({super.key});

  @override
  State<AdminConnectivitySettings> createState() =>
      _AdminConnectivitySettingsState();
}

class DeviceData {
  final String id, name, type, status;
  final String signalStrength;

  DeviceData({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.signalStrength,
  });
}

class _AdminConnectivitySettingsState extends State<AdminConnectivitySettings> {
  String _selectedSSID = 'RoboClean-Network';
  String _deviceName = 'RoboClean-Admin-Panel';
  bool _wifiConnected = true;
  bool _bluetoothEnabled = true;

  final List<DeviceData> pairedDevices = [
    DeviceData(
      id: 'ROBOT-001',
      name: 'RoboClean Alpha',
      type: 'Robot',
      status: 'Connected',
      signalStrength: '95%',
    ),
    DeviceData(
      id: 'ROBOT-002',
      name: 'RoboClean Beta',
      type: 'Robot',
      status: 'Connected',
      signalStrength: '87%',
    ),
    DeviceData(
      id: 'ROBOT-003',
      name: 'RoboClean Gamma',
      type: 'Robot',
      status: 'Disconnected',
      signalStrength: '0%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connectivity Settings',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 24),
          _buildConnectionStatusCards(),
          const SizedBox(height: 24),
          _buildWiFiSection(),
          const SizedBox(height: 24),
          _buildBluetoothSection(),
          const SizedBox(height: 24),
          _buildDeviceNameSection(),
          const SizedBox(height: 24),
          _buildPairedDevicesSection(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'WiFi Status',
            _wifiConnected ? 'Connected' : 'Disconnected',
            Icons.wifi,
            _wifiConnected ? _successColor : _errorColor,
            _wifiConnected ? 'Signal: Strong' : 'No connection',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Bluetooth Status',
            _bluetoothEnabled ? 'Enabled' : 'Disabled',
            Icons.bluetooth,
            _bluetoothEnabled ? _successColor : _warningColor,
            _bluetoothEnabled ? '3 devices paired' : 'Disabled',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Connected Devices',
            '${pairedDevices.where((d) => d.status == 'Connected').length}',
            Icons.devices,
            _accentPrimary,
            'of ${pairedDevices.length} total',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: _textSecondary),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  Widget _buildWiFiSection() {
    return _buildSettingsCard(
      title: 'WiFi Configuration',
      icon: Icons.wifi,
      color: _accentPrimary,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network SSID',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _accentPrimary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSSID,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: _accentPrimary, size: 18),
                    onPressed: () => _showWiFiConfigDialog(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WiFi Password',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _accentPrimary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '••••••••••',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: _accentPrimary, size: 18),
                    onPressed: () => _showWiFiConfigDialog(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showTestConnectionDialog(),
          icon: const Icon(Icons.signal_cellular_alt),
          label: Text(
            'Test WiFi Connection',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentPrimary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBluetoothSection() {
    return _buildSettingsCard(
      title: 'Bluetooth Configuration',
      icon: Icons.bluetooth,
      color: _accentSecondary,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bluetooth Status',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Currently: ${_bluetoothEnabled ? 'Enabled' : 'Disabled'}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            Switch(
              value: _bluetoothEnabled,
              onChanged: (value) => setState(() => _bluetoothEnabled = value),
              activeColor: _accentSecondary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _successColor, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: _successColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bluetooth range: 100 meters',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _successColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceNameSection() {
    return _buildSettingsCard(
      title: 'Device Name Setup',
      icon: Icons.devices,
      color: _warningColor,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Name',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _warningColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _deviceName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: _warningColor, size: 18),
                    onPressed: () => _showDeviceNameDialog(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _accentPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _accentPrimary, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: _accentPrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Device name is used for identification on the network',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPairedDevicesSection() {
    return _buildSettingsCard(
      title: 'Paired Devices',
      icon: Icons.devices_other,
      color: _successColor,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...pairedDevices.map((device) => _buildDeviceItem(device)),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddDeviceDialog(),
          icon: const Icon(Icons.add),
          label: Text(
            'Add New Device',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _successColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceItem(DeviceData device) {
    final isConnected = device.status == 'Connected';
    final statusColor = isConnected ? _successColor : _errorColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor, width: 0.5),
                      ),
                      child: Text(
                        device.status,
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.signal_cellular_alt,
                      color: _accentPrimary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      device.signalStrength,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleDeviceAction(value, device),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    const Icon(Icons.signal_cellular_alt, size: 16),
                    const SizedBox(width: 8),
                    Text('Test Connection', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 16, color: _errorColor),
                    const SizedBox(width: 8),
                    Text(
                      'Remove Device',
                      style: GoogleFonts.poppins(color: _errorColor),
                    ),
                  ],
                ),
              ),
            ],
            color: _cardBg,
            icon: Icon(Icons.more_vert, color: _accentPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _showWiFiConfigDialog() {
    final ssidController = TextEditingController(text: _selectedSSID);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'WiFi Configuration',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Network SSID', ssidController),
              const SizedBox(height: 12),
              _buildTextField(
                'WiFi Password',
                passwordController,
                obscure: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'WiFi configuration updated',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Test WiFi Connection',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _successColor, width: 0.5),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: _successColor, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Connection Successful',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _successColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Signal Strength: 95%\nSpeed: 54 Mbps\nLatency: 12ms',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceNameDialog() {
    final nameController = TextEditingController(text: _deviceName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Edit Device Name',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_buildTextField('Device Name', nameController)],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Device name updated',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _warningColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          'Add New Device',
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Enable Bluetooth on your device and make it discoverable. The device will appear in the list automatically.',
          style: GoogleFonts.poppins(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Scanning for devices...',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: _accentPrimary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _successColor,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Start Scan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeviceAction(String action, DeviceData device) {
    if (action == 'test') {
      _showTestConnectionDialog();
    } else if (action == 'remove') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _cardBg,
          title: Text(
            'Remove Device',
            style: GoogleFonts.poppins(
              color: _errorColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Remove ${device.name} from paired devices?',
            style: GoogleFonts.poppins(color: _textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: _textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Device removed',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: _errorColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: _textSecondary),
        filled: true,
        fillColor: Color(0xFF0A0E1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentPrimary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentPrimary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
