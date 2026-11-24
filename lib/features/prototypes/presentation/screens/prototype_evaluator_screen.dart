import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/prototypes/domain/models/prototype_model_type.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/screens/prototype_station_lounge_screen.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_1_stepper_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_2_saas_portal_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_3_express_kiosk_view.dart';

/// Interactive evaluation workbench allowing testers and stakeholders to
/// compare the 3 candidate interaction paradigms side-by-side, toggle
/// mobile vs tablet viewport simulation, and test trilingual responsiveness.
class PrototypeEvaluatorScreen extends StatefulWidget {
  const PrototypeEvaluatorScreen({super.key});

  @override
  State<PrototypeEvaluatorScreen> createState() => _PrototypeEvaluatorScreenState();
}

class _PrototypeEvaluatorScreenState extends State<PrototypeEvaluatorScreen> {
  PrototypeModelType _activeModel = PrototypeModelType.stepper;
  bool _isMobilePreviewFrame = false;

  void _openLounge() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrototypeStationLoungeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    Widget activeView;
    switch (_activeModel) {
      case PrototypeModelType.stepper:
        activeView = Prototype1StepperView(onOpenLounge: _openLounge);
        break;
      case PrototypeModelType.saasPortal:
        activeView = Prototype2SaasPortalView(onOpenLounge: _openLounge);
        break;
      case PrototypeModelType.expressKiosk:
        activeView = Prototype3ExpressKioskView(onOpenLounge: _openLounge);
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Prototype Evaluator'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          // Language Switcher (EN, OM, AM)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.currentLang,
                  items: const [
                    DropdownMenuItem(value: 'EN', child: Text('🇬🇧 EN')),
                    DropdownMenuItem(value: 'OM', child: Text('🌳 OM')),
                    DropdownMenuItem(value: 'AM', child: Text('🇪🇹 AM')),
                  ],
                  onChanged: (val) {
                    if (val != null) state.setLanguage(val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Mobile Viewport Toggle
          IconButton(
            icon: Icon(
              _isMobilePreviewFrame ? Icons.stay_current_portrait_rounded : Icons.desktop_windows_rounded,
              color: _isMobilePreviewFrame ? AppColors.primary : Colors.grey,
            ),
            tooltip: 'Toggle Mobile Preview Frame',
            onPressed: () => setState(() => _isMobilePreviewFrame = !_isMobilePreviewFrame),
          ),
          const SizedBox(width: 8),

          // Station Lounge Direct Button
          TextButton.icon(
            onPressed: _openLounge,
            icon: const Icon(Icons.ondemand_video_rounded, size: 18),
            label: const Text('Lounge'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Top Model Selector Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: PrototypeModelType.values.map((type) {
                final isSelected = type == _activeModel;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _activeModel = type),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  type.icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              type.targetCompletionTime,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Active Model Description Ribbon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFE2E8F0),
            child: Text(
              _activeModel.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
            ),
          ),

          // Main Interactive Canvas
          Expanded(
            child: Center(
              child: _isMobilePreviewFrame
                  ? Container(
                      width: 390,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black87, width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: activeView,
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: activeView,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
