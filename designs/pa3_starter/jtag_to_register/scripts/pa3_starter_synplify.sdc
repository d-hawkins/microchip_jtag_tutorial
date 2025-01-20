# -----------------------------------------------------------------------------
# pa3_starter_synplify.sdc
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# ProASIC3 Starter Kit Synopsys Design Constraints (SDC).
#
# -----------------------------------------------------------------------------

puts [string repeat = 80]
puts "pa3_starter_synplify.sdc: started"

# -----------------------------------------------------------------------------
# Toolname check
# -----------------------------------------------------------------------------
#
# The executable string under Windows was:
# C:/software/Synopsys/fpga_V-2023.09/bin64/m_proasic.exe
puts "pa3_starter_synplify.sdc: info = [info nameofexecutable]"
set toolname [file rootname [file tail [info nameofexecutable]]]
if {![string equal $toolname "m_proasic"]} {
	error "pa3_starter_synplify.sdc: Error: unexpected tool name '$toolname'!"
} else {
	puts "pa3_starter_synplify.sdc: Synplify detected"
}

# -----------------------------------------------------------------------------
# Global Clock
# -----------------------------------------------------------------------------
#
# 40MHz
set clk_period 25.0
create_clock -name clk_40mhz -period $clk_period [get_ports {clk_40mhz}]
set_clock_groups -asynchronous -group [get_clocks {clk_40mhz}]

# -----------------------------------------------------------------------------
# JTAG clock
# -----------------------------------------------------------------------------
#
# 20MHz
set drck_period 50.0
create_clock -name jtag_tck -period $drck_period [get_ports {tck}]
create_clock -name ujtag_drck -period $drck_period [get_pins {u1/UDRCK}]
set_clock_groups -asynchronous -group [get_clocks {jtag_tck ujtag_drck}]

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

puts "pa3_starter_synplify.sdc: ended"
puts [string repeat = 80]
