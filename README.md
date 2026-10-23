# 🚗 BISHE Car Wash Service Mobile App
**Location:** Bishoftu (Debre Zeyit), Oromia, Ethiopia  
**Architecture:** Clean Architecture (Domain, Data, Presentation)  
**State Management:** Native Reactive State Pattern (`AppStateNotifier` / `InheritedNotifier` / `ChangeNotifier`)

---

## 🌟 Overview
**BISHE Car Wash Service** is a multi-role mobile application built with Flutter for a car wash business located in Bishoftu, Oromia. The app provides specialized user experiences for **three distinct roles**:
1. **Customer**: Online booking for stationary washing (2 bays) or at-home mobile service (1 van), vehicle category selection, and live wash status tracking.
2. **Cashier**: Gate entry registration, vehicle bay assignment (Bay 1, Bay 2, Mobile Van), washer dispatching, and Cash / Digital Money Transfer (Telebirr, CBE Birr) payment collection.
3. **Admin**: Control panel to edit service pricing by car type, manage staff base salaries, and track automated washer commission logs generated upon wash completion.

---

## 🏗️ Clean Architecture Blueprint

```
lib/
├── main.dart                                 # App bootstrap & DI configuration
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                   # Bishoftu water & aquatic palette
│   │   ├── app_constants.dart                # Business rules, currency (ETB), capacity
│   │   └── app_theme.dart                    # Material 3 styling, cards & typography
│   ├── utils/
│   │   ├── currency_formatter.dart           # ETB formatting (e.g. 500 ETB)
│   │   └── date_formatter.dart               # DateTime & Time-ago helpers
│   └── widgets/
│       ├── app_role_header.dart              # Interactive role switcher dropdown
│       ├── custom_button.dart                # Styled button with loading state
│       ├── custom_text_field.dart            # Inputs with validation
│       └── status_badge.dart                 # Color-coded status chips
├── features/
│   ├── auth_roles/                           # Multi-role routing & switcher
│   │   ├── domain/models/user_role.dart      # Customer, Cashier, Admin
│   │   └── presentation/screens/
│   │       └── role_shell_screen.dart        # Role switcher bar & screen router
│   ├── booking_service/                      # Core domain & data models
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── bay_station.dart          # Bay 1, Bay 2, Mobile Van
│   │   │   │   ├── car_type.dart             # Automobile, Minibus, Truck
│   │   │   │   ├── payment_info.dart         # Cash, Telebirr, CBE Birr
│   │   │   │   ├── service_type.dart         # Walk-in Station vs At-Home Mobile
│   │   │   │   ├── wash_booking.dart         # Booking aggregate entity
│   │   │   │   ├── wash_package.dart         # Package pricing matrix per car type
│   │   │   │   └── wash_status.dart          # 7-stage wash lifecycle
│   │   │   └── repositories/
│   │   │       └── i_wash_repository.dart    # Abstract contract
│   │   ├── data/
│   │   │   ├── datasources/mock_wash_datasource.dart # Bishoftu seed data
│   │   │   └── repositories/wash_repository_impl.dart # Concrete repository
│   │   └── presentation/state/
│   │       ├── app_state_notifier.dart       # Central reactive business logic
│   │       └── app_state_provider.dart       # InheritedNotifier for UI tree
│   ├── customer/                             # Customer Feature
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── customer_home_screen.dart # Capacity monitor & quick booking
│   │       │   ├── new_booking_screen.dart   # 5-step booking wizard
│   │       │   ├── live_tracking_screen.dart # Real-time progress stepper
│   │       │   └── booking_history_screen.dart# Past receipt history
│   │       └── widgets/
│   │           ├── car_type_selector.dart    # Automobile, Minibus, Truck selector
│   │           ├── live_wash_stepper.dart    # Visual wash stages
│   │           └── station_type_card.dart    # 2 Bays vs 1 Van availability card
│   ├── cashier/                              # Cashier Gate Desk Feature
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── cashier_dashboard_screen.dart # 3-bay monitor & queue
│   │       │   ├── walk_in_registration_screen.dart # Gate check-in form
│   │       │   ├── bay_assignment_modal.dart # Assign Bay & Washer modal
│   │       │   └── payment_process_dialog.dart # Cash & Telebirr/CBE modal
│   │       └── widgets/
│   │           ├── active_queue_tile.dart    # Queue car item with fast actions
│   │           └── bay_live_status_card.dart # Live Bay 1, Bay 2, Van 1 cards
│   └── admin/                                # Admin Control Panel Feature
│       ├── domain/models/
│       │   ├── commission_log.dart           # Automated audit log entry
│       │   └── staff_member.dart             # Staff salary & commission model
│       └── presentation/
│           ├── screens/
│           │   ├── admin_dashboard_screen.dart # Executive KPIs & shortcuts
│           │   ├── pricing_management_screen.dart # Price matrix editor
│           │   ├── staff_management_screen.dart # Base salaries & commissions
│           │   └── commission_logs_screen.dart # Automatic logs & filters
│           └── widgets/
│               ├── commission_item_card.dart # Audit log item card
│               ├── pricing_matrix_editor.dart # Interactive matrix table
│               └── revenue_kpi_card.dart     # KPI summary card
```

---

## 🔑 Key Features per Role

### 1. 👤 Customer Role
- **Station & Van Capacity Visibility**: Real-time monitor showing whether Bay 1, Bay 2, and Mobile Van are vacant or occupied.
- **Service Mode Selection**:
  - `Walk-in Station`: 2 stationary pressure washing bays at the Bishoftu main gate.
  - `At-Home Mobile Service`: 1 mobile van with water tank and power generator dispatched to residential compounds or hotels (Kuriftu, Lake Babogaya, etc.).
- **Vehicle Category Selection**:
  - `Automobile`: Sedan, Hatchback, Compact
  - `Minibus`: Toyota HiAce, Dolphin, 12-16 seats
  - `Truck / SUV`: Pickup, Heavy 4WD, Light Truck
- **Service Packages with Dynamic Price Sync**:
  - Express Foam Wash
  - Standard Clean & Vacuum
  - Executive Detailing & Wax
  - Chassis & Engine Flush
- **Live Wash Progress Tracking**: 
  - Visual 6-step progress stepper: `Confirmed` ➔ `Queued in Bay` ➔ `Washing` ➔ `Drying & Detailing` ➔ `Ready for Pickup` ➔ `Completed`.
  - Shows assigned bay, assigned washer staff, and digital receipt breakdown.

### 2. 🧾 Cashier Role
- **Gate Walk-In Registration**: Fast gate check-in for arriving drive-in cars. Cashier enters license plate, customer phone, car type, package, bay assignment, and staff washer.
- **Live 3-Bay Occupancy Dashboard**:
  - Dedicated interactive monitor cards for **Bay 1 (Station)**, **Bay 2 (Station)**, and **Mobile Van 1 (At-Home)**.
  - One-tap quick advance button (e.g. `Start Washing` ➔ `Move to Drying` ➔ `Ready for Pickup` ➔ `Complete & Free Bay`).
- **Bay & Washer Reassignment**: Reassign or move vehicles between Bay 1, Bay 2, and Mobile Van, and dispatch specific washers from the staff roster.
- **Payment Processing**:
  - **Cash** (physical handover at gate checkout)
  - **Digital Money Transfer** (Telebirr & CBE Birr with transaction SMS reference verification).

### 3. 🛡️ Admin Role
- **Executive Revenue Dashboard**: Total revenue today (ETB), cash vs. digital split, total washer commissions paid, and net margin calculation.
- **Service Pricing by Car Type Matrix**:
  - Fully customizable pricing matrix for every wash package across `Automobile`, `Minibus`, and `Truck`.
  - Admin edits are reflected instantly in real-time across Customer booking and Cashier billing.
- **Staff Base Salaries & Commission Management**:
  - Set base monthly salaries in ETB (e.g. 5,000 ETB / month).
  - Customize washer commission rates (e.g. 15% to 20% per completed wash).
  - Track total completed washes and accumulated commissions per team member.
- **Automated Washer Commission Logs**:
  - Whenever a wash is marked as `completed` by the Cashier or Admin, the repository **automatically calculates and writes an immutable commission log**.
  - Commission formula: `Total Wash Price (ETB) × Washer Commission Rate (%) = Commission Earned (ETB)`.
  - Audit trail with filter by washer and total payout summation.

---

## 🚀 How to Run the App

1. Ensure the Flutter SDK is installed on your machine (`flutter --version`).
2. Navigate to the project root directory:
   ```bash
   cd "c:\Users\Tare\Desktop\Flutter App"
   ```
3. Get packages:
   ```bash
   flutter pub get
   ```
4. Run on your preferred device (Chrome, Android emulator, or Windows desktop):
   ```bash
   flutter run -d chrome
   # or
   flutter run
   ```

---

## 🔄 Interactive Multi-Role Testing
You can switch roles at any moment using:
- **Top AppBar Dropdown**: Tap the role indicator in the top right of the header to pick `Customer`, `Cashier`, or `Admin`.
- **Bottom Navigation Bar**: Tap any of the 3 tabs (`Customer`, `Cashier`, `Admin`) for immediate switching.
