import 'package:flutter/material.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/prototypes/domain/models/prototype_model_type.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/screens/prototype_station_lounge_screen.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_1_stepper_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_2_saas_portal_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_3_express_kiosk_view.dart';
import 'package:bishe_car_wash/features/prototypes/presentation/widgets/prototype_served_unified_clone_view.dart';

/// Interactive evaluation workbench allowing testers and stakeholders to
/// compare the distinct Apple-styled interaction paradigms side-by-side,
/// toggle mobile vs desktop viewport simulation, and test trilingual responsiveness.
class PrototypeEvaluatorScreen extends StatefulWidget {
  const PrototypeEvaluatorScreen({super.key});

  @override
  State<PrototypeEvaluatorScreen> createState() => _PrototypeEvaluatorScreenState();
}

class _PrototypeEvaluatorScreenState extends State<PrototypeEvaluatorScreen> {
  PrototypeModelType _activeModel = PrototypeModelType.unifiedServedClone;
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
    Color canvasBg;
    switch (_activeModel) {
      case PrototypeModelType.unifiedServedClone:
        activeView = PrototypeServedUnifiedCloneView(onOpenLounge: _openLounge);
        canvasBg = const Color(0xFFF5F5F7);
        break;
      case PrototypeModelType.stepper:
        activeView = Prototype1StepperView(onOpenLounge: _openLounge);
        canvasBg = const Color(0xFFF5F5F7);
        break;
      case PrototypeModelType.saasPortal:
        activeView = Prototype2SaasPortalView(onOpenLounge: _openLounge);
        canvasBg = const Color(0xFF161617);
        break;
      case PrototypeModelType.expressKiosk:
        activeView = Prototype3ExpressKioskView(onOpenLounge: _openLounge);
        canvasBg = const Color(0xFFFBF9F6);
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Apple Parchment Canvas
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Prototype Evaluator',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1D1F),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E5EA), height: 1),
        ),
        actions: [
          // Language Capsule Switcher (EN, OM, AM)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.currentLang,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF86868B)),
                  items: const [
                    DropdownMenuItem(value: 'EN', child: Text('EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    DropdownMenuItem(value: 'OM', child: Text('OM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    DropdownMenuItem(value: 'AM', child: Text('AM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  ],
                  onChanged: (val) {
                    if (val != null) state.setLanguage(val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Mobile Viewport Frame Toggle
          IconButton(
            icon: Icon(
              _isMobilePreviewFrame ? Icons.stay_current_portrait_rounded : Icons.desktop_windows_rounded,
              color: _isMobilePreviewFrame ? const Color(0xFF0071E3) : const Color(0xFF86868B),
              size: 22,
            ),
            tooltip: 'Toggle Mobile Preview Frame',
            onPressed: () => setState(() => _isMobilePreviewFrame = !_isMobilePreviewFrame),
          ),

          // Station Lounge Pill
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextButton.icon(
              onPressed: _openLounge,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF5F5F7),
                foregroundColor: const Color(0xFF1D1D1F),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.ondemand_video_rounded, size: 16),
              label: const Text('Lounge', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Apple Segmented Pill Selector Bar (Horizontally scrollable on narrow viewports)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA), // Apple Segmented Track
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: PrototypeModelType.values.map((type) {
                      final isSelected = type == _activeModel;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () => setState(() => _activeModel = type),
                          borderRadius: BorderRadius.circular(9999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type.icon,
                                  size: 15,
                                  color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFF86868B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type.title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 13,
                                    color: isSelected ? const Color(0xFF1D1D1F) : const Color(0xFF86868B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // Active Model Description Ribbon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            color: const Color(0xFFF5F5F7),
            child: Text(
              _activeModel.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF86868B), fontWeight: FontWeight.w500),
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
                        color: canvasBg,
                        borderRadius: BorderRadius.circular(44), // iPhone 16 Pro curved corners
                        border: Border.all(color: const Color(0xFF1D1D1F), width: 8), // Ceramic bezel
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Dynamic Island pill
                          Container(
                            height: 32,
                            color: canvasBg,
                            child: Center(
                              child: Container(
                                width: 96,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: activeView),
                        ],
                      ),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 880),
                      child: activeView,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
