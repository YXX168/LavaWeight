import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/bmi_calculator.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';

class SettingsView extends StatefulWidget {
  final StorageService storage;

  const SettingsView({super.key, required this.storage});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _nicknameController;
  late TextEditingController _heightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _initialWeightController;

  @override
  void initState() {
    super.initState();
    final p = widget.storage.profile;
    _nicknameController = TextEditingController(text: p.nickname);
    _heightController =
        TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _targetWeightController =
        TextEditingController(text: p.targetWeightKg.toStringAsFixed(1));
    _initialWeightController =
        TextEditingController(text: p.initialWeightKg.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _initialWeightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final target = double.tryParse(_targetWeightController.text) ?? 65.0;
    final initial = double.tryParse(_initialWeightController.text) ?? 72.0;

    widget.storage.saveProfile(
      widget.storage.profile.copyWith(
        nickname: _nicknameController.text.trim(),
        heightCm: height,
        targetWeightKg: target,
        initialWeightKg: initial,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('个人设置已保存'),
        backgroundColor: LavaTheme.backgroundAubergine,
      ),
    );
  }

  void _exportData() {
    final jsonStr = widget.storage.exportBackupJson();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('备份数据已复制到剪贴板，您可以妥善保存'),
        backgroundColor: LavaTheme.backgroundAubergine,
      ),
    );
  }

  Future<void> _importData() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('剪贴板中没有可导入的备份文本')),
        );
      }
      return;
    }

    final success = widget.storage.importBackupJson(data.text!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '数据恢复成功！' : '备份格式错误，无法导入'),
          backgroundColor: success ? LavaTheme.success : LavaTheme.lavaPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.storage.profile;
    final (minHealthy, maxHealthy) =
        BMICalculator.getHealthyWeightRange(profile.heightCm);

    return Stack(
      children: [
        // Dark background
        Positioned.fill(
          child: Container(
            color: LavaTheme.background,
          ),
        ),

        // Radial ambient glow
        Positioned(
          top: -100,
          right: -100,
          width: 320,
          height: 320,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x33FF2A85), Colors.transparent],
              ),
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '个人与设置',
                  style: TextStyle(
                    color: LavaTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '量身定制您的体重管理目标',
                  style: TextStyle(
                    color: LavaTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                // Health Range Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0x33FF2A85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.favorite_outline,
                          color: LavaTheme.lavaPeach,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '理想健康体重范围',
                              style: TextStyle(
                                color: LavaTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$minHealthy ~ $maxHealthy kg',
                              style: const TextStyle(
                                color: LavaTheme.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '基于身高 ${profile.heightCm.toStringAsFixed(0)} cm 测算 (BMI 18.5 ~ 23.9)',
                              style: const TextStyle(
                                color: LavaTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Fields Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基本目标设置',
                        style: TextStyle(
                          color: LavaTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('身高 (cm)', _heightController),
                      const SizedBox(height: 12),
                      _buildTextField('目标体重 (kg)', _targetWeightController),
                      const SizedBox(height: 12),
                      _buildTextField('初始体重 (kg)', _initialWeightController),
                      const SizedBox(height: 12),
                      _buildTextField('昵称', _nicknameController),
                      const SizedBox(height: 18),
                      GlowingButton(
                        label: '保存设置',
                        onPressed: _saveProfile,
                        height: 46,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Data Management Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '数据与备份',
                        style: TextStyle(
                          color: LavaTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GlowingButton(
                              label: '备份至剪贴板',
                              icon: Icons.copy,
                              onPressed: _exportData,
                              isSecondary: true,
                              height: 44,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlowingButton(
                              label: '从剪贴板恢复',
                              icon: Icons.paste,
                              onPressed: _importData,
                              isSecondary: true,
                              height: 44,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            widget.storage.seedDemoData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已恢复 18 天演示记录')),
                            );
                          },
                          child: const Text(
                            '重置为示例演示数据',
                            style: TextStyle(
                                color: LavaTheme.lavaPeach, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Privacy Commitment Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.shield_outlined,
                              color: LavaTheme.success, size: 18),
                          SizedBox(width: 8),
                          Text(
                            '隐私与安全承诺',
                            style: TextStyle(
                              color: LavaTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'LavaWeight 坚持 100% 本地优先原则。本应用无需注册、无需联网，所有身体指标记录均加密保存在您的手机设备中。',
                        style: TextStyle(
                          color: LavaTheme.textMuted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style:
                const TextStyle(color: LavaTheme.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: LavaTheme.glassFill,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: LavaTheme.glassBorderSubtle, width: 0.8),
            ),
            child: TextField(
              controller: controller,
              style:
                  const TextStyle(color: LavaTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/bmi_calculator.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';

class SettingsView extends StatefulWidget {
  final StorageService storage;

  const SettingsView({super.key, required this.storage});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _nicknameController;
  late TextEditingController _heightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _initialWeightController;

  @override
  void initState() {
    super.initState();
    final p = widget.storage.profile;
    _nicknameController = TextEditingController(text: p.nickname);
    _heightController =
        TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _targetWeightController =
        TextEditingController(text: p.targetWeightKg.toStringAsFixed(1));
    _initialWeightController =
        TextEditingController(text: p.initialWeightKg.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _initialWeightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final target = double.tryParse(_targetWeightController.text) ?? 65.0;
    final initial = double.tryParse(_initialWeightController.text) ?? 72.0;

    widget.storage.saveProfile(
      widget.storage.profile.copyWith(
        nickname: _nicknameController.text.trim(),
        heightCm: height,
        targetWeightKg: target,
        initialWeightKg: initial,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('个人设置已保存'),
        backgroundColor: LavaTheme.backgroundAubergine,
      ),
    );
  }

  void _exportData() {
    final jsonStr = widget.storage.exportBackupJson();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('备份数据已复制到剪贴板，您可以妥善保存'),
        backgroundColor: LavaTheme.backgroundAubergine,
      ),
    );
  }

  Future<void> _importData() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('剪贴板中没有可导入的备份文本')),
        );
      }
      return;
    }

    final success = widget.storage.importBackupJson(data.text!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '数据恢复成功！' : '备份格式错误，无法导入'),
          backgroundColor:
              success ? LavaTheme.success : LavaTheme.lavaPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.storage.profile;
    final (minHealthy, maxHealthy) =
        BMICalculator.getHealthyWeightRange(profile.heightCm);

    return Stack(
      children: [
        // Dark background
        Positioned.fill(
          child: Container(
            color: LavaTheme.background,
          ),
        ),

        // Radial ambient glow
        Positioned(
          top: -100,
          right: -100,
          width: 320,
          height: 320,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x33FF2A85), Colors.transparent],
              ),
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '个人与设置',
                  style: TextStyle(
                    color: LavaTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '量身定制您的体重管理目标',
                  style: TextStyle(
                    color: LavaTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                // Health Range Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0x33FF2A85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.favorite_outline,
                          color: LavaTheme.lavaPeach,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '理想健康体重范围',
                              style: TextStyle(
                                color: LavaTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$minHealthy ~ $maxHealthy kg',
                              style: const TextStyle(
                                color: LavaTheme.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '基于身高 ${profile.heightCm.toStringAsFixed(0)} cm 测算 (BMI 18.5 ~ 23.9)',
                              style: const TextStyle(
                                color: LavaTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Fields Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基本目标设置',
                        style: TextStyle(
                          color: LavaTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('身高 (cm)', _heightController),
                      const SizedBox(height: 12),
                      _buildTextField('目标体重 (kg)', _targetWeightController),
                      const SizedBox(height: 12),
                      _buildTextField('初始体重 (kg)', _initialWeightController),
                      const SizedBox(height: 12),
                      _buildTextField('昵称', _nicknameController),
                      const SizedBox(height: 18),
                      GlowingButton(
                        label: '保存设置',
                        onPressed: _saveProfile,
                        height: 46,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Data Management Card
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '数据与备份',
                        style: TextStyle(
                          color: LavaTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GlowingButton(
                              label: '备份至剪贴板',
                              icon: Icons.copy,
                              onPressed: _exportData,
                              isSecondary: true,
                              height: 44,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlowingButton(
                              label: '从剪贴板恢复',
                              icon: Icons.paste,
                              onPressed: _importData,
                              isSecondary: true,
                              height: 44,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            widget.storage.seedDemoData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已恢复 18 天演示记录')),
                            );
                          },
                          child: const Text(
                            '重置为示例演示数据',
                            style: TextStyle(
                                color: LavaTheme.lavaPeach, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Privacy Commitment Card
                const GlassCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: LavaTheme.success, size: 18),
                          SizedBox(width: 8),
                          Text(
                            '隐私与安全承诺',
                            style: TextStyle(
                              color: LavaTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'LavaWeight 坚持 100% 本地优先原则。本应用无需注册、无需联网，所有身体指标记录均加密保存在您的手机设备中。',
                        style: TextStyle(
                          color: LavaTheme.textMuted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style:
                const TextStyle(color: LavaTheme.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: LavaTheme.glassFill,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: LavaTheme.glassBorderSubtle, width: 0.8),
            ),
            child: TextField(
              controller: controller,
              style:
                  const TextStyle(color: LavaTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
