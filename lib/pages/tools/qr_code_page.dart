import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController(text: 'https://github.com');
  String _qrData = 'https://github.com';
  int _qrVersion = QrVersions.auto;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: '生成'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: '扫描'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateTab(theme),
          _buildScanTab(theme),
        ],
      ),
    );
  }

  Widget _buildGenerateTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: '输入内容',
              hintText: '输入文本、URL、电话等',
              prefixIcon: Icon(Icons.edit),
            ),
            maxLines: 3,
            minLines: 1,
            onChanged: (v) => setState(() => _qrData = v),
          ),
          const SizedBox(height: 8),
          // Quick templates
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ActionChip(
                avatar: const Icon(Icons.link, size: 16),
                label: const Text('URL'),
                onPressed: () {
                  _textController.text = 'https://';
                  setState(() => _qrData = 'https://');
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.email, size: 16),
                label: const Text('邮箱'),
                onPressed: () {
                  _textController.text = 'mailto:example@email.com';
                  setState(() => _qrData = _textController.text);
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.phone, size: 16),
                label: const Text('电话'),
                onPressed: () {
                  _textController.text = 'tel:+86';
                  setState(() => _qrData = _textController.text);
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.wifi, size: 16),
                label: const Text('WiFi'),
                onPressed: () {
                  _textController.text = 'WIFI:T:WPA;S:网络名;P:密码;;';
                  setState(() => _qrData = _textController.text);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // QR code display
          if (_qrData.isNotEmpty)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: QrImageView(
                  data: _qrData,
                  version: _qrVersion,
                  size: 250,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _qrData));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('复制内容'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Share.share(_qrData);
                },
                icon: const Icon(Icons.share),
                label: const Text('分享'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '二维码扫描',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              '需要相机权限才能使用扫描功能\n请在真机上测试此功能',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请在真机上使用扫描功能')),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('打开扫描器'),
            ),
          ],
        ),
      ),
    );
  }
}
