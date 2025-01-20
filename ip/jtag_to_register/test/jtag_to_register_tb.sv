// ----------------------------------------------------------------------------
// jtag_to_register_tb.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip UJTAG-to-register testbench.
//
// ----------------------------------------------------------------------------
// References
// ----------
//
// [1] Microchip, "SmartFusion2 and IGLOO2 Macro Library Guide", 2020.
//     (sf2_mlg.pdf)
//
// [2] Microchip, "RTG4 Macro Library Guide", 2020.
//     (rtg4_mlg.pdf)
//
// ----------------------------------------------------------------------------

module jtag_to_register_tb #(
		// Parallel register bit-width
		parameter int WIDTH      = 8,

		// Use Update-DR as a clock
		// * Xilinx BSCAN requires UPDATE_CLK = 1
		parameter int UPDATE_CLK = 0
	);

	// ------------------------------------------------------------------------
	// Parameters
	// ------------------------------------------------------------------------
	//
	// JTAG TCK frequency
	localparam real TCK_FREQUENCY = 10.0e6;

	// JTAG TCK period
	localparam time TCK_PERIOD = (1.0e9/TCK_FREQUENCY)*1ns;

	// Free run TCK in RTI
	localparam bit RTI_TCK_FREE_RUN = 1'b0;
	localparam int RTI_TCK_PERIODS  = 10;

	// ------------------------------------------------------------------------
	// Signals
	// ------------------------------------------------------------------------
	//
	// JTAG
	logic trst_n;
	logic tck;
	logic tms;
	logic tdi;
	logic tdo;

	// IR register
	logic [7:0] ujtag_ir;
	logic       ujtag_sel; // User select

	// UJTAG state
	logic ujtag_tlr_n; // Test-Logic-Reset
	logic ujtag_tlr;   // Test-Logic-Reset
	logic ujtag_cdr;   // Capture-DR
	logic ujtag_sdr;   // Shift-DR
	logic ujtag_udr;   // Update-DR

	// User serial interface
	logic ujtag_drck;
	logic ujtag_tdi;
	logic ujtag_tdo;

	// Control/status
	logic [WIDTH-1:0] control;
	logic [WIDTH-1:0] status;

	// ------------------------------------------------------------------------
	// JTAG TAP
	// ------------------------------------------------------------------------
	//
	// The SystemVerilog enumeration in this component is used for decoding
	// and viewing the JTAG TAP state in the Questasim waveform view.
	//
	jtag_tap u1 (
      .trst_n (trst_n),
      .tck    (tck   ),
      .tms    (tms   )
   );

	// ------------------------------------------------------------------------
	// UJTAG
	// ------------------------------------------------------------------------
	//
	UJTAG u2 (
		// JTAG
		.TRSTB  (trst_n),
		.TCK    (tck   ),
		.TMS    (tms   ),
		.TDI    (tdi   ),
		.TDO    (tdo   ),    // Output

		// User JTAG
		.UIREG  (ujtag_ir   ),    // Tap IR value
		.URSTB  (ujtag_tlr_n),    // Test-Logic-Reset
		.UDRCAP (ujtag_cdr  ),    // Capture-DR
		.UDRSH  (ujtag_sdr  ),    // Shift-DR
		.UDRUPD (ujtag_udr  ),    // Update-DR
		.UDRCK  (ujtag_drck ),    // TCK
		.UTDI   (ujtag_tdi  ),    // TDI
		.UTDO   (ujtag_tdo  )     // TDO
	);

	// User IR select
	assign ujtag_sel = ((ujtag_ir >= 'h10) && (ujtag_ir <= 'h7F));

	// Test-Logic-Reset (active high)
	assign ujtag_tlr = ~ujtag_tlr_n;

	// ------------------------------------------------------------------------
	// JTAG-to-Register
	// ------------------------------------------------------------------------
	//
	jtag_to_register #(
		.WIDTH      (WIDTH     ),
		.UPDATE_CLK (UPDATE_CLK)
	) u3 (
		.jtag_sel  (ujtag_sel ),
		.jtag_drck (ujtag_drck),
		.jtag_tdi  (ujtag_tdi ),
		.jtag_tdo  (ujtag_tdo ),
		.jtag_tlr  (ujtag_tlr ),
		.jtag_cdr  (ujtag_cdr ),
		.jtag_sdr  (ujtag_sdr ),
		.jtag_udr  (ujtag_udr ),
		.control   (control   ),
		.status    (status    )
	);

	// Loopback
	assign status = control;

	// ------------------------------------------------------------------------
	// Stimulus
	// ------------------------------------------------------------------------
	//
	logic       [7:0] USER_IR = 'h20; // User IR range is 'h10 to 'h7F
	logic       [7:0] irval = '0;
	logic [WIDTH-1:0] tdival = '0;
	logic [WIDTH-1:0] tdoval = '0;
	logic [WIDTH-1:0] expval = '0;
	initial begin
		$display(" ");
		$display("==========================================================");
		$display("JTAG-to-Register Testbench");
		$display("==========================================================");
		$display(" ");

		// --------------------------------------------------------------------
		// Defaults
		// --------------------------------------------------------------------
		//
		// JTAG interface
		trst_n = 1'b0;
		tck    = 1'b0;  // Start low to match logic analyzer traces
		tms    = 1'b1;
		tdi    = 1'b0;

		// Delay between tests
		#(10*TCK_PERIOD);

		// --------------------------------------------------------------------
		// TAP Reset
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("TAP Reset");
		$display("----------------------------------------------------------");
		$display(" ");

		trst_n = 1'b1;
		tms = 1'b1;
		for (int unsigned i = 0; i < 8; i++) begin
			tck = 1'b0;
			#(TCK_PERIOD/2);
			tck = 1'b1;
			#(TCK_PERIOD/2);
		end
		tck = 1'b0;

		// Delay between tests
		#(10*TCK_PERIOD/2);

		// --------------------------------------------------------------------
		// Shift-IR
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Shift-IR");
		$display("----------------------------------------------------------");
		$display(" ");
		//
		// TLR -> RTI -> SDRS -> SIRS -> CIR -> SIR x7 -> E1IR -> UIR -> RTI
		//     0      1       1       0      0         1       1      0
		//
		// TLR -> RTI
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// RTI -> SDRS
		tms = 1'b1;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SDRS -> SIRS
		tms = 1'b1;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SIRS -> CIR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// CIR -> SIR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SIR
		irval = USER_IR;
		for (int unsigned i = 0; i < 7; i++) begin
			tdi = irval[i];
			tck = 1'b0;
			#(TCK_PERIOD/2);
			tck = 1'b1;
			#(TCK_PERIOD/2);
		end
		//
		// SIR -> E1IR
		tms = 1'b1;
		tdi = irval[7];
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// E1IR -> UIR
		tms = 1'b1;
		tdi = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// UIR -> RTI
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		tck = 1'b0;

		// Check the IR value
		assert(ujtag_ir == USER_IR) begin
			$display("User IR value match.");
		end
		else begin
			$error("User IR value mismatch!");
		end

		// Run-Test-Idle
		if (RTI_TCK_FREE_RUN) begin
			for (int unsigned i = 0; i < RTI_TCK_PERIODS; i++) begin
				tck = 1'b0;
				#(TCK_PERIOD/2);
				tck = 1'b1;
				#(TCK_PERIOD/2);
			end
			tck = 1'b0;
		end
		else begin
			#(RTI_TCK_PERIODS*TCK_PERIOD);
		end

		// Delay between tests
		#(10*TCK_PERIOD/2);

		// --------------------------------------------------------------------
		// Shift-DR
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Shift-DR");
		$display("----------------------------------------------------------");
		$display(" ");
		//
		// RTI -> SDRS -> CDR -> SDR x31 -> E1DR -> UDR -> RTI
		//     1       0      0          1       1      0
		//
		// RTI -> SDRS
		tms = 1'b1;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SDRS -> CDR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// CDR -> SDR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SDR
		expval = '0;
		tdival = 'h44332211;
		for (int unsigned i = 0; i < (WIDTH-1); i++) begin
			tdi = tdival[i];
			tck = 1'b0;
			#(TCK_PERIOD/2);
			tdoval[i] = tdo;
			tck = 1'b1;
			#(TCK_PERIOD/2);
		end
		//
		// SDR -> E1DR
		tms = 1'b1;
		tdi = tdival[WIDTH-1];
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tdoval[WIDTH-1] = tdo;
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// E1DR -> UDR
		tms = 1'b1;
		tdi = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// UDR -> RTI
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		tck = 1'b0;

		// Check the TDI and TDO values
		assert(control == tdival) begin
			$display("TDI value match.");
		end
		else begin
			$error("TDI value mismatch!");
		end
		assert(tdoval == expval) begin
			$display("TDO value match.");
		end
		else begin
			$error("TDO value mismatch!");
		end

		// Run-Test-Idle
		if (RTI_TCK_FREE_RUN) begin
			for (int unsigned i = 0; i < RTI_TCK_PERIODS; i++) begin
				tck = 1'b0;
				#(TCK_PERIOD/2);
				tck = 1'b1;
				#(TCK_PERIOD/2);
				tck = 1'b0;
			end
		end
		else begin
			#(RTI_TCK_PERIODS*TCK_PERIOD);
		end

		// Delay between tests
		#(10*TCK_PERIOD/2);

		// --------------------------------------------------------------------
		// Shift-DR
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Shift-DR");
		$display("----------------------------------------------------------");
		$display(" ");
		//
		// RTI -> SDRS -> CDR -> SDR x31 -> E1DR -> UDR -> RTI
		//     1       0      0          1       1      0
		//
		// RTI -> SDRS
		tms = 1'b1;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SDRS -> CDR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// CDR -> SDR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SDR
		expval = tdival; // Save the previous value for TDO check
		tdival = 'h88776655;
		for (int unsigned i = 0; i < (WIDTH-1); i++) begin
			tdi = tdival[i];
			tck = 1'b0;
			#(TCK_PERIOD/2);
			tdoval[i] = tdo;
			tck = 1'b1;
			#(TCK_PERIOD/2);
		end
		//
		// SDR -> E1DR
		tms = 1'b1;
		tdi = tdival[WIDTH-1];
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tdoval[WIDTH-1] = tdo;
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// E1DR -> UDR
		tms = 1'b1;
		tdi = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// UDR -> RTI
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		tck = 1'b0;

		// Check the TDI and TDO values
		assert(control == tdival) begin
			$display("TDI value match.");
		end
		else begin
			$error("TDI value mismatch!");
		end
		assert(tdoval == expval) begin
			$display("TDO value match.");
		end
		else begin
			$error("TDO value mismatch!");
		end

		// Run-Test-Idle
		if (RTI_TCK_FREE_RUN) begin
			for (int unsigned i = 0; i < RTI_TCK_PERIODS; i++) begin
				tck = 1'b0;
				#(TCK_PERIOD/2);
				tck = 1'b1;
				#(TCK_PERIOD/2);
				tck = 1'b0;
			end
		end
		else begin
			#(RTI_TCK_PERIODS*TCK_PERIOD);
		end

		// Delay between tests
		#(10*TCK_PERIOD/2);

		// --------------------------------------------------------------------
		// Shift-DR
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("Shift-DR");
		$display("----------------------------------------------------------");
		$display(" ");
		//
		// RTI -> SDRS -> CDR -> SDR x31 -> E1DR -> UDR -> RTI
		//     1       0      0          1       1      0
		//
		// RTI -> SDRS
		tms = 1'b1;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SDRS -> CDR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// CDR -> SDR
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// SDR
		expval = tdival; // Save the previous value for TDO check
		tdival = 'hCCBBAA99;
		for (int unsigned i = 0; i < (WIDTH-1); i++) begin
			tdi = tdival[i];
			tck = 1'b0;
			#(TCK_PERIOD/2);
			tdoval[i] = tdo;
			tck = 1'b1;
			#(TCK_PERIOD/2);
		end
		//
		// SDR -> E1DR
		tms = 1'b1;
		tdi = tdival[WIDTH-1];
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tdoval[WIDTH-1] = tdo;
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// E1DR -> UDR
		tms = 1'b1;
		tdi = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		//
		// UDR -> RTI
		tms = 1'b0;
		tck = 1'b0;
		#(TCK_PERIOD/2);
		tck = 1'b1;
		#(TCK_PERIOD/2);
		tck = 1'b0;

		// Check the TDI and TDO values
		assert(control == tdival) begin
			$display("TDI value match.");
		end
		else begin
			$error("TDI value mismatch!");
		end
		assert(tdoval == expval) begin
			$display("TDO value match.");
		end
		else begin
			$error("TDO value mismatch!");
		end

		// Run-Test-Idle
		if (RTI_TCK_FREE_RUN) begin
			for (int unsigned i = 0; i < RTI_TCK_PERIODS; i++) begin
				tck = 1'b0;
				#(TCK_PERIOD/2);
				tck = 1'b1;
				#(TCK_PERIOD/2);
				tck = 1'b0;
			end
		end
		else begin
			#(RTI_TCK_PERIODS*TCK_PERIOD);
		end

		// Delay between tests
		#(10*TCK_PERIOD/2);

		// --------------------------------------------------------------------
		// TAP Reset
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("TAP Reset");
		$display("----------------------------------------------------------");
		$display(" ");

		trst_n = 1'b1;
		tms = 1'b1;
		for (int unsigned i = 0; i < 8; i++) begin
			tck = 1'b0;
			#(TCK_PERIOD/2);
			tck = 1'b1;
			#(TCK_PERIOD/2);
		end
		tck = 1'b0;

		// Delay between tests
		#(10*TCK_PERIOD/2);

		// --------------------------------------------------------------------
		// End simulation
		// --------------------------------------------------------------------
		//
		$display(" ");
		$display("----------------------------------------------------------");
		$display("End simulation");
		$display("----------------------------------------------------------");
		$display(" ");
		$stop(0);
	end

endmodule

