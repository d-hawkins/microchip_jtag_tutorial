// ----------------------------------------------------------------------------
// jtag_tap.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// JTAG Test Access Port (TAP) State Machine.
//
// This FSM is used for debugging/annotating JTAG simulations.
//
// ----------------------------------------------------------------------------

module jtag_tap (
      input logic trst_n,
      input logic tck,
      input logic tms
   );

   // -------------------------------------------------------------------------
   // FSM enumeration
   // -------------------------------------------------------------------------
   //
   enum {
      TLR,  // Test-Logic-Reset
      RTI,  // Run-Test-Idle
      //
      // Data states
      SDRS, // Select-DR-Scan
      CDR,  // Capture-DR
      SDR,  // Shift-DR
      E1DR, // Exit1-DR
      PDR,  // Pause-DR
      E2DR, // Exit2-DR
      UDR,  // Update-DR
      //
      // Instruction states
      SIRS, // Select-IR-Scan
      CIR,  // Capture-IR
      SIR,  // Shift-IR
      E1IR, // Exit1-IR
      PIR,  // Pause-IR
      E2IR, // Exit2-IR
      UIR   // Update-IR
   } state = TLR;

   // -------------------------------------------------------------------------
   // FSM state transitions
   // -------------------------------------------------------------------------
   //
   always_ff @(negedge trst_n or posedge tck)
   begin
      if (~trst_n) begin
         state <= TLR;
      end
      else begin
         case (state)

            // Test-Logic-Reset
            TLR:
               if (~tms) begin
                  state <= RTI;
               end

            // Run-Test-Idle
            RTI:
               if (tms) begin
                  state <= SDRS;
               end

            // ----------------------------------------------------------------
            // Data states
            // ----------------------------------------------------------------
            //
            // Select-DR-Scan
            SDRS:
               if (~tms) begin
                  state <= CDR;
               end
               else begin
                  state <= SIRS;
               end

            // Capture-DR
            CDR:
               if (~tms) begin
                  state <= SDR;
               end
               else begin
                  state <= E1DR;
               end

            // Shift-DR
            SDR:
               if (tms) begin
                  state <= E1DR;
               end

            // Exit1-DR
            E1DR:
               if (~tms) begin
                  state <= PDR;
               end
               else begin
                  state <= UDR;
               end

            // Pause-DR
            PDR:
               if (tms) begin
                  state <= E2DR;
               end

            // Exit2-DR
            E2DR:
               if (~tms) begin
                  state <= SDR;
               end
               else begin
                  state <= UDR;
               end

            // Update-DR
            UDR:
               if (~tms) begin
                  state <= RTI;
               end
               else begin
                  state <= SDRS;
               end

            // ----------------------------------------------------------------
            // Instruction states
            // ----------------------------------------------------------------
            //
            // Select-IR-Scan
            SIRS:
               if (~tms) begin
                  state <= CIR;
               end
               else begin
                  state <= TLR;
               end

            // Capture-IR
            CIR:
               if (~tms) begin
                  state <= SIR;
               end
               else begin
                  state <= E1IR;
               end

            // Shift-IR
            SIR:
               if (tms) begin
                  state <= E1IR;
               end

            // Exit1-IR
            E1IR:
               if (~tms) begin
                  state <= PIR;
               end
               else begin
                  state <= UIR;
               end

            // Pause-IR
            PIR:
               if (tms) begin
                  state <= E2IR;
               end

            // Exit2-IR
            E2IR:
               if (~tms) begin
                  state <= SIR;
               end
               else begin
                  state <= UIR;
               end

            // Update-IR
            UIR:
               if (~tms) begin
                  state <= RTI;
               end
               else begin
                  state <= SDRS;
               end
         endcase
      end
   end
endmodule

