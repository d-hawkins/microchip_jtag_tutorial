# -----------------------------------------------------------------------------
# sf2_starter.sdc
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# SmartFusion2 Starter Kit Synopsys Design Constraints (SDC).
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# JTAG clock
# -----------------------------------------------------------------------------
#
# 33MHz
set drck_period 30.0
create_clock -name ujtag_drck -period $drck_period [get_pins {u1/UDRCK}]
set_clock_groups -asynchronous -group [get_clocks {ujtag_drck}]

# -----------------------------------------------------------------------------
# Output Constraints
# -----------------------------------------------------------------------------
#
# The SmartTime clock-to-output delays were adjusted until the reported
# margin was under 0.1ns.
#

# LED driven by ujtag_drck
# -------------------------
#
# Clock-to-output delays
set tco_max 11.2
set tco_min  5.9

# Output delay constraints
set output_max [expr {$drck_period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock ujtag_drck [get_ports {led}]

# Output hold analysis delay
set_output_delay -min $output_min -clock ujtag_drck [get_ports {led}]
