import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme.dart';
import '../../logic/settings_repository.dart';
import '../../logic/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsRepository _settings;
  bool _isAdaptive = true;
  double _manualLevel = 5;
  String _currentTheme = 'obsidian';
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _settings = context.read<SettingsRepository>();
    _isAdaptive = _settings.isAdaptive;
    _manualLevel = _settings.manualLevel.toDouble();
    _currentTheme = _settings.boardTheme;
    _isMuted = _settings.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(color: AppTheme.champagneGold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('Zorluk Ayarları'),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Otomatik Seviye (Adaptive)', style: TextStyle(color: Colors.white)),
            subtitle: const Text('AI performansınıza göre kendini ayarlar.', style: TextStyle(color: Colors.white54)),
            value: _isAdaptive,
            activeColor: AppTheme.champagneGold,
            onChanged: (val) {
              setState(() => _isAdaptive = val);
              _settings.setAdaptive(val);
            },
          ),
          if (!_isAdaptive) ...[
            const SizedBox(height: 24),
            Text('Manuel Seviye: ${_manualLevel.toInt()}', style: const TextStyle(color: Colors.white)),
            Slider(
              value: _manualLevel,
              min: 1,
              max: 20,
              divisions: 19,
              activeColor: AppTheme.champagneGold,
              inactiveColor: Colors.white10,
              onChanged: (val) {
                setState(() => _manualLevel = val);
                _settings.setManualLevel(val.toInt());
              },
            ),
          ],
          const SizedBox(height: 32),
          _buildSectionTitle('Görünüm & Ses'),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Tahta Teması', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<String>(
              value: _currentTheme,
              dropdownColor: AppTheme.deepCharcoal,
              style: const TextStyle(color: AppTheme.champagneGold),
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'obsidian', child: Text('Obsidyen (Koyu)')),
                DropdownMenuItem(value: 'classic', child: Text('Klasik (Yeşil)')),
                DropdownMenuItem(value: 'ocean', child: Text('Okyanus (Mavi)')),
                DropdownMenuItem(value: 'wood', child: Text('Ahşap')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _currentTheme = val);
                  _settings.setBoardTheme(val);
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Ses Efektleri', style: TextStyle(color: Colors.white)),
            value: !_isMuted,
            activeColor: AppTheme.champagneGold,
            onChanged: (val) {
              setState(() => _isMuted = !val);
              _settings.setMuted(!val);
              AudioManager().isMuted = !val;
            },
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Oyuncu Bilgileri'),
          ListTile(
            title: const Text('Tahmini ELO', style: TextStyle(color: Colors.white)),
            trailing: Text('${_settings.playerElo}', style: const TextStyle(color: AppTheme.champagneGold, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.champagneGold,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}
