-- https://github.com/cyberang3l/octavi-xplane-flywithlua
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

--- Do not modify the ButtonsInit table - everything should be false here
ButtonsInit = {
  SHIFT = false,
  KNOB = false,
  AP = false,
  HDG = false,
  NAV = false,
  APR = false,
  ALT = false,
  VS = false,
  D = false,
  MENU = false,
  CLR = false,
  ENT = false,
  L_KNOB_ROTATE_RIGHT = false,
  L_KNOB_ROTATE_LEFT = false,
  S_KNOB_ROTATE_RIGHT = false,
  S_KNOB_ROTATE_LEFT = false,
}

ButtonID = {
  SHIFT = 0,
  KNOB = 1,
  AP = 2,
  HDG = 3,
  NAV = 4,
  APR = 5,
  ALT = 6,
  VS = 7,
  D = 8,
  MENU = 9,
  CLR = 10,
  ENT = 11,
  CDI = 12,
  OBS = 13,
  MSG = 14,
  FPL = 15,
  VNAV = 16,
  PROC = 17,
}

ButtonStrings = {
  [ButtonID.SHIFT] = "<->",
  [ButtonID.KNOB] = "",
  [ButtonID.AP] = "AP",
  [ButtonID.HDG] = "HDG",
  [ButtonID.NAV] = "NAV",
  [ButtonID.APR] = "APR",
  [ButtonID.ALT] = "ALT",
  [ButtonID.VS] = "VS",
  [ButtonID.D] = "-D->",
  [ButtonID.MENU] = "MENU",
  [ButtonID.CLR] = "CLR",
  [ButtonID.ENT] = "ENT",
  [ButtonID.CDI] = "CDI",
  [ButtonID.OBS] = "OSB",
  [ButtonID.MSG] = "MSG",
  [ButtonID.FPL] = "FPL",
  [ButtonID.VNAV] = "VNAV",
  [ButtonID.PROC] = "PROC",
}

ButtonIDToButtonName = {
  [ButtonID.SHIFT] = "SHIFT",
  [ButtonID.KNOB] = "KNOB",
  [ButtonID.AP] = "AP",
  [ButtonID.HDG] = "HDG",
  [ButtonID.NAV] = "NAV",
  [ButtonID.APR] = "APR",
  [ButtonID.ALT] = "ALT",
  [ButtonID.VS] = "VS",
  [ButtonID.D] = "D",
  [ButtonID.MENU] = "MENU",
  [ButtonID.CLR] = "CLR",
  [ButtonID.ENT] = "ENT",
  [ButtonID.CDI] = "AP",
  [ButtonID.OBS] = "HDG",
  [ButtonID.MSG] = "NAV",
  [ButtonID.FPL] = "APR",
  [ButtonID.VNAV] = "ALT",
  [ButtonID.PROC] = "VS",
}
