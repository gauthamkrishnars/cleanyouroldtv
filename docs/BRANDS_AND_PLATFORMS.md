# Universal TV Platforms and Brand Guide

This guide covers how to optimize televisions across different operating systems, including Android TV, Google TV, Fire OS, LG webOS, and Samsung Tizen.

---

## 1. Supported by CleanYourOldTV (Android TV, Google TV, and Fire OS)

The automated scripts (`RUN_OPTIMIZER.bat` or `run_optimizer.sh`) support any television running Android TV, Google TV, or Fire OS.

### Network Prerequisites:
1. **Same Local Network**: Your computer or phone and the TV must be connected to the same Wi-Fi router or Ethernet switch. Do not use Guest Wi-Fi networks, as routers enable client isolation on guest networks.
2. **Turn Off VPN**: Ensure any VPN (NordVPN, ExpressVPN, Surfshark, Cloudflare WARP) on your computer or phone is disabled before connecting.
3. **Keep TV Screen Awake**: The TV must be powered on and displaying the home screen.
4. **Approve Authorization Prompt**: When connecting for the first time, a dialog appears on the TV screen asking to "Allow USB Debugging". Check "[X] Always allow from this computer" using your physical TV remote and select OK.

### Tested and Supported Hardware:
* **Budget and Regional Brands**: Lloyd, Thomson, Kodak, Vu, Blaupunkt, MarQ, Coocaa, Daiwa, Shinco, BPL, Sansui, Micromax, Intex.
* **Mainstream Android TVs**: Xiaomi (Mi TV / Redmi TV), TCL, Realme, OnePlus, Hisense, Motorola, Nokia, Sharp, Toshiba.
* **Premium Android TVs**: Sony Bravia, Philips Android TV series.
* **Streaming Sticks and Boxes**: Amazon Fire TV Stick / 4K / Cube, Chromecast with Google TV, Xiaomi Mi Box / TV Stick, Onn 4K Box, Nvidia Shield TV.

---

### What is a CVTE Motherboard?
Many budget smart TV manufacturers do not design their internal computing hardware. Instead, they buy pre-built smart TV mainboards made by CVTE.

On these boards:
1. **Physical Remote Inputs**: The Home and Source buttons on the plastic remote switch directly between the smart interface and the Cable/DTH/HDMI tuner hardware. Disabling the stock launcher breaks this physical switching.
2. **Factory Debugging**: Network debugging on port 5555 is frequently enabled directly from the factory, allowing immediate connection without developer menus.

---

### How to Connect to Your TV: 4 Methods

#### Method 0: Direct Connection (Many Budget TVs)
1. Turn on the TV and check its local IP address under Settings -> Network (e.g. 192.168.1.50).
2. Run `RUN_OPTIMIZER.bat` and enter the IP address.
3. If ADB is enabled by default, the script connects immediately.

#### Method 1: Standard 7-Click Method (Google TV, Sony, Mi, TCL, Realme, OnePlus)
1. Open TV Settings -> Device Preferences (or System) -> About.
2. Scroll to Android TV OS Build (or Build Number).
3. Press the OK button on your remote 7 times until a confirmation appears stating you are a developer.
4. Return to Settings -> Developer Options.
5. Enable USB Debugging and Network Debugging.

#### Method 2: Engineering Remote Codes (Older Budget TVs)
If tapping the build number does not open Developer Options:
1. Press the Menu (or Source / Input) button on your physical remote.
2. While the on-screen menu is visible, type one of these number sequences:
   * `1 1 4 7` (Most common on CVTE boards)
   * `2 5 8 0`
   * `8 1 5`
3. In the factory menu, open General Settings or Other Settings and toggle ADB Debugging to ON.

#### Method 3: Amazon Fire TV (Fire OS)
1. Open Settings -> My Fire TV -> About.
2. Click the device name 7 times to reveal Developer Options.
3. Return to Settings -> Developer Options.
4. Set ADB Debugging to ON.

---

## 2. Non-Android TVs (LG webOS and Samsung Tizen)

LG and Samsung televisions do not run Android. Android ADB commands will not connect to them. Use these platform-specific steps instead:

---

### A. LG Smart TVs (webOS)

LG televisions run webOS, a proprietary Linux-based platform.

#### 1. Turn Off Background Tracking and Ad Services
1. Open All Settings -> General.
2. Open AI Service and turn off:
   * AI Picture Pro
   * AI Brightness Settings
   * AI Sound Pro
3. Open Support (or General -> Additional Settings):
   * Open Home Settings and turn off Home Auto Launch and Home Promotion.
   * Open Live Plus (LG automatic content recognition) and turn it off.

#### 2. Installing Ad-Free YouTube and Moonlight on webOS
1. Install the official Developer Mode app from the LG Content Store.
2. Register a free developer account at [developer.lge.com](https://developer.lge.com).
3. Log in inside the Developer Mode app and turn Key Server to ON.
4. Install [webOS Dev Manager](https://github.com/webosbrew/dev-manager-desktop) on your computer. Connect over local Wi-Fi to install the webOS Homebrew Channel, which provides YouTube AdFree and Moonlight game streaming.

---

### B. Samsung Smart TVs (Tizen OS)

Samsung televisions run Tizen OS.

#### 1. Disable Auto-Playing Video Streams
1. Open Settings -> General -> Smart Features.
2. Turn off Autorun Smart Hub.
3. Turn off Autorun Last App.
4. Highlight the Samsung TV Plus tile on the home screen, press Down on the directional pad, and select Remove.

#### 2. Disable Content Tracking
1. Open Settings -> Support -> Terms and Privacy.
2. Review Privacy Notices:
   * Uncheck Viewing Information Services.
   * Uncheck Interest-Based Advertising.

---

## 3. Network-Level DNS Optimization (All TV Brands)

To block telemetry and ad domains across all smart TVs on your home network without installing software:
1. Open your router admin portal in a browser (typically `192.168.1.1`).
2. Navigate to DHCP / DNS Settings.
3. Set the upstream DNS servers:
   * Primary DNS: `94.140.14.14` (AdGuard DNS) or `1.1.1.1` (Cloudflare)
   * Secondary DNS: `94.140.15.15` (AdGuard DNS) or `1.0.0.1` (Cloudflare)
4. Save and reboot the router. All connected devices inherit the filtered DNS.
