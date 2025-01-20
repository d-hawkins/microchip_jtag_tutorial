# -----------------------------------------------------------------------------
# pa3_starter_libero.sdc
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# ProASIC3 Starter Kit Synopsys Design Constraints (SDC).
#
# This Libero-specific SDC file was created as the create_clock command
# for the UDRCK could not be made consistent between the Synplify SDC and
# Libero SDC. The Synplify SDC also supports full Tcl syntax, whereas
# the Libero SDC does not, eg., 'puts' and 'info' do not work.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Global Clock
# -----------------------------------------------------------------------------
#
# 40MHz
set clk_period 25.0
create_clock -name clk_40mhz -period $clk_period clk_40mhz

# -----------------------------------------------------------------------------
# JTAG clock
# -----------------------------------------------------------------------------
#
# 20MHz
set drck_period 50.0
create_clock -name jtag_tck -period $drck_period tck
create_clock -name ujtag_drck -period $drck_period u1:UDRCK

# -----------------------------------------------------------------------------
# Output Constraints
# -----------------------------------------------------------------------------
#
# The SmartTime clock-to-output delays were adjusted until the reported
# margin was under 0.1ns.
#

# LED driven by clk_40mhz
# -----------------------
#
# Clock-to-output delays
set tco_max 16.2
set tco_min  4.5

# Output delay constraints
set output_max [expr {$clk_period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock clk_40mhz [get_ports {led[7]}]

# Output hold analysis delay
set_output_delay -min $output_min -clock clk_40mhz [get_ports {led[7]}]

# LEDs driven by ujtag_drck
# -------------------------
#
# Clock-to-output delays
set tco_max 17.9
set tco_min  5.2

# Output delay constraints
set output_max [expr {$drck_period - $tco_max}]
set output_min -$tco_min

# Output setup analysis delay
set_output_delay -max $output_max -clock ujtag_drck \
	[get_ports {led[6] led[5] led[4] led[3] led[2] led[1] led[0]}]

# Output hold analysis delay
set_output_delay -min $output_min -clock ujtag_drck \
	[get_ports {led[6] led[5] led[4] led[3] led[2] led[1] led[0]}]
