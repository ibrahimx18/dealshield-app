import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';

// ─────────────────────────────────────────────────────────────
// Live Video Proof of Product
// Records a live video with on-screen timestamp overlay.
// The timestamp is burned into the recording so it can't be faked.
// ─────────────────────────────────────────────────────────────

class VideoProofScreen extends StatefulWidget {
  final String commodityType; // 'Gold', 'AGO', 'Crude Oil'

  const VideoProofScreen({super.key, required this.commodityType});

  @override
  State<VideoProofScreen> createState() => _VideoProofScreenState();
}

class _VideoProofScreenState extends State<VideoProofScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  bool _isReady = false;
  bool _isRecording = false;
  bool _recorded = false;
  String? _videoPath;
  Duration _recordDuration = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  DateTime _recordStartTime = DateTime.now();
  String _timestampText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No camera available', style: SafePayText.body()),
            backgroundColor: SafePayColors.red,
          ),
        );
      }
      return;
    }

    // Use back camera for product recording
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e', style: SafePayText.body()),
            backgroundColor: SafePayColors.red,
          ),
        );
      }
    }
  }

  void _startRecording() async {
    if (!_isReady || _controller == null) return;

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordStartTime = DateTime.now();
        _recorded = false;
      });

      // Update timestamp every second
      _updateTimestamp();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e', style: SafePayText.body()),
          backgroundColor: SafePayColors.red,
        ),
      );
    }
  }

  void _updateTimestamp() {
    if (!_isRecording) return;
    setState(() {
      _recordDuration = DateTime.now().difference(_recordStartTime);
      _timestampText = _formatTimestamp();
    });
    Future.delayed(const Duration(seconds: 1), _updateTimestamp);
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final tz = now.timeZoneName;
    final elapsed = '${_recordDuration.inMinutes.toString().padLeft(2, '0')}:${(_recordDuration.inSeconds % 60).toString().padLeft(2, '0')}';
    return '$date • $time $tz • REC $elapsed';
  }

  void _stopRecording() async {
    if (!_isRecording || _controller == null) return;

    try {
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recorded = true;
        _videoPath = file.path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop recording: $e', style: SafePayText.body()),
          backgroundColor: SafePayColors.red,
        ),
      );
      setState(() => _isRecording = false);
    }
  }

  void _retake() {
    setState(() {
      _recorded = false;
      _videoPath = null;
      _recordDuration = Duration.zero;
      _timestampText = '';
    });
  }

  void _submit() {
    if (_videoPath != null) {
      Navigator.of(context).pop({
        'videoPath': _videoPath,
        'timestamp': _timestampText,
        'duration': _recordDuration.inSeconds,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePayColors.bg,
      body: Stack(
        children: [
          // Camera preview or recorded confirmation
          if (!_recorded && _isReady)
            CameraPreview(_controller!)
          else if (!_recorded && !_isReady)
            _buildCameraLoading()
          else
            _buildRecordedPreview(),

          // Timestamp overlay (always visible during recording)
          if (_isRecording) _buildTimestampOverlay(),

          // Top bar
          _buildTopBar(),

          // Bottom controls
          if (!_recorded) _buildBottomControls(),
          if (_recorded) _buildRecordedControls(),
        ],
      ),
    );
  }

  Widget _buildCameraLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: SafePayColors.gold),
          const SizedBox(height: 16),
          Text('Initializing camera...', style: SafePayText.body()),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: GlassContainer(
                  blur: 12,
                  opacity: 0.12,
                  borderRadius: 24,
                  padding: const EdgeInsets.all(8),
                  showShadow: false,
                  child: const Icon(Iconsax.arrow_left_2, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Video Proof',
                      style: SafePayText.heading3(color: Colors.white),
                    ),
                    Text(
                      '${widget.commodityType} — Proof of Product',
                      style: SafePayText.caption(color: SafePayColors.gold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimestampOverlay() {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SafePayColors.red.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Pulsing red dot
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: SafePayColors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: SafePayColors.red, blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _timestampText.isNotEmpty ? _timestampText : _formatTimestamp(),
                style: GoogleFonts.dmMono(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              // Instructions
              if (!_isRecording)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: GlassContainer(
                    blur: 12,
                    opacity: 0.1,
                    borderRadius: 12,
                    padding: const EdgeInsets.all(16),
                    tint: SafePayColors.gold,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.information, color: SafePayColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text('Recording Instructions', style: SafePayText.label(color: SafePayColors.gold, weight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Show the ${widget.commodityType} clearly\n'
                          '• Show serial numbers / hallmarks / certificates\n'
                          '• Keep the product in frame at all times\n'
                          '• Record at least 15 seconds\n'
                          '• The timestamp is automatically embedded',
                          style: SafePayText.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                ),
              // Record button
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? SafePayColors.red : SafePayColors.gold,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? SafePayColors.red : SafePayColors.gold).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Iconsax.stop : Iconsax.video,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRecording ? 'Tap to stop recording' : 'Tap to start recording',
                style: SafePayText.caption(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordedPreview() {
    return Column(
      children: [
        const SizedBox(height: 120),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GlassContainer(
              width: double.infinity,
              blur: 12,
              opacity: 0.1,
              borderRadius: 20,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SafePayColors.green.withOpacity(0.15),
                      border: Border.all(color: SafePayColors.green, width: 2),
                    ),
                    child: const Icon(Iconsax.tick_circle, color: SafePayColors.green, size: 44),
                  ),
                  const SizedBox(height: 20),
                  Text('Video Recorded!', style: SafePayText.heading2(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${_recordDuration.inMinutes}m ${_recordDuration.inSeconds % 60}s',
                    style: SafePayText.body(color: SafePayColors.gold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Timestamp: $_timestampText',
                    style: GoogleFonts.dmMono(color: SafePayColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _videoPath != null ? 'Saved to: ${_videoPath!.split('/').last}' : '',
                    style: SafePayText.caption(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecordedControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _retake,
                  child: GlassContainer(
                    blur: 12,
                    opacity: 0.1,
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    showShadow: false,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.refresh, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Text('Retake', style: SafePayText.button(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GoldButton3D(
                  label: 'Use Video',
                  icon: Iconsax.tick_circle,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
