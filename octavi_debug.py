#!/usr/bin/env python3

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

    # # If you want to test turning on/off different led, use the following
    # # code to write to the HID device:
    # import time
    # for i in range(0, 2**6 + 1):
    #     print(i)
    #     device.write(i.to_bytes(2, "big"))
    #     time.sleep(0.1)
