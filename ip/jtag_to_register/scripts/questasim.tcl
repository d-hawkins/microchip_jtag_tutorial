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
# Microchip UJTAG
# -----------------------------------------------------------------------------
#
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

# -----------------------------------------------------------------------------
# Component
# -----------------------------------------------------------------------------
#
vlog src/jtag_to_register.sv

# -----------------------------------------------------------------------------
# Testbench
# -----------------------------------------------------------------------------
#
# Generic JTAG TAP to provide a waveform view
vlog ../jtag_tap/test/jtag_tap.sv

# JTAG-to-Register testbench
vlog test/jtag_to_register_tb.sv

# -----------------------------------------------------------------------------
# Testbench procedure
# -----------------------------------------------------------------------------
#
# Testbench procedure
proc jtag_to_register_tb {} {
	# UJTAG simulation requires -t ps to generate UDRCK correctly
	vsim -t ps -voptargs=+acc +nowarnTSCALE jtag_to_register_tb
	do scripts/jtag_to_register_tb.do
	run -a
}

echo " "
echo "Testbench Procedures"
echo "--------------------"
echo " "
echo " jtag_to_register_tb - run the JTAG-to-register testbench"
echo " "
