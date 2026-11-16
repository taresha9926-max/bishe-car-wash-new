# BISHE CAR WASH & AUTO CARE OPERATIONS MANUAL
**Authoritative Operational Knowledge Base & System Architecture**
*Location: Bishoftu (Debre Zeyit), Oromia, Ethiopia (behind Hirna Butchery, near Alemshet Fero)*  
*GPS Coordinates: 8°44'57.2"N 38°58'02.4"E | Station Phone: +251 911 234 567*

---

## 1. Station Infrastructure & Capacity

### 1.1 Physical Facilities
- **Bay 1 (Physical Wash Bay)**: High-pressure power washer, foam cannon, water recycling pit, heavy-duty drainage.
- **Bay 2 (Physical Wash Bay)**: Dual foam lance, undercarriage sprayers, vacuum & drying station.
- **Mobile Van (At-Home / On-Demand Auto Care)**: Mobile service unit serving 8 Bishoftu zones: City Center, Lake Babogaya, Lake Bishoftu Resort Corridor, Kuriftu, Lake Hora Ras, Meda Welabu, Addis Expressway Gate, Industrial Park Road.
- **Staff Rest & Shower Facility**: Hot shower unit for staff and walk-in shower customers (VAT Exempt).
- **Warehouse & Storage Room**: Secure room with bin cards, 22 tracked consumable chemicals, fixed asset tools, and locked empty-container return bay.

### 1.2 Team Structure & Roster
- **8 Station Washers**: Working in rotating pairs across Bay 1, Bay 2, and Mobile Van.
- **Washer Commission Pool**: Individual commission rates from 2% to 25% (default 15%) calculated strictly on **Net Revenue** (Gross Revenue minus 15% VAT).
- **Cashier**: Manages walk-in reception, POS terminal (Cash, Telebirr, CBE Birr, Awash Bank), physical cash drawer, and initiates shift handovers.
- **Operations Manager**: Supervises wash quality, bay flow, night shift lead, receives shift custody via 6-digit OTP.
- **Storekeeper**: Controls warehouse, maintains bin cards, enforces Empty-for-Full chemical canister exchanges, and audits fixed assets.
- **Accountant**: Performs daily closing audits, matches cashier cash envelopes against stamped bank deposit slips (CBE/Awash), reconciles petty cash, audits VAT obligations.
- **Super Admin**: Controls master pricing, tariffs, staff commission rates, and system configuration.

---

## 2. Vehicle Classifications & Workload Coefficients

The station classifies all vehicles into 3 standardized categories plus carpet cleaning:

| Category | Database Value | Representative Vehicles | Workload Multiplier | Expected Shampoo (ml) | Expected Perfume (ml) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Type A (Small)** | `'automobile'` | Corolla, Dzire, Yaris, Vitz, BYD, small sedans | **1.0× (Base)** | 125 ml | 5 ml (1 spray cycle) |
| **Type B (Medium)** | `'minibus'` | V8, Bigstar, Hilux, Dolphin, Minibus, SUVs | **1.5×** | 187.5 ml | 7.5 ml |
| **Type C (Large / Heavy)** | `'truck'` | Sinotruk, FSR, Heavy Trucks, Large Vans | **2.5×** | 312.5 ml | 12.5 ml |
| **Carpet Cleaning** | `is_carpet: true` | Normal or Thick/Shaggy Carpets | **Area ($m^2$) × 0.25** | ~30 ml / $m^2$ | Optional fragrance |

### Equivalent Vehicle Units (EVU) Formula:
$$\text{Total Station EVU} = (\text{Type A} \times 1.0) + (\text{Type B} \times 1.5) + (\text{Type C} \times 2.5) + (\text{Carpet } m^2 \times 0.25)$$

---

## 3. Service Packages & Pricing Matrix

### 3.1 Vehicle Detailing Packages
1. **Silver / Basic Wash**: Body hand wash, high-pressure rinse, active snow foam shampoo, microfiber towel dry, tire black dressing.
2. **Gold / Polishing Finish**: Silver wash + machine or hand buffing polish with Abro polish compound and grinder pads.
3. **Platinum A/B/C**: Comprehensive detailing, high-gloss wax, interior dashboard protectant, foaming tire cleaner, interior scent spray.
4. **Diamond Complete Overhaul**: Full exterior paint correction, deep engine degreasing, undercarriage wash, leather seat conditioning, carpet extraction.
5. **Engine Bay Degreasing**: Concentrated degreaser spray, oil breakdown, electrical terminal shielding, safe rinse.
6. **Walk-In Shower Facility**: Hot water shower for walk-in clients.

### 3.2 Carpet Cleaning Tariffs
- **Normal Carpet (Type A)**: 80 ETB / $m^2$ base rate.
- **Thick / Shaggy Carpet (Type B)**: 100 ETB / $m^2$ base rate.
- **Dimensions**: Tracked by length $\times$ width (e.g. $3\text{m} \times 4\text{m} = 12\text{ m}^2$).

---

## 4. Statutory Tax & Financial Accounting Architecture

### 4.1 Value Added Tax (VAT) Rules
- **Car Wash & Detailing Services**: Subject to statutory **15% VAT**.
- **Carpet Cleaning Services**: Subject to statutory **15% VAT**.
- **Shower Services**: **0% VAT (Exempt)** under statutory sanitation rules.
- **Net Base Revenue Formula**:
  $$\text{Net Base Revenue} = \frac{\text{Gross Revenue}}{1.15} \quad \text{or} \quad \text{Gross} - (\text{Gross} \times 0.15)$$

### 4.2 Washer Commission Payout Architecture
- Commission is calculated **strictly on Net Service Revenue** (excluding VAT).
- Default rate is 15%, but individual washer agreements vary from 2% to 25% based on seniority and performance.
- When two washers work on a single vehicle in Bay 1 or Bay 2, the commission is split 50/50 between them.
$$\text{Washer Payout} = \text{Net Revenue} \times \text{Washer's Commission Rate}$$

### 4.3 P&L Statement Structure
1. **Gross Service Revenue**: Total cash, digital (Telebirr, CBE Birr), and card inflow.
2. **Less: 15% VAT**: Statutory tax obligation.
3. **Net Service Revenue**: Taxable station operating income.
4. **Cost of Goods Sold (COGS)**:
   - **Direct Labor**: Washer commission payouts.
   - **Direct Materials**: Consumable chemicals consumed during washes (~28.5 ETB / EVU average).
5. **Gross Operating Profit**: Net Revenue minus COGS.
6. **Operating Expenses (OPEX)**:
   - Cashier & yard petty cash expenses (water bills, electricity, daily supplies).
7. **Net Operating Profit (EBITDA)**: Net daily cash retained to amortize station land rent and base staff salaries.

---

## 5. Warehouse Consumables & The "Empty-for-Full" Protocol

### 5.1 The 22 Core Consumable Items
- **CS-001**: Abro Polish Compound (Tins / Cans) — Min: 4.0 | Cost: 450 ETB
- **CS-002**: Grinder Polish Buffing Pad (Pieces) — Min: 5.0 | Cost: 300 ETB
- **CS-003**: Dashboard Protectant / ቅባት (Liters) — Min: 5.0 | Cost: 650 ETB
- **CS-004**: Foaming Tire Cleaner Spray (Spray Cans) — Min: 6.0 | Cost: 380 ETB
- **CS-005**: Water Spot Removing Compound (Bottles) — Min: 3.0 | Cost: 850 ETB
- **CS-006**: Air Freshener Perfume / ሽቶ (500ml Bottles) — Min: 6.0 | Cost: 250 ETB
- **CS-007**: 2-Color Polishing Cloth / የማሻ ጨርቅ (Pieces) — Min: 8.0 | Cost: 150 ETB
- **CS-008**: Headlight Restoration Chemicals (Bottles) — Min: 2.0 | Cost: 950 ETB
- **CS-009**: Active Snow Foam Car Shampoo (5L Canisters) — Min: 15.0 L | Cost: 220 ETB/L
- **CS-010A**: Dashboard Finishing Sprays (Cans) — Min: 5.0 | Cost: 320 ETB
- **CS-010B**: Carpet & Interior Cleaning Sprays (Cans) — Min: 5.0 | Cost: 340 ETB
- **CS-011**: Tire Dressing Black Gel (Cans) — Min: 4.0 | Cost: 420 ETB
- **CS-012**: Concentrated Engine Degreaser (Liters) — Min: 3.0 | Cost: 550 ETB
- **CS-013**: Microfiber Towels 40x40 (Pieces) — Min: 20.0 | Cost: 65 ETB
- **CS-014**: Leather Seat Conditioner Cream (Bottles) — Min: 3.0 | Cost: 480 ETB

### 5.2 The Empty-for-Full Custody Rule
- **Standard Canister Benchmarks**:
  - **5L Foam Shampoo (CS-009)**: Yields **~40 EVU** (~125 ml / EVU).
  - **500ml Interior Perfume (CS-006)**: Yields **~100 interior sprays** (~5 ml / spray).
- **Storekeeper Enforcement**:
  - The storekeeper **NEVER** issues a new 5L shampoo canister or 500ml perfume bottle without receiving the **matching empty container with its cap intact**.
  - If a 5L canister is returned after fewer than **25 cars**, the storekeeper flags a **leakage or excessive foam alert**.
  - If a 5L canister lasts more than **55 cars**, the storekeeper flags an **under-dosing / over-dilution alert**.
  - Every dispatch is signed on the bay's physical Bin Card with the washer's signature and car count tally.

---

## 6. Daily Shift Workflows & Handover Protocols

### 6.1 Shift Schedule
- **Day Shift**: 07:00 – 15:30 (Managed by Primary Cashier).
- **Night / Evening Shift**: 15:30 – 22:00 (Managed by Operations Lead / Night Cashier).

### 6.2 6-Digit OTP Custody Handover
1. At 15:30, the Day Cashier counts physical cash in the drawer and prepares the digital payment summary (Telebirr/CBE).
2. The Cashier taps **Request Shift Handover** in the Cashier Desk.
3. The system generates a **secure 6-digit OTP** displayed exclusively to the receiving Operations Manager.
4. The Operations Manager physically recounts the cash drawer, confirms matches with the terminal report, and enters the 6-digit OTP into the terminal.
5. Upon verification:
   - The drawer balance transfers to the Manager.
   - The Day Cashier shift is locked.
   - The Deposit to Bank button is disabled until bank deposit slip upload.

### 6.3 Bank Deposit Slip Reconciliation
- All physical cash exceeding the station daily reserve (3,000 ETB) must be deposited into the station's **CBE (Commercial Bank of Ethiopia)** or **Awash Bank** account.
- The Cashier or Manager uploads a photo of the bank teller-stamped deposit slip.
- The Accountant verifies the deposit amount against the drawer closing envelope before approving the final daily balance.
