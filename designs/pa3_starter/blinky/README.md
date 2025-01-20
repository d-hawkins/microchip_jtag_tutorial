# Microchip FPGA UJTAG Tutorial

1/15/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

Microchip ProASIC3 Starter Kit 'blinky' design.

-------------------------------------------------------------------------------
# Synthesis

1. Start Libero IDE v11.9sp6

2. Run the project setup script via "Project > Execute Script" and select

 ~~~
 c:/github/microchip_jtag_tutorial/designs/pa3_starter/blinky/scripts/libero.tcl
 ~~~

3. Synthesis and Place-and-Route.

 Click the green play button in the Libero SoC GUI to run synthesis and place-and-route.

4. Timing Analysis.

 In the 'Design Flow' window, double-click the 'Verify Timing' step.

5. Generate bitstream.

 In the 'Design Flow' window, double-click the 'Generate Programming Data' step.

6. Program the board.

 In the 'Design Flow' window, double-click the 'Program Device' step.
 
