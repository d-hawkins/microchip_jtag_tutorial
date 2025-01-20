# -----------------------------------------------------------------------------
# questasim.tcl
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Siemens Questasim simulation script.
#
# Script execution;
#
# 1. Start Questasim
#
# 2. Use the Tcl console to change to the project directory
#
# 3. Run this script
#
#    tcl> source scripts/questasim.tcl
#
# The script will create the Questasim output in the build/ directory.
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Toolname check
# -----------------------------------------------------------------------------
#
# The executable string under Windows was:
# C:/software/questasim_2023.4/win64/vish.exe
set toolname [file rootname [file tail [info nameofexecutable]]]
if {![string equal $toolname "vish"]} {
	error "questasim.tcl: Error: unexpected tool name '$toolname'!"
}

# -----------------------------------------------------------------------------
# Questasim build
# -----------------------------------------------------------------------------
#
set qwork build/questasim
if {![file exist $qwork]} {

	# Setup and map the work directory
	echo "questasim.tcl: Setting up Questasim work directory"

	# Setup the work library
	if {![file exists build]} {
		file mkdir build
	}

	# Create and map the work library
	vlib $qwork
	vmap work $qwork
}

# -----------------------------------------------------------------------------
# Testbench procedures
# -----------------------------------------------------------------------------
#
# The procedures compile the components, since the ProASIC3 simulation
# model is different than that used by newer devices like the SmartFusion2.
#
# Libero SoC UJTAG device
proc ujtag_sf2_tb {} {

	# Libero SoC path
	if {![info exists MICROCHIP_LIBERO_SOC]} {
		if {[info exists ::env(MICROCHIP_LIBERO_SOC)]} {
			set MICROCHIP_LIBERO_SOC $::env(MICROCHIP_LIBERO_SOC)
		} else {
			error "questasim.tcl: Error: Missing environment variable MICROCHIP_LIBERO_SOC!"
		}
	}

	# The UJTAG component is present in smartfusion2.v and rtg4.v
	# (but not in polarfire.v!)
	vlog $MICROCHIP_LIBERO_SOC/Designer/lib/vlog/smartfusion2.v

	# Generic JTAG TAP to provide a waveform view
	vlog ../jtag_tap/test/jtag_tap.sv

	# UJTAG wrapper (for port matching of ProASIC3 and SmartFusion2 devices)
	vlog test/ujtag_wrapper_sf2.sv

	# UJTAG testbench
	vlog test/ujtag_tb.sv

	# UJTAG simulation requires -t ps to generate UDRCK correctly
	vsim -t ps -voptargs=+acc +nowarnTSCALE ujtag_tb
	do scripts/ujtag_tb.do
	run -a
}

proc ujtag_pa3_tb {} {

	# Libero IDE path
	if {![info exists MICROCHIP_LIBERO_IDE]} {
		if {[info exists ::env(MICROCHIP_LIBERO_IDE)]} {
			set MICROCHIP_LIBERO_IDE $::env(MICROCHIP_LIBERO_IDE)
		} else {
			error "questasim.tcl: Error: Missing environment variable MICROCHIP_LIBERO_IDE!"
		}
	}

	# RTAX and ProASIC3
	vlog $MICROCHIP_LIBERO_IDE/Designer/lib/vlog/proasic3e.v

	# Generic JTAG TAP to provide a waveform view
	vlog ../jtag_tap/test/jtag_tap.sv

	# UJTAG wrapper (for port matching of ProASIC3 and SmartFusion2 devices)
	vlog test/ujtag_wrapper_pa3.sv

	# UJTAG testbench
	vlog test/ujtag_tb.sv

	# UJTAG simulation requires -t ps to generate UDRCK correctly
	vsim -t ps -voptargs=+acc +nowarnTSCALE ujtag_tb
	do scripts/ujtag_tb.do
	run -a
}

echo " "
echo "Testbench Procedures"
echo "--------------------"
echo " "
echo " ujtag_pa3_tb - run the UJTAG ProASIC3 testbench"
echo " ujtag_sf2_tb - run the UJTAG Smartfusion2 (and newer) testbench"
echo " "
