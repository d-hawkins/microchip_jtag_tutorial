# Microchip FPGA UJTAG Tutorial

1/15/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

PolarFire SoC Discovery Kit 'jtag_to_register' design.

-------------------------------------------------------------------------------
# Synthesis

1. Start Libero SoC

2. Run the project setup script via "Project > Execute Script" and select

 ~~~
 c:/github/microchip_jtag_tutorial/designs/pfs_disco/jtag_to_register/scripts/libero.tcl
 ~~~

3. Synthesis and Place-and-Route.

 Click the green play button in the Libero SoC GUI to run synthesis and place-and-route.

4. Timing Analysis.

 In the 'Design Flow' window, double-click the 'Verify Timing' step.

5. Generate bitstream.

 In the 'Design Flow' window, double-click the 'Generate Bitstream' step.

6. Program the board.

 In the 'Design Flow' window, double-click the 'Run PROGRAM Action' step.
 
7. FlashPro Express project.

 In the 'Design Flow' window, double-click the 'Export FlashPro Express Job' step.

 The FlashPro Express project can be used to run the JTAG-to-Register STAPL file.
 