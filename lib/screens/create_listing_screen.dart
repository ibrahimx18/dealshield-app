import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';
import 'video_proof_screen.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  CommodityCategory _category = CommodityCategory.cars;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _insure = false;
  bool _posting = false;

  // Cars-specific
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  String _carCondition = 'Clean Used';

  // Gold-specific
  String _goldKarat = '22K (916)';
  final _goldWeightCtrl = TextEditingController();
  final _goldQtyCtrl = TextEditingController();
  String _goldForm = 'Bar';

  // Oil-specific
  String _oilType = 'AGO (Diesel)';
  final _oilVolumeCtrl = TextEditingController();
  final _oilLocationCtrl = TextEditingController();
  String _oilIncoterm = 'EXW';

  // Land-specific
  final _landSizeCtrl = TextEditingController();
  String _landTitle = 'C of O';
  final _landStateCtrl = TextEditingController();
  String _landType = 'Residential';

  // Dollars-specific
  String _dollarForm = 'Bank Transfer';
  final _dollarAmountCtrl = TextEditingController();
  final _dollarRateCtrl = TextEditingController();
  String _dollarPayment = 'Bank';

  // Proof of Product
  String _proofDocType = '';
  final _proofDocNumberCtrl = TextEditingController();
  bool _proofUploaded = false;
  String _proofFileName = '';
  // Live video proof
  bool _videoRecorded = false;
  String _videoTimestamp = '';
  int _videoDuration = 0;
  String? _videoPath;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    _goldWeightCtrl.dispose();
    _goldQtyCtrl.dispose();
    _oilVolumeCtrl.dispose();
    _oilLocationCtrl.dispose();
    _landSizeCtrl.dispose();
    _landStateCtrl.dispose();
    _dollarAmountCtrl.dispose();
    _dollarRateCtrl.dispose();
    _proofDocNumberCtrl.dispose();
    super.dispose();
  }

  // Categories that require proof of product
  bool get _requiresProof =>
      _category == CommodityCategory.oil || _category == CommodityCategory.gold;

  List<String> get _proofDocTypes {
    if (_category == CommodityCategory.oil) {
      if (_oilType.contains('Crude')) {
        return ['NNPC Allocation Letter', 'Crude Oil Sales License', 'Terminal Operator License', 'Bill of Lading', 'SGS Inspection Report'];
      }
      return ['NNPC Allocation Letter', 'Refinery Dispatch Ticket', 'Depot Release Order', 'SGS/Intertek Inspection Report', 'Bill of Lading', 'Product Certificate'];
    }
    if (_category == CommodityCategory.gold) {
      return ['Assay Report (Hallmark)', 'LBMA Good Delivery Certificate', 'Refinery Certificate', 'Mining License', 'Customs Declaration', 'Jeweller Certificate'];
    }
    return [];
  }

  void _resetForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _priceCtrl.clear();
    _locationCtrl.clear();
    _makeCtrl.clear();
    _modelCtrl.clear();
    _yearCtrl.clear();
    _mileageCtrl.clear();
    _goldWeightCtrl.clear();
    _goldQtyCtrl.clear();
    _oilVolumeCtrl.clear();
    _oilLocationCtrl.clear();
    _landSizeCtrl.clear();
    _landStateCtrl.clear();
    _dollarAmountCtrl.clear();
    _dollarRateCtrl.clear();
    _proofDocNumberCtrl.clear();
    setState(() {
      _category = CommodityCategory.cars;
      _insure = false;
      _proofUploaded = false;
      _proofFileName = '';
      _proofDocType = '';
    });
  }

  String _buildDescription() {
    final parts = <String>[];
    switch (_category) {
      case CommodityCategory.cars:
        if (_makeCtrl.text.isNotEmpty) parts.add('Make: ${_makeCtrl.text}');
        if (_modelCtrl.text.isNotEmpty) parts.add('Model: ${_modelCtrl.text}');
        if (_yearCtrl.text.isNotEmpty) parts.add('Year: ${_yearCtrl.text}');
        if (_mileageCtrl.text.isNotEmpty) parts.add('Mileage: ${_mileageCtrl.text} km');
        parts.add('Condition: $_carCondition');
        break;
      case CommodityCategory.gold:
        parts.add('Karat: $_goldKarat');
        if (_goldWeightCtrl.text.isNotEmpty) parts.add('Weight: ${_goldWeightCtrl.text} kg');
        if (_goldQtyCtrl.text.isNotEmpty) parts.add('Quantity Available: ${_goldQtyCtrl.text} units');
        parts.add('Form: $_goldForm');
        break;
      case CommodityCategory.oil:
        parts.add('Type: $_oilType');
        if (_oilVolumeCtrl.text.isNotEmpty) parts.add('Volume: ${_oilVolumeCtrl.text} litres');
        parts.add('Incoterm: $_oilIncoterm');
        if (_oilLocationCtrl.text.isNotEmpty) parts.add('Pickup: ${_oilLocationCtrl.text}');
        break;
      case CommodityCategory.land:
        if (_landSizeCtrl.text.isNotEmpty) parts.add('Size: ${_landSizeCtrl.text} sqm');
        parts.add('Title: $_landTitle');
        parts.add('Type: $_landType');
        if (_landStateCtrl.text.isNotEmpty) parts.add('State: ${_landStateCtrl.text}');
        break;
      case CommodityCategory.cement:
        parts.add('Brand: Dangote / BUA / Lafarge');
        parts.add('Escrow Fee: ₦10 per bag flat rate');
        break;
      case CommodityCategory.dollars:
        if (_dollarAmountCtrl.text.isNotEmpty) parts.add('Amount: \$${_dollarAmountCtrl.text}');
        if (_dollarRateCtrl.text.isNotEmpty) parts.add('Rate: ₦${_dollarRateCtrl.text}/\$');
        parts.add('Form: $_dollarForm');
        parts.add('Payment: $_dollarPayment');
        break;
      case CommodityCategory.crypto:
        parts.add('Asset: USDT / BTC');
        parts.add('Escrow Fee: 0.5% flat rate');
        break;
      case CommodityCategory.giftcards:
        parts.add('Asset: Physical / E-code Card');
        parts.add('Escrow Fee: 1.0% flat rate');
        break;
    }
    // Add proof of product info
    if (_requiresProof && _proofDocType.isNotEmpty) {
      parts.add('\n── Proof of Product ──');
      parts.add('Document: $_proofDocType');
      if (_proofDocNumberCtrl.text.isNotEmpty) parts.add('Ref: ${_proofDocNumberCtrl.text}');
      if (_proofUploaded) parts.add('Status: Uploaded ✓ (Pending Verification)');
    }
    if (_category == CommodityCategory.gold && _videoRecorded) {
      parts.add('\n── Live Video Proof ──');
      parts.add('Timestamp: $_videoTimestamp');
      parts.add('Duration: ${_videoDuration}s');
      parts.add('Status: Recorded ✓');
    }
    if (_descCtrl.text.isNotEmpty) parts.add('\n${_descCtrl.text}');
    return parts.join('\n');
  }

  Future<void> _postListing() async {
    if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and price')),
      );
      return;
    }
    if (_requiresProof && (!_proofUploaded || _proofDocType.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proof of Product is required for ${_category == CommodityCategory.oil ? "oil/AGO" : "gold"} listings. Please upload verification document.'),
          backgroundColor: SafePayColors.red,
        ),
      );
      return;
    }
    // Gold requires live video proof
    if (_category == CommodityCategory.gold && !_videoRecorded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Live video proof is required for gold listings. Please record a video showing the gold with timestamp.'),
          backgroundColor: SafePayColors.red,
        ),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      final listing = Listing(
        id: '',
        category: _category,
        title: _titleCtrl.text,
        description: _buildDescription(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        location: _locationCtrl.text,
        sellerName: '',
        sellerRating: '5.0',
        verified: false,
        postedDate: DateTime.now(),
        insured: _insure,
        proofVerified: false,
        proofDocType: _proofDocType.isNotEmpty ? _proofDocType : null,
        proofDocNumber: _proofDocNumberCtrl.text.isNotEmpty ? _proofDocNumberCtrl.text : null,
        proofDocUrl: _proofUploaded ? _proofFileName : null,
      );
      await context.read<AppState>().addListing(listing);
      _resetForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_requiresProof
              ? '✓ Listing posted! Proof of Product submitted for verification. Buyers will see it once verified.'
              : '✓ Listing posted successfully!'),
            backgroundColor: SafePayColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: SafePayColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeshGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Post a Listing', style: SafePayText.heading3()),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Category selection
              Text('Select What You\'re Selling', style: SafePayText.label(weight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildCategoryGrid(),
              const SizedBox(height: 24),

              // Title
              GlassInput(controller: _titleCtrl, label: 'Listing Title', hint: _titleHint(), icon: Iconsax.edit),
              const SizedBox(height: 16),

              // Category-specific fields
              _buildCategoryFields(),

              // Price
              GlassInput(controller: _priceCtrl, label: _priceLabel(), hint: _priceHint(), icon: Iconsax.money, keyboard: TextInputType.number),
              const SizedBox(height: 16),

              // Location
              GlassInput(controller: _locationCtrl, label: _locationLabel(), hint: _locationHint(), icon: Iconsax.location),
              const SizedBox(height: 16),

              // Description
              GlassInput(controller: _descCtrl, label: 'Additional Description', hint: 'Any extra details...', icon: Iconsax.document_text, maxLines: 3),
              const SizedBox(height: 16),

              // Photo upload
              _buildPhotoUpload(),
              const SizedBox(height: 16),

              // Proof of Product (for oil & gold)
              if (_requiresProof) ...[
                _buildProofOfProduct(),
                const SizedBox(height: 16),
              ],

              // Insurance toggle
              GlassCard(
                glass: true,
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: Text('Insure this listing', style: SafePayText.body(weight: FontWeight.w600)),
                  subtitle: Text('Protect your goods with insurance partner (2% fee)', style: SafePayText.bodySmall()),
                  value: _insure,
                  activeTrackColor: SafePayColors.green,
                  onChanged: (v) => setState(() => _insure = v),
                ),
              ),
              const SizedBox(height: 24),

              // Post button
              GoldButton3D(
                label: _requiresProof ? 'Submit for Verification & Post' : 'Post Listing',
                icon: Iconsax.add_circle,
                loading: _posting,
                onPressed: _postListing,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Category Grid ───────────────────────────────────────────

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: CommodityCategory.values.length,
      itemBuilder: (context, index) {
        final cat = CommodityCategory.values[index];
        final selected = _category == cat;
        final requiresProof = cat == CommodityCategory.oil || cat == CommodityCategory.gold;

        return GestureDetector(
          onTap: () => setState(() {
            _category = cat;
            _proofDocType = '';
            _proofUploaded = false;
            _proofFileName = '';
          }),
          child: GlassContainer(
            blur: 8,
            opacity: selected ? 0.12 : 0.04,
            borderRadius: 14,
            padding: const EdgeInsets.all(8),
            showBorder: selected,
            showShadow: selected,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(cat.label, style: SafePayText.bodySmall(
                  color: selected ? SafePayColors.gold : SafePayColors.textSecondary,
                  weight: FontWeight.w600,
                )),
                if (requiresProof)
                  Text('Proof Required', style: SafePayText.caption(color: SafePayColors.gold.withOpacity(0.7))),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Proof of Product ───────────────────────────────────────

  Widget _buildProofOfProduct() {
    return GlassContainer(
      width: double.infinity,
      blur: 12,
      opacity: 0.08,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      tint: SafePayColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.shield_tick, color: SafePayColors.gold, size: 22),
              const SizedBox(width: 8),
              Text('Proof of Product', style: SafePayText.heading3(color: SafePayColors.gold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _category == CommodityCategory.oil
              ? 'Oil/AGO listings require verifiable proof. Upload an official document (allocation letter, dispatch ticket, inspection report).'
              : 'Gold listings require proof of authenticity. Upload assay report, refinery certificate, or LBMA certificate.',
            style: SafePayText.bodySmall(),
          ),
          const SizedBox(height: 16),

          // Document type dropdown
          Text('Document Type', style: SafePayText.label(weight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildProofDropdown(),
          const SizedBox(height: 16),

          // Document reference number
          GlassInput(
            controller: _proofDocNumberCtrl,
            label: 'Document Reference Number',
            hint: 'e.g. NNPC/ALLOC/2026/001',
            icon: Iconsax.document,
          ),
          const SizedBox(height: 16),

          // Upload button
          GestureDetector(
            onTap: () => _simulateUpload(),
            child: GlassContainer(
              width: double.infinity,
              blur: 8,
              opacity: _proofUploaded ? 0.06 : 0.04,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(vertical: 20),
              showShadow: false,
              child: Column(
                children: [
                  Icon(
                    _proofUploaded ? Iconsax.tick_circle : Iconsax.document_upload,
                    color: _proofUploaded ? SafePayColors.green : SafePayColors.gold,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _proofUploaded
                      ? '$_proofFileName\nUploaded ✓ — Pending Verification'
                      : 'Tap to Upload Document (PDF, JPG, PNG)',
                    textAlign: TextAlign.center,
                    style: SafePayText.bodySmall(
                      color: _proofUploaded ? SafePayColors.green : SafePayColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Live Video Proof (Gold only) ──
          if (_category == CommodityCategory.gold) ...[
            _buildLiveVideoProof(),
            const SizedBox(height: 12),
          ],

          // Verification note
          GlassContainer(
            blur: 6,
            opacity: 0.04,
            borderRadius: 10,
            padding: const EdgeInsets.all(12),
            showShadow: false,
            tint: SafePayColors.blue,
            child: Row(
              children: [
                const Icon(Iconsax.info_circle, color: SafePayColors.blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your listing will show as "Pending Verification" until our team verifies the document. Verified listings get a blue check badge and higher buyer trust.',
                    style: SafePayText.bodySmall(color: SafePayColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _simulateUpload() {
    if (_proofDocType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Select document type first'), backgroundColor: SafePayColors.red),
      );
      return;
    }
    // Simulate file upload
    setState(() {
      _proofUploaded = true;
      _proofFileName = '${_proofDocType.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ $_proofFileName uploaded'), backgroundColor: SafePayColors.green),
    );
  }

  // ─── Live Video Proof (Gold) ─────────────────────────────────
  Widget _buildLiveVideoProof() {
    return GlassContainer(
      width: double.infinity,
      blur: 12,
      opacity: 0.08,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      tint: _videoRecorded ? SafePayColors.green : SafePayColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _videoRecorded ? Iconsax.video_tick : Iconsax.video_play,
                color: _videoRecorded ? SafePayColors.green : SafePayColors.gold,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Video Proof',
                style: SafePayText.heading3(
                  color: _videoRecorded ? SafePayColors.green : SafePayColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Record a live video of the gold with the app built-in timestamp. '
            'Show the physical gold, hallmarks, and any certificates. '
            'The timestamp is embedded automatically and cannot be faked.',
            style: SafePayText.bodySmall(),
          ),
          const SizedBox(height: 16),
          if (!_videoRecorded)
            GoldButton3D(
              label: 'Start Recording',
              icon: Iconsax.video,
              onPressed: _recordVideoProof,
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.tick_circle, color: SafePayColors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video recorded ✓',
                            style: SafePayText.label(
                              color: SafePayColors.green,
                              weight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Duration: ${_videoDuration ~/ 60}m ${_videoDuration % 60}s',
                            style: SafePayText.caption(),
                          ),
                          Text(
                            'Timestamp: $_videoTimestamp',
                            style: SafePayText.caption(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _retakeVideo,
                        child: GlassContainer(
                          blur: 8,
                          opacity: 0.06,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          showShadow: false,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.refresh, color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                Text('Retake', style: SafePayText.button(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _recordVideoProof() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => VideoProofScreen(commodityType: 'Gold'),
        fullscreenDialog: true,
      ),
    );

    if (result != null && result['videoPath'] != null) {
      setState(() {
        _videoRecorded = true;
        _videoPath = result['videoPath'];
        _videoTimestamp = result['timestamp'] ?? '';
        _videoDuration = result['duration'] ?? 0;
      });
    }
  }

  void _retakeVideo() {
    setState(() {
      _videoRecorded = false;
      _videoPath = null;
      _videoTimestamp = '';
      _videoDuration = 0;
    });
  }

  Widget _buildProofDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _proofDocType.isEmpty ? null : _proofDocType,
          dropdownColor: SafePayColors.bgLight,
          isExpanded: true,
          hint: Text('Select document type', style: SafePayText.body(color: SafePayColors.textMuted)),
          style: SafePayText.body(),
          items: _proofDocTypes.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: SafePayText.body()))).toList(),
          onChanged: (v) => setState(() => _proofDocType = v ?? ''),
        ),
      ),
    );
  }

  // ─── Photo Upload ────────────────────────────────────────────

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: () {},
      child: GlassContainer(
        width: double.infinity,
        blur: 8,
        opacity: 0.04,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 28),
        showShadow: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.camera, color: SafePayColors.textSecondary, size: 36),
            const SizedBox(height: 8),
            Text('Tap to upload photos', style: SafePayText.bodySmall()),
          ],
        ),
      ),
    );
  }

  // ─── Category-specific form fields ───────────────────────────

  Widget _buildCategoryFields() {
    switch (_category) {
      case CommodityCategory.cars: return _buildCarsFields();
      case CommodityCategory.gold: return _buildGoldFields();
      case CommodityCategory.oil: return _buildOilFields();
      case CommodityCategory.land: return _buildLandFields();
      case CommodityCategory.cement: return _buildLandFields(); // Generic fields
      case CommodityCategory.dollars: return _buildDollarsFields();
      case CommodityCategory.crypto: return _buildDollarsFields();
      case CommodityCategory.giftcards: return _buildDollarsFields();
    }
  }

  Widget _buildCarsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: GlassInput(controller: _makeCtrl, label: 'Make', hint: 'e.g. Toyota', icon: Iconsax.car)),
            const SizedBox(width: 12),
            Expanded(child: GlassInput(controller: _modelCtrl, label: 'Model', hint: 'e.g. Corolla', icon: Iconsax.car)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: GlassInput(controller: _yearCtrl, label: 'Year', hint: 'e.g. 2018', icon: Iconsax.calendar, keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: GlassInput(controller: _mileageCtrl, label: 'Mileage (km)', hint: 'e.g. 45000', icon: Iconsax.speedometer, keyboard: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown('Condition', _carCondition, ['Brand New', 'Clean Used', 'Used', 'Foreign Used'], (v) => _carCondition = v!),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGoldFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Karat Purity', _goldKarat, ['24K (999.9)', '22K (916)', '21K (875)', '18K (750)', '14K (585)'], (v) => _goldKarat = v!),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: GlassInput(controller: _goldWeightCtrl, label: 'Weight (kg)', hint: 'e.g. 2.5', icon: Iconsax.weight, keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: GlassInput(controller: _goldQtyCtrl, label: 'Quantity', hint: 'e.g. 10', icon: Iconsax.box, keyboard: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown('Form', _goldForm, ['Bar', 'Biscuit', 'Dust', 'Jewellery', 'Coin'], (v) => _goldForm = v!),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOilFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown('Product Type', _oilType, ['AGO (Diesel)', 'PMS (Petrol)', 'DPK (Kerosene)', 'Crude Oil', 'Lubricant'], (v) => _oilType = v!),
        const SizedBox(height: 16),
        GlassInput(controller: _oilVolumeCtrl, label: 'Volume (litres)', hint: 'e.g. 30000', icon: Iconsax.box, keyboard: TextInputType.number),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDropdown('Incoterm', _oilIncoterm, ['EXW', 'FOB', 'CIF', 'TTO', 'TTT'], (v) => _oilIncoterm = v!)),
            const SizedBox(width: 12),
            Expanded(child: GlassInput(controller: _oilLocationCtrl, label: 'Depot/Source', hint: 'e.g. Apapa', icon: Iconsax.location)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLandFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: GlassInput(controller: _landSizeCtrl, label: 'Size (sqm)', hint: 'e.g. 600', icon: Iconsax.frame, keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: GlassInput(controller: _landStateCtrl, label: 'State', hint: 'e.g. Lagos', icon: Iconsax.location)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown('Title Document', _landTitle, ['C of O', 'R of O', "Governor's Consent", 'Deed of Assignment', 'Survey Plan Only'], (v) => _landTitle = v!),
        const SizedBox(height: 16),
        _buildDropdown('Land Type', _landType, ['Residential', 'Commercial', 'Industrial', 'Agricultural', 'Mixed Use'], (v) => _landType = v!),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDollarsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: GlassInput(controller: _dollarAmountCtrl, label: 'Amount (\$)', hint: 'e.g. 5000', icon: Iconsax.money_change, keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: GlassInput(controller: _dollarRateCtrl, label: 'Rate (₦/\$)', hint: 'e.g. 1620', icon: Iconsax.money, keyboard: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown('Form', _dollarForm, ['Bank Transfer', 'Cash', 'Crypto', 'Wire'], (v) => _dollarForm = v!),
        const SizedBox(height: 16),
        _buildDropdown('Payment Method', _dollarPayment, ['Bank', 'Cash', 'Mobile Money', 'Cheque'], (v) => _dollarPayment = v!),
        const SizedBox(height: 16),
      ],
    );
  }

  // ─── Dropdown Helper ─────────────────────────────────────────

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SafePayText.label(weight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: SafePayColors.bgLight,
              isExpanded: true,
              style: SafePayText.body(),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: SafePayText.body()))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Hints ──────────────────────────────────────────────────

  String _titleHint() {
    switch (_category) {
      case CommodityCategory.cars: return 'e.g. Toyota Corolla 2018 — Clean Used';
      case CommodityCategory.gold: return 'e.g. 22K Gold Bars — 2.5kg Available';
      case CommodityCategory.oil: return 'e.g. AGO Diesel — 30,000 litres at Apapa';
      case CommodityCategory.land: return 'e.g. 600sqm Residential Land — Lekki';
      case CommodityCategory.cement: return 'e.g. 600 Bags Dangote Cement — ₦10/bag Escrow';
      case CommodityCategory.dollars: return 'e.g. \$5,000 USD at ₦1,620/\$';
      case CommodityCategory.crypto: return 'e.g. 10,000 USDT TRC-20 P2P Trade';
      case CommodityCategory.giftcards: return 'e.g. \$500 Apple Gift Card';
    }
  }

  String _priceLabel() {
    switch (_category) {
      case CommodityCategory.gold: return 'Total Price (₦)';
      case CommodityCategory.oil: return 'Total Price (₦)';
      case CommodityCategory.dollars: return 'Total Naira Equivalent (₦)';
      default: return 'Price (₦)';
    }
  }

  String _priceHint() {
    switch (_category) {
      case CommodityCategory.gold: return 'e.g. 180000000';
      case CommodityCategory.oil: return 'e.g. 15000000';
      case CommodityCategory.dollars: return 'auto-calculated from rate';
      default: return 'e.g. 8500000';
    }
  }

  String _locationLabel() {
    switch (_category) {
      case CommodityCategory.oil: return 'Delivery Location';
      case CommodityCategory.land: return 'Exact Address/Landmark';
      case CommodityCategory.dollars: return 'Meeting Location';
      default: return 'Location';
    }
  }

  String _locationHint() {
    switch (_category) {
      case CommodityCategory.oil: return 'e.g. Port Harcourt';
      case CommodityCategory.land: return 'e.g. Plot 12, Lekki Phase 1';
      case CommodityCategory.dollars: return 'e.g. Wuse 2, Abuja';
      default: return 'e.g. Lekki, Lagos';
    }
  }
}
