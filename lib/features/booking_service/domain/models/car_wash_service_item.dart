import 'car_type.dart';

class CarWashServiceItem {
  final String id;
  final String name;
  final String category; // 'exterior', 'polish', 'interior', 'engine', 'specialty'
  final String? description;
  final Map<CarType, double> pricingByCarType;
  final bool isActive;

  const CarWashServiceItem({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.pricingByCarType,
    this.isActive = true,
  });

  double getPriceFor(CarType carType) =>
      pricingByCarType[carType] ?? pricingByCarType[CarType.automobile] ?? 0.0;

  CarWashServiceItem copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    Map<CarType, double>? pricingByCarType,
    bool? isActive,
  }) {
    return CarWashServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      pricingByCarType: pricingByCarType ?? this.pricingByCarType,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'pricing_automobile': pricingByCarType[CarType.automobile],
      'pricing_minibus': pricingByCarType[CarType.minibus],
      'pricing_truck': pricingByCarType[CarType.truck],
      'is_active': isActive,
    };
  }

  factory CarWashServiceItem.fromMap(Map<String, dynamic> map) {
    return CarWashServiceItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'exterior',
      description: map['description']?.toString(),
      pricingByCarType: {
        CarType.automobile: (map['pricing_automobile'] as num?)?.toDouble() ?? 500.0,
        CarType.minibus: (map['pricing_minibus'] as num?)?.toDouble() ?? 700.0,
        CarType.truck: (map['pricing_truck'] as num?)?.toDouble() ?? 1200.0,
      },
      isActive: map['is_active'] == null ? true : (map['is_active'] as bool),
    );
  }

  /// Default 14 atomic detailing services for Bishe Car Wash
  static List<CarWashServiceItem> getInitialServiceItems() {
    return const [
      // 1. Exterior & Hand Wash
      CarWashServiceItem(
        id: 'srv_body_wash',
        name: 'Body Hand Wash with Shampoo',
        category: 'exterior',
        description: 'High-pressure pre-rinse, touchless snow foam & microfiber hand wash',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 700.0,
          CarType.truck: 1200.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_tire_clean',
        name: 'Tire Cleaning & Tire Black Finish',
        category: 'exterior',
        description: 'Deep rim scrub, silicone tire black gloss dressing',
        pricingByCarType: {
          CarType.automobile: 200.0,
          CarType.minibus: 300.0,
          CarType.truck: 400.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_window_polish',
        name: 'Window Polish & Exterior Glass',
        category: 'exterior',
        description: 'Streak-free exterior windshield & side window polish',
        pricingByCarType: {
          CarType.automobile: 150.0,
          CarType.minibus: 250.0,
          CarType.truck: 400.0,
        },
      ),

      // 2. Polish & Paint Correction
      CarWashServiceItem(
        id: 'srv_machine_polish',
        name: 'Machine Body Polish',
        category: 'polish',
        description: 'Machine rotary buffer gloss restoration & paint enhancement',
        pricingByCarType: {
          CarType.automobile: 1000.0,
          CarType.minibus: 1500.0,
          CarType.truck: 2000.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_scratch_removal',
        name: 'Scratch & Minor Scuff Removal',
        category: 'polish',
        description: 'Targeted abrasive compound for clear-coat scratches and scuffs',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 800.0,
          CarType.truck: 1100.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_water_spot',
        name: 'Water Spot Chemical Removal',
        category: 'polish',
        description: 'Chemical mineral dissolution for Bishoftu lake water mineral stains',
        pricingByCarType: {
          CarType.automobile: 800.0,
          CarType.minibus: 1200.0,
          CarType.truck: 1600.0,
        },
      ),

      // 3. Interior Restoration & Detailing
      CarWashServiceItem(
        id: 'srv_int_vacuum',
        name: 'Interior Vacuum Floor & Seat Cleaning',
        category: 'interior',
        description: 'Deep cabin vacuuming of seats, floor mats and trunk',
        pricingByCarType: {
          CarType.automobile: 400.0,
          CarType.minibus: 600.0,
          CarType.truck: 800.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_seats_out',
        name: 'Seat & Floor Carpet Removed & Washed',
        category: 'interior',
        description: 'Unbolting passenger seats for extraction shampoo & pressure wash',
        pricingByCarType: {
          CarType.automobile: 2500.0,
          CarType.minibus: 4000.0,
          CarType.truck: 5000.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_roof_cleaning',
        name: 'Roof Headliner Deep Cleaning',
        category: 'interior',
        description: 'High-heat steam sanitization for roof fabric without sagging',
        pricingByCarType: {
          CarType.automobile: 600.0,
          CarType.minibus: 900.0,
          CarType.truck: 1200.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_dashboard_detailing',
        name: 'Dashboard Detailing (Cream & Airfresh)',
        category: 'interior',
        description: 'Air vent brush detailing, UV dashboard cream & fragrance',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 800.0,
          CarType.truck: 1100.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_door_panel',
        name: 'Door Panel Deep Cleaning',
        category: 'interior',
        description: 'Deep scrubbing of all interior door skins, handles and pockets',
        pricingByCarType: {
          CarType.automobile: 400.0,
          CarType.minibus: 600.0,
          CarType.truck: 800.0,
        },
      ),

      // 4. Engine & Specialty Detailing
      CarWashServiceItem(
        id: 'srv_engine_shampoo',
        name: 'Engine Cleaning (Shampoo)',
        category: 'engine',
        description: 'Basic engine compartment wash with automotive shampoo',
        pricingByCarType: {
          CarType.automobile: 500.0,
          CarType.minibus: 700.0,
          CarType.truck: 1000.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_engine_chemical',
        name: 'Engine Bay Chemical Degreasing',
        category: 'engine',
        description: 'Specialty chemical degreasing, grime rinse & hose conditioning',
        pricingByCarType: {
          CarType.automobile: 1200.0,
          CarType.minibus: 1700.0,
          CarType.truck: 2300.0,
        },
      ),
      CarWashServiceItem(
        id: 'srv_headlight_restoration',
        name: 'Headlight Restoration',
        category: 'specialty',
        description: 'Dual-stage wet-sanding to clear yellow oxidation + UV sealant',
        pricingByCarType: {
          CarType.automobile: 1000.0,
          CarType.minibus: 1400.0,
          CarType.truck: 1800.0,
        },
      ),
    ];
  }
}
