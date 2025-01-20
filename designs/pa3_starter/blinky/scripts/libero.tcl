# -----------------------------------------------------------------------------
# libero.tcl
#
# 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Microchip Libero SoC GUI project creation script.
#
# Script execution;
#
# 1. Start Libero SoC
#
# 2. Select Project -> Execute Script
#
#    and select this script with no arguments.
#
# The script will create the build/ directory, create a project, add the
# source and constraints, and then run synthesis and place-and-route.
#
# The Libero GUI can then be used to open tools such as ChipPlanner
# (to review the floorplan) and SmartTime (to review timing).
#
# -----------------------------------------------------------------------------

puts [string repeat = 80]
puts "libero.tcl: started"

# -----------------------------------------------------------------------------
# Toolname check
# -----------------------------------------------------------------------------
#
# The executable string under Windows was:
# C:/software/Microsemi/Libero_SoC_v11.9/Designer/bin/libero.exe
set toolname [file rootname [file tail [info nameofexecutable]]]
if {![string equal $toolname "libero"]} {
	error "libero.tcl: Error: unexpected tool name '$toolname'!"
}

# -----------------------------------------------------------------------------
# Project Directories
# -----------------------------------------------------------------------------
#
# The command 'pwd' returns the path to the scripts/ folder, while
# 'info script' returns the path to scripts/libero.tcl.
#
# Change directory to the project folder
cd ../

# Project directories
set top     [pwd]
set src     $top/src
set scripts $top/scripts
set build   $top/build

# -----------------------------------------------------------------------------
# Build Directory
# -----------------------------------------------------------------------------
#
# This script is designed to create a project from scratch, so the build
# directory should not exist. Rather than delete the folder, ask the user
# to remove it (this saves accidentally deleting a useful project!).
# Libero creates the project directory.
#
if {[file exists $build]} {
	error "libero.tcl: Error: the build directory already exists!"
}

# -----------------------------------------------------------------------------
# Libero Project
# -----------------------------------------------------------------------------
#
# The following commands were determined by manually creating a project, and
# then using 'Project -> Export Script' to create a script with Tcl commands.
# The commands were then edited to use the variables within this script.
#
# ProASIC3 Starter Kit
new_project \
	-location $build                        \
	-name {pa3_starter}                     \
	-project_description {}                 \
	-block_mode 0                           \
	-standalone_peripheral_initialization 0 \
	-instantiate_in_smartdesign 1           \
	-use_enhanced_constraint_flow 1         \
	-hdl {VERILOG}                          \
	-family {ProASIC3E}                     \
	-die {A3PE1500}                         \
	-package {208 PQFP}                     \
	-speed {STD}                            \
	-die_voltage {1.5}                      \
	-part_range {COM}                       \
	-adv_options {IO_DEFT_STD:LVTTL}        \
	-adv_options {RESTRICTPROBEPINS:1}      \
	-adv_options {RESTRICTSPIPINS:0}        \
	-adv_options {TEMPR:COM}                \
	-adv_options {VCCI_1.5_VOLTR:COM}       \
	-adv_options {VCCI_1.8_VOLTR:COM}       \
	-adv_options {VCCI_2.5_VOLTR:COM}       \
	-adv_options {VCCI_3.3_VOLTR:COM}       \
	-adv_options {VOLTR:COM}

# Enable SystemVerilog files
# * Set the Project > Settings, Design Flow, SystemVerilog radio button
project_settings -verilog_mode {SYSTEM_VERILOG}

# Source
create_links                        \
	-convert_EDN_to_HDL 0           \
	-hdl_source $src/pa3_starter.sv

# Constraints
create_links                      \
	-convert_EDN_to_HDL 0         \
	-pdc $scripts/pa3_starter.pdc \
	-sdc $scripts/pa3_starter.sdc

# Enable SDC for synthesis
organize_tool_files -tool {SYNTHESIZE} \
	-file $scripts/pa3_starter.sdc     \
	-module {pa3_starter::work}        \
	-input_type {constraint}

# Enable PDC and SDC for place-and-route
organize_tool_files -tool {COMPILE} \
	-file $scripts/pa3_starter.sdc  \
	-file $scripts/pa3_starter.pdc  \
	-module {pa3_starter::work}     \
	-input_type {constraint}

# -----------------------------------------------------------------------------
# Run Synthesis and Place-and-Route
# -----------------------------------------------------------------------------
#
# Comment the following lines to have the script only setup the project.
# The user can then click on the green arrow to synthesize the project.
# This allows the script to complete quickly for projects where user
# interaction with the Libero GUI is expected.
#
# Run "Place and Route"
#run_tool -name {PLACEROUTE}

# Run "Verify Timing"
#run_tool -name {VERIFYTIMING}

# Run "Generate Programming Data"
#run_tool -name {GENERATEPROGRAMMINGDATA}

# Run "Program Device"
# run_tool -name {PROGRAMDEVICE}

puts "libero.tcl: ended"
puts [string repeat = 80]

