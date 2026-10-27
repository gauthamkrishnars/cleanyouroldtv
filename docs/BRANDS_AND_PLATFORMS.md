# Universal TV Platforms & Brand Guide

This guide ensures anyone—regardless of what TV model, brand, or operating system they or their family own—knows exactly how to optimize it safely without risk of breaking anything.

---

## 1. Supported by CleanYourOldTV 1-Click Toolkit (Android TV & Google TV)

The automated script (`RUN_OPTIMIZER.bat` or `run_optimizer.sh`) supports **any television running Android TV, Google TV, or Fire OS**. 

### Tested & Supported Brands:
* **Budget & CVTE Boards**: Lloyd, Thomson, Kodak, Vu, Blaupunkt, MarQ, Coocaa, Daiwa, Shinco, BPL.
* **Mainstream Android TVs**: Xiaomi (Mi TV / Redmi TV), TCL, Realme, OnePlus, Hisense, Motorola, Nokia, Sharp, Toshiba.
* **Premium Android TVs**: Sony Bravia, Philips (Android TV series).
* **Streaming Sticks & Boxes**: Amazon Fire TV Stick / Fire TV 4K / Cube, Chromecast with Google TV, Xiaomi Mi Box / TV Stick, Onn 4K Streaming Box, Nvidia Shield TV.

---

### How to Turn on Developer Options & ADB Debugging

Follow the specific steps below for your brand to unlock network control:

#### A. Standard Android TV / Google TV (Sony, TCL, Xiaomi, Realme, OnePlus)
1. Turn on your TV and open **Settings** (gear icon on the top right).
2. Go to **Device Preferences** (or **System**) $\rightarrow$ **About**.
3. Scroll down to **Android TV OS Build** (or **Build Number**).
4. Tap the **OK** button on your remote **7 times rapidly** until a popup says: *"You are now a developer!"*
5. Press Back $\rightarrow$ go to **Developer Options**.
6. Turn **ON**:
   * **USB Debugging**
   * **Network Debugging** (if present)
7. Note down your TV's IP address from **Settings $\rightarrow$ Network & Internet $\rightarrow$ Connected Wi-Fi/Ethernet**.

#### B. Budget TVs & CVTE Boards (Lloyd, Vu, Thomson, Kodak)
1. Go to **TV Settings** $\rightarrow$ **System Info** (or **About TV**).
2. Highlight **Build Version** or **Firmware Version** and press **OK 7 times**.
3. In Developer Options, enable **USB Debugging**.
4. Check your IP address under **Network Settings**.

#### C. Amazon Fire TV (Fire OS)
1. Go to **Settings** $\rightarrow$ **My Fire TV** $\rightarrow$ **About**.
2. Click on the device name (e.g. *Fire TV Stick 4K*) **7 times** to unlock Developer Options.
3. Press Back, open **Developer Options**.
4. Set **ADB Debugging** to **ON**.
5. Go to **Network** to note your IP address.

---

## 2. Non-Android TVs (LG webOS & Samsung Tizen)

If you or a friend have an **LG TV** or a **Samsung TV**, they do **not** run Android. Android ADB scripts will not connect to them. Here is how to speed them up and optimize them safely:

---

### A. LG Smart TVs (webOS)

LG televisions use **webOS**, which is based on Linux rather than Android. 

#### 1. Instant Settings Speedup (Turn Off Background Tracking)
LG webOS spends significant processing power analyzing what you watch in the background. Disabling this speeds up the interface:
1. Open **All Settings** $\rightarrow$ **General**.
2. Go to **AI Service** $\rightarrow$ Turn **OFF**:
   * *AI Picture Pro*
   * *AI Brightness Settings*
   * *AI Sound Pro*
3. Go to **Support** (or *General $\rightarrow$ Additional Settings*):
   * Select **Home Settings** $\rightarrow$ Turn **OFF** *Home Auto Launch* and *Home Promotion*. (This stops the heavy ad screen from loading every time you turn on the TV!)
   * Select **Live Plus** (LG's automatic content recognition) $\rightarrow$ Turn **OFF**.

#### 2. Installing Ad-Free YouTube & Moonlight on LG (Homebrew Channel)
If you want ad-free YouTube or game streaming on webOS:
1. Install the official **Developer Mode** app from the LG Content Store.
2. Create a free developer account at [developer.lge.com](https://developer.lge.com).
3. Log in inside the Developer Mode app and turn **Key Server ON**.
4. Use the free, open-source **[webOS Dev Manager](https://github.com/webosbrew/dev-manager-desktop)** on your PC. It connects over Wi-Fi and lets you install the **webOS Homebrew Channel** with 1 click to get:
   * **YouTube AdFree for webOS** (SponsorBlock + No Ads)
   * **Moonlight for webOS** (Game streaming directly to your LG TV)

---

### B. Samsung Smart TVs (Tizen OS)

Samsung TVs run **Tizen OS**.

#### 1. Disable Samsung TV Plus & Auto-Playing Video Ads
1. Open **Settings** $\rightarrow$ **General** $\rightarrow$ **Smart Features**.
2. Turn **OFF** *Autorun Smart Hub*.
3. Turn **OFF** *Autorun Last App*.
4. Remove **Samsung TV Plus** from your home bar by highlighting the icon, pressing Down, and choosing *Remove*. This prevents the TV from launching heavy live video streams in the background when turning on.

#### 2. Privacy & Telemetry Debloat
1. Go to **Settings** $\rightarrow$ **Support** $\rightarrow$ **Terms & Privacy**.
2. Review Privacy Notices:
   * Uncheck **Viewing Information Services** (Samsung ACR tracking).
   * Uncheck **Interest-Based Advertising**.

---

## 3. Universal Network-Level Optimization (Works on ALL TVs)

Regardless of brand (LG, Samsung, Sony, or Lloyd), you can apply ad-blocking and faster DNS across all of them at your home router:
1. Log into your home router's admin page (usually `192.168.1.1` in your browser).
2. Under **DHCP / DNS Settings**, set:
   * **Primary DNS**: `94.140.14.14` (AdGuard DNS) or `1.1.1.1` (Cloudflare)
   * **Secondary DNS**: `94.140.15.15` (AdGuard DNS) or `1.0.0.1` (Cloudflare)
3. Every TV, phone, and tablet connected to your home Wi-Fi will instantly block tracking and resolve streaming domains faster with zero software installed!
