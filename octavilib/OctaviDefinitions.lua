VENDOR_ID = 0x04d8
DEVICE_ID = 0xe6d6

FunctionID = {
  INIT = -1, -- No real state - set only when the script is initializing the active function
  COM1 = 0, -- Primary state
  COM2 = 1, -- Primary state
  NAV1 = 2, -- Primary state
  NAV2 = 3, -- Primary state
  FMS1 = 4, -- Primary state
  FMS2 = 5, -- Primary state
  AP = 6, -- Primary state
  XPDR = 7, -- Primary state
  HDG = 8, -- Secondary state
  BARO = 9, -- Secondary state
  CRS1 = 10, -- Secondary state
  CRS2 = 11, -- Secondary state
  MODE = 15, -- Secondary state
}

FunctionStrings = {
  [FunctionID.INIT] = "INIT",
  [FunctionID.COM1] = "COM1",
  [FunctionID.COM2] = "COM2",
  [FunctionID.NAV1] = "NAV1",
  [FunctionID.NAV2] = "NAV2",
  [FunctionID.FMS1] = "FMS1",
  [FunctionID.FMS2] = "FMS2",
  [FunctionID.AP] = "AP",
  [FunctionID.XPDR] = "XPDR",
  [FunctionID.HDG] = "HDG",
  [FunctionID.BARO] = "BARO",
  [FunctionID.CRS1] = "CRS1",
  [FunctionID.CRS2] = "CRS2",
  [FunctionID.MODE] = "MODE",
}

FunctionButtonValue = {
  BTN0 = 0,
  BTN1 = 1,
  BTN2 = 2,
  BTN3 = 3,
  BTN4 = 4,
  BTN5 = 5,
  BTN6 = 6,
  BTN7 = 7,
}

FunctionPrimaryMap = {
  [FunctionButtonValue.BTN0] = FunctionID.COM1,
  [FunctionButtonValue.BTN1] = FunctionID.COM2,
  [FunctionButtonValue.BTN2] = FunctionID.NAV1,
  [FunctionButtonValue.BTN3] = FunctionID.NAV2,
  [FunctionButtonValue.BTN4] = FunctionID.FMS1,
  [FunctionButtonValue.BTN5] = FunctionID.FMS2,
  [FunctionButtonValue.BTN6] = FunctionID.AP,
  [FunctionButtonValue.BTN7] = FunctionID.XPDR,
}

FunctionSecondaryMap = {
  [FunctionButtonValue.BTN0] = FunctionID.HDG,
  [FunctionButtonValue.BTN1] = FunctionID.BARO,
  [FunctionButtonValue.BTN2] = FunctionID.CRS1,
  [FunctionButtonValue.BTN3] = FunctionID.CRS2,
  [FunctionButtonValue.BTN4] = FunctionID.FMS1,
  [FunctionButtonValue.BTN5] = FunctionID.FMS2,
  [FunctionButtonValue.BTN6] = FunctionID.AP,
  [FunctionButtonValue.BTN7] = FunctionID.MODE,
}
