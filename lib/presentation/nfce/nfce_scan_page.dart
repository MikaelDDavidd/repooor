import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/dev/mock_nfce_samples.dart';
import '../../domain/exceptions/nfce_exception.dart';
import '../providers/nfce_providers.dart';
import '../shared/widgets/app_loading_state.dart';
import 'widgets/camera_permission_denied_view.dart';
import 'widgets/qr_scanner_view.dart';

class NfceScanPage extends ConsumerStatefulWidget {
  const NfceScanPage({super.key});

  @override
  ConsumerState<NfceScanPage> createState() => _NfceScanPageState();
}

class _NfceScanPageState extends ConsumerState<NfceScanPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  PermissionStatus? _permissionStatus;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final current = await Permission.camera.status;
    final status = current.isDenied
        ? await Permission.camera.request()
        : current;
    if (!mounted) return;
    setState(() => _permissionStatus = status);
  }

  Future<void> _onDetected(String raw) async {
    if (_handled) return;
    _handled = true;
    await _controller.stop();
    await ref.read(nfceImportProvider.notifier).onQrDetected(raw);
    if (!mounted) return;
    final state = ref.read(nfceImportProvider);
    if (state is NfceFailure) {
      final exception = state.exception;
      if (exception is NfceUnsupportedStateException) {
        context.go('/nfce/unsupported/${exception.uf}');
        return;
      }
      if (exception is NfceInvalidQrException) {
        _handled = false;
        await _controller.start();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(exception.message),
          ),
        );
        return;
      }
    }
    context.go('/nfce/review');
  }

  Future<void> _loadMockSample() async {
    final sample = await showModalBottomSheet<MockNfceSample>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Simular NFC-e (debug)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            for (final s in mockNfceSamples)
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(s.label),
                onTap: () => Navigator.of(context).pop(s),
              ),
          ],
        ),
      ),
    );
    if (sample == null || !mounted) return;
    await ref
        .read(nfceImportProvider.notifier)
        .loadMockHtml(uf: sample.uf, chave: sample.chave, html: sample.html);
    if (mounted) context.go('/nfce/review');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Escanear cupom fiscal'),
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              heroTag: 'nfce_mock_fab',
              onPressed: _loadMockSample,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Simular NFC-e'),
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final status = _permissionStatus;
    if (status == null) return const AppLoadingState();
    if (status.isGranted) {
      return QrScannerView(controller: _controller, onDetect: _onDetected);
    }
    return CameraPermissionDeniedView(
      permanent: status.isPermanentlyDenied || status.isRestricted,
      onRetry: _checkPermission,
    );
  }
}
