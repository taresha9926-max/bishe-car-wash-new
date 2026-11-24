# Umami Analytics for BISHE Car Wash

Umami is a privacy-first, open-source alternative to Google Analytics. It collects zero personal data, requires no cookie banners, and is extremely lightweight (~4KB tracking script).

---

## 1. How It's Connected to the BISHE Web App

The tracking script has been downloaded directly into `web/umami.js` and connected in `web/index.html`.

By default:
* **Script Source:** `umami.js` (served locally with the Flutter web bundle)
* **Default Host:** `https://cloud.umami.is` (or your local/custom Umami server)
* **Website ID:** `bishe-car-wash` (or your custom UUID)

---

## 2. Option A: Self-Host Umami (Local / Docker)

If you wish to run Umami on your own computer or server:

1. **Start Docker Desktop** on Windows.
2. Double-click `tools/umami/start_umami.bat` (or run `docker compose up -d` inside this directory).
3. Open your browser at:
   ```
   http://localhost:3000
   ```
4. Log in using the default credentials:
   * **Username:** `admin`
   * **Password:** `umami`
   *(You will be prompted to change this on your first login)*
5. Go to **Settings > Websites** -> click **Add Website**:
   * Name: `BISHE Car Wash`
   * Domain: `bishecarwash.vercel.app` (or your GitHub Pages domain)
6. Copy the generated **Website ID** (UUID).
7. Update `web/index.html`:
   ```html
   <script defer
           src="umami.js"
           data-website-id="YOUR_COPIED_UUID"
           data-host-url="http://localhost:3000"
           data-auto-track="true">
   </script>
   ```
   *(Or set `localStorage.setItem('bishe_umami_website_id', 'YOUR_COPIED_UUID')` in the browser console)*

---

## 3. Option B: Umami Cloud (Zero Maintenance)

If you prefer cloud hosting without managing a Docker server:

1. Sign up for free at [Umami Cloud](https://cloud.umami.is).
2. Create a website: `BISHE Car Wash`.
3. Copy your **Website ID**.
4. In `web/index.html`, set:
   ```html
   <script defer
           src="umami.js"
           data-website-id="YOUR_COPIED_UUID"
           data-host-url="https://cloud.umami.is"
           data-auto-track="true">
   </script>
   ```

---

## 4. SPA Navigation & Custom Event Tracking

Because BISHE Car Wash is a Flutter Web Single Page Application (SPA), `umami.js` automatically hooks into `window.history.pushState` and `window.history.replaceState`.

In addition, global JavaScript helper functions are available:
* `window.bisheTrackEvent('booking_created', { car_type: 'SUV' })`
* `window.bisheTrackView('/cashier', 'Cashier Desk')`
