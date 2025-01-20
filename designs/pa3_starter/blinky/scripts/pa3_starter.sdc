# -----------------------------------------------------------------------------
# pa3_starter.sdc
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# ProASIC3 Starter Kit Synopsys Design Constraints (SDC).
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Global Clock
# -----------------------------------------------------------------------------
#
# 40MHz
set clk_period 25.0
create_clock -name clk_40mhz -period $clk_period [get_ports {clk_40mhz}]
set_clock_groups -asynchronous -group [get_clocks {clk_40mhz}]

# -----------------------------------------------------------------------------
# Output Constraints
# -----------------------------------------------------------------------------
#
# The SmartTime clock-to-output delays were adjusted until the reported
# margin was under 0.1ns.
#

# LEDs driven by clk_40mhz
# ------------------------
#
# Clock-to-output delays
set tco_max 16.2
set tco_min  4.5

# Output delay constraints
set output_max [expr {$clk_period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock clk_40mhz [get_ports {led[*]}]

# Output hold analysis delay
set_output_delay -min $output_min -clock clk_40mhz [get_ports {led[*]}]
