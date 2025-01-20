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
set clk_period 20.0
create_clock -name clk_50mhz -period $clk_period [get_ports {clk_50mhz}]
set_clock_groups -asynchronous -group [get_clocks {clk_50mhz}]

# -----------------------------------------------------------------------------
# JTAG clock
# -----------------------------------------------------------------------------
#
# 33MHz
set drck_period 30.0
create_clock -name ujtag_drck -period $drck_period [get_pins {u1/UDRCK}]
set_clock_groups -asynchronous -group [get_clocks {ujtag_drck}]

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

# LED driven by clk_50mhz
# -----------------------
#
# Clock-to-output delays
set tco_max 6.5
set tco_min 3.5

# Output delay constraints
set output_max [expr {$clk_period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock clk_50mhz [get_ports {led[6]}]

# Output hold analysis delay
set_output_delay -min $output_min -clock clk_50mhz [get_ports {led[6]}]

# LEDs driven by ujtag_drck
# -------------------------
#
# Clock-to-output delays
set tco_max 6.0
set tco_min 2.9

# Output delay constraints
set output_max [expr {$drck_period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock ujtag_drck \
	[get_ports {led[3] led[2] led[1] led[0]}]

# Output hold analysis delay
set_output_delay -min $output_min -clock ujtag_drck \
	[get_ports {led[3] led[2] led[1] led[0]}]
