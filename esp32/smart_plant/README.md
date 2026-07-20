# ESP32 Smart Plant Hardware Wiring & Simulation

This directory contains the firmware (`smart_plant.ino`) and the interactive circuit simulation (`diagram.json`) for your physical ESP32 device.

## Wiring Guide (Pin Connections)

When building your physical device, wire the components exactly like this:

| Component | ESP32 Pin | Wire Color Code (Simulation) | Description |
| :--- | :--- | :--- | :--- |
| **Soil Moisture Sensor** | **GPIO 36 (A0)** | Green | Connect the analog signal pin to 36. It reads 0-4095 depending on moisture. |
| **Water Level Sensor** | **GPIO 34** | Blue | Connect the analog signal pin to 34. |
| **Temperature Sensor** | **GPIO 39** | Yellow | Connect the analog signal pin to 39. |
| **Water Pump (Relay/LED)** | **GPIO 5** | Blue (LED) | Connect this to a Relay module (which connects to the pump) or an LED for testing. |
| **Power (VCC)** | **3V3** | Red | Provide 3.3V power to all sensors. |
| **Ground (GND)** | **GND** | Black | Connect all grounds back to the ESP32 GND pin. |

## How to Simulate This Locally on Your Computer

I've configured a **Wokwi** interactive circuit diagram so you can click and interact with the physical components virtually!

1. Install the **Wokwi for VS Code** extension in your VS Code editor.
2. In VS Code, open the `/home/yousef/Folders/Git/IOT/esp32/smart_plant` folder.
3. Open `diagram.json`. Wokwi will show you a visual layout of your ESP32 connected to slide potentiometers (acting as your sensors) and a Blue LED (acting as your water pump).
4. If you want the simulator to connect to your real Firebase project:
   - Edit `smart_plant.ino` and set `WIFI_SSID` to `"Wokwi-GUEST"` and `WIFI_PASSWORD` to `""`.
   - Ensure your Firebase `API_KEY` and `PROJECT_ID` are set.
5. Click **"Start Simulation"** in Wokwi!

**What will happen in the simulation?**
- You can slide the potentiometers with your mouse. Sliding the "Soil Moisture" one down will lower the moisture reading.
- If it goes below your threshold (and Automatic mode is on in your Flutter app), you will visually see the Blue LED (Pump) instantly turn **ON** in the simulator!
- Because Wokwi connects to the real internet, sliding the virtual sensors will magically update your Flutter dashboard in real-time!
