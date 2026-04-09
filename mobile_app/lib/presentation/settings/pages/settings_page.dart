import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/indonesian_date_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/controllers/session_controller.dart';
import '../../shared/widgets/brand_logo_badge.dart';
import '../../shared/widgets/demo_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import '../controllers/store_setting_controller.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _storeNameController;
  late final TextEditingController _storeAddressController;
  late final TextEditingController _storePhoneController;
  late final TextEditingController _invoiceFooterController;
  bool _hasHydratedForm = false;
  String? _selectedLogoPath;
  bool _removeLogo = false;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _storeAddressController = TextEditingController();
    _storePhoneController = TextEditingController();
    _invoiceFooterController = TextEditingController();

    Future.microtask(
      () => ref.read(storeSettingControllerProvider.notifier).loadInitial(),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    _invoiceFooterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final storeSettingState = ref.watch(storeSettingControllerProvider);
    final user = session?.user;
    final createdAt = user?.createdAt == null
        ? '-'
        : IndonesianDateFormatter.shortDateTime(user!.createdAt!);

    ref.listen<StoreSettingState>(storeSettingControllerProvider, (_, next) {
      if (!_hasHydratedForm &&
          !next.isLoading &&
          next.storeSetting != null &&
          mounted) {
        _hydrateForm(next);
      }

      if (next.successMessage != null && mounted) {
        setState(() {
          _selectedLogoPath = null;
          _removeLogo = false;
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.successMessage!)),
          );
        ref.read(storeSettingControllerProvider.notifier).clearFeedback();
      } else if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        ref.read(storeSettingControllerProvider.notifier).clearFeedback();
      }
    });

    if (!_hasHydratedForm &&
        !storeSettingState.isLoading &&
        storeSettingState.storeSetting != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _hydrateForm(storeSettingState);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: storeSettingState.isLoading
            ? const Center(child: LoadingIndicator())
            : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => ref
                        .read(storeSettingControllerProvider.notifier)
                        .load(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 76, 20, 28),
                      children: [
                        SurfaceCard(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: storeSettingState.isSaving
                                    ? null
                                    : () => _showLogoOptions(storeSettingState),
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        BrandLogoBadge(
                                          width: 132,
                                          height: 72,
                                          filePath: _selectedLogoPath,
                                          imageUrl: _removeLogo
                                              ? null
                                              : storeSettingState
                                                  .storeSetting?.logoUrl,
                                        ),
                                        Positioned(
                                          right: -6,
                                          bottom: -6,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.edit_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Tap logo untuk ganti atau hapus',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user?.name ?? '-',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user?.phone.isNotEmpty == true
                                    ? user!.phone
                                    : (user?.email.isNotEmpty == true
                                        ? user!.email
                                        : '-'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                createdAt,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SurfaceCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTextField(
                                  controller: _storeNameController,
                                  label: 'Nama Toko',
                                  hintText: 'Masukkan nama toko',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nama toko wajib diisi ya.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _storeAddressController,
                                  label: 'Alamat Toko',
                                  hintText: 'Masukkan alamat toko',
                                  maxLines: 3,
                                  minLines: 2,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _storePhoneController,
                                  label: 'Nomor HP',
                                  hintText: 'Masukkan nomor HP',
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _invoiceFooterController,
                                  label: 'Footer Invoice',
                                  hintText: 'Catatan footer invoice',
                                  maxLines: 3,
                                  minLines: 2,
                                ),
                                const SizedBox(height: 20),
                                PrimaryButton(
                                  label: 'Simpan Pengaturan',
                                  isLoading: storeSettingState.isSaving,
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    await ref
                                        .read(storeSettingControllerProvider
                                            .notifier)
                                        .save(
                                          storeName:
                                              _storeNameController.text.trim(),
                                          storeAddress: _storeAddressController
                                              .text
                                              .trim(),
                                          phoneNumber:
                                              _storePhoneController.text.trim(),
                                          invoiceFooter:
                                              _invoiceFooterController.text
                                                  .trim(),
                                          logoFilePath: _removeLogo
                                              ? null
                                              : _selectedLogoPath,
                                          removeLogo: _removeLogo,
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton(
                          onPressed: () => ref
                              .read(sessionControllerProvider.notifier)
                              .logout(),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DemoScreenHeader(
                      title: 'Akun & Pengaturan',
                      height: 50,
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: const Border(
                        bottom: BorderSide(
                          color: Color(0x12000000),
                        ),
                      ),
                      titleStyle:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _hydrateForm(StoreSettingState state) {
    final storeSetting = state.storeSetting;
    _storeNameController.text = storeSetting?.storeName ?? '';
    _storeAddressController.text = storeSetting?.storeAddress ?? '';
    _storePhoneController.text = storeSetting?.phoneNumber ?? '';
    _invoiceFooterController.text = storeSetting?.invoiceFooter ?? '';
    _hasHydratedForm = true;
  }

  Future<void> _pickLogoImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedLogoPath = picked.path;
      _removeLogo = false;
    });
  }

  void _removeLogoImage() {
    setState(() {
      _selectedLogoPath = null;
      _removeLogo = true;
    });
  }

  Future<void> _showLogoOptions(StoreSettingState state) async {
    final canRemove = _hasExistingLogo(state) || _selectedLogoPath != null;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kelola Logo Toko',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih tindakan untuk logo toko kamu.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Ganti Logo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickLogoImage();
                  },
                ),
                if (canRemove)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    title: const Text(
                      'Hapus Logo',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _removeLogoImage();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasExistingLogo(StoreSettingState state) {
    return (state.storeSetting?.logoUrl ?? '').trim().isNotEmpty &&
        !_removeLogo;
  }
}
