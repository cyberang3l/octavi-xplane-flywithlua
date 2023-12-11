-- https://github.com/cyberang3l/octavi-xplane-flywithlua

COM1 = dataref_table("sim/cockpit/radios/com1_stdby_freq_hz")
COM2 = dataref_table("sim/cockpit/radios/com2_stdby_freq_hz")
NAV1 = dataref_table("sim/cockpit/radios/nav1_stdby_freq_hz")
NAV2 = dataref_table("sim/cockpit/radios/nav2_stdby_freq_hz")
HDG1 = dataref_table("sim/cockpit/autopilot/heading_mag")

dataref("NAV1_OBS", "sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot", "writable")
dataref("NAV2_OBS", "sim/cockpit2/radios/actuators/nav2_obs_deg_mag_copilot", "writable")
dataref("COM1_POWER", "sim/cockpit2/radios/actuators/com1_power", "writable")

G430_NCS = dataref_table("sim/cockpit/g430/g430_nav_com_sel")
ADF1 = dataref_table("sim/cockpit/radios/adf1_freq_hz")
dataref("ADF1_CARD", "sim/cockpit2/radios/actuators/adf1_card_heading_deg_mag_pilot", "writable")

XPDR = dataref_table("sim/cockpit/radios/transponder_code")

AP_MODE = dataref_table("sim/cockpit/autopilot/autopilot_mode")
AP_STATE = dataref_table("sim/cockpit/autopilot/autopilot_state")
dataref("BACKCOURSE_ON", "sim/cockpit2/autopilot/backcourse_on")
dataref("APPROACH_STATUS", "sim/cockpit2/autopilot/approach_status")

AP_ALT = dataref_table("sim/cockpit/autopilot/altitude")
AP_VS = dataref_table("sim/cockpit/autopilot/vertical_velocity")
