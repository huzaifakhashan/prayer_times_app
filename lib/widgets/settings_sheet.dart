import 'dart:io';
import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import '../models/app_settings.dart';
import '../services/adhan_service.dart';
import '../utils/constants.dart';

class SettingsSheet extends StatelessWidget {
  final AppSettings settings;
  final AdhanService adhanService;
  final VoidCallback onChanged;
  final Future<void> Function() onSave;
  final Future<void> Function(String) onPickFile;
  final Future<void> Function(String) onRemoveFile;

  const SettingsSheet({
    super.key,
    required this.settings,
    required this.adhanService,
    required this.onChanged,
    required this.onSave,
    required this.onPickFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, controller) {
            return Column(
              children: [
                const SizedBox(height: 15),
                const Text('الإعدادات',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _sectionTitle('إعدادات الحساب'),
                      const SizedBox(height: 15),
                      _madhabDropdown(setState),
                      const SizedBox(height: 15),
                      _methodDropdown(setState),
                      SwitchListTile(
                        title: const Text('عرض الشروق'),
                        value: settings.showSunrise,
                        onChanged: (v) => setState(() => settings.showSunrise = v),
                      ),
                      SwitchListTile(
                        title: const Text('نظام 24 ساعة'),
                        value: settings.use24Hour,
                        onChanged: (v) => setState(() => settings.use24Hour = v),
                      ),
                      const Divider(height: 30),
                      _sectionTitle('إعدادات الأذان'),
                      SwitchListTile(
                        title: const Text('تفعيل تشغيل الأذان'),
                        subtitle: const Text('تشغيل الصوت تلقائياً عند دخول الوقت'),
                        value: settings.adhanEnabled,
                        onChanged: (v) => setState(() => settings.adhanEnabled = v),
                      ),
                      const SizedBox(height: 10),
                      ...AppSettings.adhanPrayers.map((name) => _adhanCard(name, setState)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await onSave();
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      );

  Widget _madhabDropdown(StateSetter setState) {
    return DropdownButtonFormField<Madhab>(
      value: settings.madhab,
      decoration: const InputDecoration(
        labelText: 'مذهب العصر',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: Madhab.shafi, child: Text('الجمهور (شافعي)')),
        DropdownMenuItem(value: Madhab.hanafi, child: Text('الحنفي')),
      ],
      onChanged: (v) => setState(() => settings.madhab = v!),
    );
  }

  Widget _methodDropdown(StateSetter setState) {
    return DropdownButtonFormField<CalcMethod>(
      value: settings.method,
      decoration: const InputDecoration(
        labelText: 'طريقة الحساب',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: CalcMethod.muslimWorldLeague, child: Text('رابطة العالم الإسلامي')),
        DropdownMenuItem(value: CalcMethod.egyptian, child: Text('الهيئة المصرية')),
        DropdownMenuItem(value: CalcMethod.karachi, child: Text('كراتشي')),
        DropdownMenuItem(value: CalcMethod.ummAlQura, child: Text('أم القرى')),
        DropdownMenuItem(value: CalcMethod.dubai, child: Text('دبي')),
        DropdownMenuItem(value: CalcMethod.qatar, child: Text('قطر')),
        DropdownMenuItem(value: CalcMethod.kuwait, child: Text('الكويت')),
        DropdownMenuItem(value: CalcMethod.turkey, child: Text('تركيا')),
      ],
      onChanged: (v) => setState(() => settings.method = v!),
    );
  }

  Widget _adhanCard(String name, StateSetter setState) {
    final path = settings.adhanFiles[name];
    final hasFile = path != null && path.isNotEmpty;
    final fileName = hasFile ? path.split(Platform.pathSeparator).last : null;

    return Card(
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (hasFile) ...[
              const SizedBox(height: 8),
              Text(fileName ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await onPickFile(name);
                      setState(() {});
                    },
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(hasFile ? 'تغيير الملف' : 'اختيار ملف',
                        style: const TextStyle(fontSize: 13)),
                  ),
                ),
                if (hasFile) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => adhanService.preview(path),
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () async {
                      await onRemoveFile(name);
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}