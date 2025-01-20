# Microchip FPGA UJTAG Tutorial

1/15/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

The SmartFusion2 Security Evaluation Kit I have has the silkscreen text:

  M2GL_M2S-EVAL-KIT
  DVP-102-000402-001
  Rev D

The SF2 Security Users Guide (UG0594) Revision 4 revision history section 
indicates that Revision 3.0 of the document was updated for the Rev E design.

I could not find the Rev D User Guide (I found 3.1 and 4.0). I did find the Rev D
schematic, and the major difference observed, is that the FTDI interface on Rev D
only supports SPI mode to the SF2, whereas the Rev E design implements an
Embedded FlashPro5 JTAG interface. 

For JTAG-to-Register testing I used an external FlashPro5 programmer connected
to the FP4 (FlashPro4) header.

