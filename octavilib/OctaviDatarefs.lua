--dataref definitions --- needs cleanup

--dataref("COM1", "sim/cockpit/radios/com1_stdby_freq_hz", "writable")
COM1 = dataref_table("sim/cockpit/radios/com1_stdby_freq_hz")

--dataref("COM2", "sim/cockpit/radios/com2_stdby_freq_hz", "writable")
COM2 = dataref_table("sim/cockpit/radios/com2_stdby_freq_hz")
--COM2 = dataref_table("sim/cockpit/radios/com2_freq_hz")

--dataref("NAV1", "sim/cockpit/radios/nav1_stdby_freq_hz", "writable")
--dataref("NAV1", "sim/cockpit2/radios/actuators/nav1_standby_frequency_hz", "writable")
NAV1 = dataref_table("sim/cockpit/radios/nav1_stdby_freq_hz")

--dataref("NAV2", "sim/cockpit/radios/nav2_stdby_freq_hz", "writable")
NAV2 = dataref_table("sim/cockpit/radios/nav2_stdby_freq_hz")
--NAV2 = dataref_table("sim/cockpit/radios/nav2_freq_hz")

--dataref("HDG1", "sim/cockpit/autopilot/heading_mag", "writable")
HDG1 = dataref_table("sim/cockpit/autopilot/heading_mag")

dataref("NAV1_OBS", "sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot", "writable")
dataref("NAV2_OBS", "sim/cockpit2/radios/actuators/nav2_obs_deg_mag_copilot", "writable")
dataref("COM1_POWER", "sim/cockpit2/radios/actuators/com1_power", "writable")

G430_NCS = dataref_table("sim/cockpit/g430/g430_nav_com_sel")

--dataref("ADF1", "sim/cockpit/radios/adf1_stdby_freq_hz", "writable")
--ADF1 = dataref_table("sim/cockpit/radios/adf1_stdby_freq_hz")
ADF1 = dataref_table("sim/cockpit/radios/adf1_freq_hz")
dataref("ADF1_CARD", "sim/cockpit2/radios/actuators/adf1_card_heading_deg_mag_pilot", "writable")

XPDR = dataref_table("sim/cockpit/radios/transponder_code")
--dataref("XPDR_ALT", "sim/cockpit2/radios/actuators/transponder_code", "writable")

--dataref("NAVCOMSEL", "sim/cockpit/g430/g430_nav_com_sel", "writable", 1)
--NAVCOMSEL=dataref_table("sim/cockpit/g430/g430_nav_com_sel")

AP_MODE = dataref_table("sim/cockpit/autopilot/autopilot_mode")
AP_STATE = dataref_table("sim/cockpit/autopilot/autopilot_state")
dataref("BACKCOURSE_ON", "sim/cockpit2/autopilot/backcourse_on")
dataref("APPROACH_STATUS", "sim/cockpit2/autopilot/approach_status")

AP_ALT = dataref_table("sim/cockpit/autopilot/altitude")
AP_VS = dataref_table("sim/cockpit/autopilot/vertical_velocity")
