import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../theme/lava_theme.dart';
import '../widgets/app_helpers.dart';
import '../widgets/glass_card.dart';
import '../widgets/glowing_button.dart';
import '../widgets/lava_background.dart';

class SettingsView extends StatefulWidget {
  final StorageService storage;
  const SettingsView({super.key, required this.storage});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _target;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _height = TextEditingController();
    _target = TextEditingController();
    _refreshFields();
  }

  void _refreshFields() {
    final profile = widget.storage.savedProfile;
    _name.text = profile.nickname;
    _height.text = profile.heightCm == 0
        ? ''
        : profile.heightCm.toStringAsFixed(0);
    _target.text = profile.targetWeightKg == 0
        ? ''
        : profile.targetWeightKg.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showNotice(context, success);
    } catch (_) {
      if (mounted) showNotice(context, '操作未完成，原数据已保留，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await _run(
      () => widget.storage.saveProfile(
        widget.storage.savedProfile.copyWith(
          nickname: _name.text.trim(),
          heightCm: double.tryParse(_height.text.trim()) ?? 0,
          targetWeightKg: double.tryParse(_target.text.trim()) ?? 0,
        ),
      ),
      '设置已保存',
    );
  }

  Future<void> _export() => _run(() async {
    final value = widget.storage.exportBackupJson();
    await Clipboard.setData(ClipboardData(text: value));
  }, '备份文本已复制，请粘贴到自己的文件中保存');

  Future<void> _import() async {
    if (_busy) return;
    String raw;
    int count;
    try {
      raw = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
      count = StorageService.parseBackup(raw).records.length;
    } catch (_) {
      if (mounted) showNotice(context, '剪贴板中没有有效的流光体重备份');
      return;
    }
    if (!mounted) return;
    if (!await confirmAction(
      context,
      title: '恢复备份？',
      message: '将用备份中的 $count 条记录与个人设置替换当前数据。建议先复制一份当前备份。',
      confirm: '恢复备份',
    )) {
      return;
    }
    await _run(() async {
      await widget.storage.importBackupJson(raw);
      _refreshFields();
    }, '备份已恢复');
  }

  @override
  Widget build(BuildContext context) {
    final storage = widget.storage;
    return PageBackdrop(
      image: 'trends',
      motion: storage.profile.motionEnabled,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我的',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '给自己留一点光',
                style: TextStyle(color: LavaTheme.textSecondary),
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('个人目标', style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _name,
                        maxLength: 40,
                        enabled: !_busy,
                        decoration: const InputDecoration(
                          labelText: '昵称（选填）',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _numberField(_height, '身高（cm，选填）', 50, 250),
                      const SizedBox(height: 16),
                      _numberField(_target, '目标体重（kg，选填）', 20, 300),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: GlowingButton(
                          label: '保存设置',
                          onPressed: _busy ? null : _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: const Text('以斤显示', style: TextStyle(fontSize: 15)),
                      subtitle: const Text(
                        '1 kg = 2 斤',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: storage.savedProfile.useJin,
                      onChanged: _busy
                          ? null
                          : (value) => _run(
                              () => storage.saveProfile(
                                storage.savedProfile.copyWith(useJin: value),
                              ),
                              '单位已更新',
                            ),
                    ),
                    const Divider(color: LavaTheme.glassBorderSubtle),
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: const Text('流光呼吸', style: TextStyle(fontSize: 15)),
                      subtitle: const Text(
                        '背景轻缓漂移，跟随系统减少动态效果设置',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: storage.savedProfile.motionEnabled,
                      onChanged: _busy
                          ? null
                          : (value) => _run(
                              () => storage.saveProfile(
                                storage.savedProfile.copyWith(
                                  motionEnabled: value,
                                ),
                              ),
                              '动效设置已更新',
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('数据与备份', style: TextStyle(fontSize: 17)),
                    const SizedBox(height: 12),
                    const Text(
                      '记录仅保存在这台设备的本地数据库。备份为未加密文本，请妥善保管。',
                      style: TextStyle(
                        color: LavaTheme.textSecondary,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: GlowingButton(
                        label: '复制备份文本',
                        icon: Icons.copy_outlined,
                        isSecondary: true,
                        onPressed: _busy ? null : _export,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: GlowingButton(
                        label: '从剪贴板恢复',
                        icon: Icons.restore_rounded,
                        isSecondary: true,
                        onPressed: _busy ? null : _import,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('体验与关于', style: TextStyle(fontSize: 17)),
                    const SizedBox(height: 12),
                    Text(
                      storage.isDemo
                          ? '正在展示演示数据，个人记录保持原样。'
                          : '可预览 18 天示例趋势。演示不会写入个人记录。',
                      style: const TextStyle(
                        fontSize: 12,
                        color: LavaTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlowingButton(
                      label: storage.isDemo ? '退出演示预览' : '预览演示数据',
                      isSecondary: true,
                      onPressed: _busy
                          ? null
                          : () {
                              if (storage.isDemo) {
                                storage.exitDemo();
                              } else {
                                storage.showDemo();
                              }
                              showNotice(
                                context,
                                storage.isDemo ? '已开启演示，可返回今日和趋势查看' : '已回到个人记录',
                              );
                            },
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      '流光体重 · LavaWeight 0.1.0\n开源 · 离线 · 无账号',
                      style: TextStyle(
                        color: LavaTheme.textSecondary,
                        fontSize: 12,
                        height: 1.7,
                      ),
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

  Widget _numberField(
    TextEditingController controller,
    String label,
    double min,
    double max,
  ) => TextFormField(
    controller: controller,
    enabled: !_busy,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
    validator: (raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      final value = double.tryParse(raw.trim());
      if (value == null || !value.isFinite || value < min || value > max) {
        return '请输入 ${min.toInt()}–${max.toInt()} 之间的数值';
      }
      return null;
    },
  );
}
