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
# C:/software/Microchip/Libero_SoC_v2024.1/Designer/bin/libero.exe
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

# Repository and IP directory
set repo    [file dirname [file dirname [file dirname $top]]]
set ip      $repo/ip

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
# SmartFusion2 Security Evaluation Board
new_project \
	-location $build                                 \
	-name {sf2_security}                             \
	-project_description {}                          \
	-block_mode 0                                    \
	-standalone_peripheral_initialization 0          \
	-instantiate_in_smartdesign 1                    \
	-ondemand_build_dh 1                             \
	-use_relative_path 0                             \
	-linked_files_root_dir_env {}                    \
	-hdl {VERILOG}                                   \
	-family {SmartFusion2}                           \
	-die {M2S090TS}                                  \
	-package {484 FBGA}                              \
	-speed {-1}                                      \
	-die_voltage {1.2}                               \
	-part_range {COM}                                \
	-adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} \
	-adv_options {IO_DEFT_STD:LVCMOS 2.5V}           \
	-adv_options {PLL_SUPPLY:PLL_SUPPLY_25}          \
	-adv_options {RESTRICTPROBEPINS:1}               \
	-adv_options {RESTRICTSPIPINS:0}                 \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0}  \
	-adv_options {TEMPR:COM}                         \
	-adv_options {VCCI_1.2_VOLTR:COM}                \
	-adv_options {VCCI_1.5_VOLTR:COM}                \
	-adv_options {VCCI_1.8_VOLTR:COM}                \
	-adv_options {VCCI_2.5_VOLTR:COM}                \
	-adv_options {VCCI_3.3_VOLTR:COM}                \
	-adv_options {VOLTR:COM}

# Source
create_links                         \
	-convert_EDN_to_HDL 0            \
	-hdl_source $src/sf2_security.sv \
	-hdl_source $ip/jtag_to_register/src/jtag_to_register.sv

# Constraints
create_links                          \
	-convert_EDN_to_HDL 0             \
	-io_pdc $scripts/sf2_security.pdc \
	-sdc $scripts/sf2_security.sdc

# Set the design root
build_design_hierarchy
set_root -module {sf2_security::work}

# Enable SDC for synthesis
organize_tool_files -tool {SYNTHESIZE} \
	-file $scripts/sf2_security.sdc    \
	-module {sf2_security::work}       \
	-input_type {constraint}

# Enable PDC and SDC for place-and-route
organize_tool_files -tool {PLACEROUTE} \
	-file $scripts/sf2_security.sdc    \
	-file $scripts/sf2_security.pdc    \
	-module {sf2_security::work}       \
	-input_type {constraint}

# Enable SDC for timing verification
organize_tool_files -tool {VERIFYTIMING} \
	-file $scripts/sf2_security.sdc      \
	-module {sf2_security::work}         \
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

# Run "Generate Bitstream"
#run_tool -name {GENERATEPROGRAMMINGFILE}

# Run "Run PROGRAM Action"
# run_tool -name {PROGRAMDEVICE}

puts "libero.tcl: ended"
puts [string repeat = 80]

