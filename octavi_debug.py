#!/usr/bin/env python3
# https://github.com/cyberang3l/octavi-xplane-flywithlua

import hidapi
import importlib


to_bin = importlib.import_module("submodules.number-to-binary.to-bin")


# Octavi
VENDOR_ID = 0x04d8
PRODUCT_ID = 0xe6d6

devices_available = hidapi.enumerate(VENDOR_ID, PRODUCT_ID)
assert list(
    devices_available), "No Octavi devices were found - have you connected your devices?"

try:
    device = hidapi.Device(vendor_id=VENDOR_ID,
                           product_id=PRODUCT_ID, blocking=False)
except OSError as e:
    strerror = e.args[0]
    if "Could not open connection" in strerror:
        print("An OCTAVI device was found, but we couldn't open the device. Is it in use by another program?")
        exit(1)

print("Connected to device", device.get_manufacturer_string(),
      device.get_product_string(), device.get_serial_number_string())
while True:
    read_bytes = device.read(length=8, timeout_ms=1000, blocking=True)
    if read_bytes:
        val = to_bin.HexBinDecPrinter(raw_value=str(int.from_bytes(
            read_bytes, "big")), print_split=8, bits_to_show=64)
        val.print_all()

    # # 2nd value controls the LEDs at the bottom of the device
    # # 3rd and 5th byte can write values that change the knob readings.
    # # Technically, every time we write a value to these bytes, the next
    # # time we read the input we get the difference from the value the byte
    # # contained before we write.
    # #
    # # # If you want to test turning on/off different leds, use the following
    # # # code to write to the HID device:
    # # import time
    # for i in range(0, 2**6 + 1):
    #     leds = hex(i).replace('0x', '').zfill(2)
    #     small_knob = hex(random.randint(0, 255)).replace('0x', '').zfill(2)
    #     large_knob = hex(random.randint(0, 255)).replace('0x', '').zfill(2)

    #     val = f"0x00{leds}{small_knob}00{small_knob}000000"
    #     print(f"writing {val} to device")
    #     bytes_to_write = int(val, 16).to_bytes(8, "big")
    #     device.write(bytes_to_write)
    #     read_bytes = device.read(length=8, timeout_ms=1000, blocking=True)
    #     if read_bytes:
    #         val = to_bin.HexBinDecPrinter(raw_value=str(int.from_bytes(
    #             read_bytes, "big")), print_split=8, bits_to_show=64)
    #         val.print_all()
    #     time.sleep(0.1)
