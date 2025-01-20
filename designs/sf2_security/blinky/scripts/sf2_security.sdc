# -----------------------------------------------------------------------------
# sf2_security.sdc
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# SmartFusion2 Security Synopsys Design Constraints (SDC).
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Global Clock
# -----------------------------------------------------------------------------
#
# 50MHz
set clk_period 20.0
create_clock -name clk_50mhz -period $clk_period [get_ports {clk_50mhz}]
set_clock_groups -asynchronous -group [get_clocks {clk_50mhz}]

# -----------------------------------------------------------------------------
# Input-to-Output Constraints
# -----------------------------------------------------------------------------
#
# The SmartTime input-to-output delays were adjusted until the reported
# margin was under 0.1ns.
#
# tio(max) = 5.918ns
# tio(min) = 3.557ns
#
# Input-to-output delays
set tio_max 6.0
set tio_min 3.5

# Input-to-output delay constraints
set_max_delay $tio_max -from [get_ports {uart_rxd}] -to  [get_ports {uart_txd}]
set_min_delay $tio_min -from [get_ports {uart_rxd}] -to  [get_ports {uart_txd}]

# -----------------------------------------------------------------------------
# Output Constraints
# -----------------------------------------------------------------------------
#
# The SmartTime clock-to-output delays were adjusted until the reported
# margin was under 0.1ns.
#

# LEDs driven by clk_50mhz
# ------------------------
#
# Clock-to-output delays
set tco_max 10.0
set tco_min  6.1

# Output delay constraints
set output_max [expr {$clk_period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock clk_50mhz [get_ports {led[*]}]

# Output hold analysis delay
set_output_delay -min $output_min -clock clk_50mhz [get_ports {led[*]}]
