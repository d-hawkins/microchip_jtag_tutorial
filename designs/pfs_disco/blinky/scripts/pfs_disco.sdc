# -----------------------------------------------------------------------------
# pfs_disco.sdc
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Microchip PolarFire SoC Discovery Kit Synopsys Design Constraints (SDC).
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Global Clock
# -----------------------------------------------------------------------------
#
# 50MHz
set period 20.0
create_clock -name clk_50mhz -period $period [get_ports {clk_50mhz}]

# -----------------------------------------------------------------------------
# Input-to-Output Constraints
# -----------------------------------------------------------------------------
#
# The SmartTime input-to-output delays were adjusted until the reported
# margin was under 0.1ns.
#
# tio(max) = 4.648ns
# tio(min) = 3.381ns
#
# Input-to-output delays
set tio_max 4.7
set tio_min 2.3

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
# tco(max) = 6.454ns
# tco(min) = 3.577ns
#
# Clock-to-output delays
set tco_max 6.5
set tco_min 3.5

# Output delay constraints
set output_max [expr {$period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock clk_50mhz [get_ports {led[*]}]

# Output hold analysis delay
set_output_delay -min $output_min -clock clk_50mhz [get_ports {led[*]}]

