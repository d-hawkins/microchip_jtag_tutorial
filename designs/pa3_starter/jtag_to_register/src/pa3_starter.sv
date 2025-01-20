// ----------------------------------------------------------------------------
// pa3_starter.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip ProASIC3 Starter Kit  'jtag_to_register' design.
//
// ----------------------------------------------------------------------------

module pa3_starter (

		// --------------------------------------------------------------------
		// JTAG
		// --------------------------------------------------------------------
		//
		input        trst_n,
		input        tck,
		input        tms,
		input        tdi,
		output       tdo,

		// --------------------------------------------------------------------
		// Clock
		// --------------------------------------------------------------------
		//
		input        clk_40mhz,

		// --------------------------------------------------------------------
		// User I/O
		// --------------------------------------------------------------------
		//
		// LEDs
		output [7:0] led
	);

	// ------------------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------------------
	//
	// Clock frequency
	localparam real CLK_40MHZ_FREQUENCY = 40.0e6;

	// LED blink rate
	localparam real BLINK_PERIOD = 0.5;

	// Counter width
	//
	// Note: the integer'() casts are important, without them Vivado
	// generates incorrect counter widths (much wider than expected)
	//
	// 1 LED driven by the 40MHz clock
	localparam integer WIDTH =
		$clog2(integer'(CLK_40MHZ_FREQUENCY*BLINK_PERIOD));

	// JTAG-to-Register parameters
	localparam int JTAG_WIDTH      = 8;
	localparam int JTAG_UPDATE_CLK = 0; // Use DRCK during UPDATE

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Counter
	logic [WIDTH-1:0] count;

	// UJTAG interface
	wire  [7:0] ujtag_ir;    // User IR value (0x10 to 0x7F)
	wire        ujtag_tlr_n; // Test-Logic-Reset
	wire        ujtag_cdr;   // Capture-DR
	wire        ujtag_sdr;   // Shift-DR
	wire        ujtag_udr;   // Update-DR
	wire        ujtag_drck_o;
	wire        ujtag_drck;
	wire        ujtag_tdi;
	wire        ujtag_tdo;

	// IR decode
	logic       ujtag_sel;   // User select

	// TLR inversion
	logic       ujtag_tlr;   // Test-Logic-Reset

	// Control/status
	wire  [JTAG_WIDTH-1:0] control;
	logic [JTAG_WIDTH-1:0] status;

	// ------------------------------------------------------------------------
	// Counter
	// ------------------------------------------------------------------------
	//
	always_ff @(posedge clk_40mhz) begin
		count <= count + 1;
	end

	// ------------------------------------------------------------------------
	// LED outputs
	// ------------------------------------------------------------------------
	//
	assign led = {count[WIDTH-1], control[6:0]};

	// ------------------------------------------------------------------------
	// UJTAG
	// ------------------------------------------------------------------------
	//
	UJTAG u1 (
		// JTAG
		.TRSTB  (trst_n      ),
		.TCK    (tck         ),
		.TMS    (tms         ),
		.TDI    (tdi         ),
		.TDO    (tdo         ),

		// User JTAG
		.UIREG0 (ujtag_ir[0] ),    // Tap IR value
		.UIREG1 (ujtag_ir[1] ),
		.UIREG2 (ujtag_ir[2] ),
		.UIREG3 (ujtag_ir[3] ),
		.UIREG4 (ujtag_ir[4] ),
		.UIREG5 (ujtag_ir[5] ),
		.UIREG6 (ujtag_ir[6] ),
		.UIREG7 (ujtag_ir[7] ),
		.URSTB  (ujtag_tlr_n ),    // Test-Logic-Reset
		.UDRCAP (ujtag_cdr   ),    // Capture-DR
		.UDRSH  (ujtag_sdr   ),    // Shift-DR
		.UDRUPD (ujtag_udr   ),    // Update-DR
		.UDRCK  (ujtag_drck_o),    // Gated TCK
		.UTDI   (ujtag_tdi   ),    // TDI to user logic
		.UTDO   (ujtag_tdo   )     // TDO from user logic
	);

	// User IR select (assert for all user IR values: 16 to 127)
	assign ujtag_sel = ((ujtag_ir >= 8'h10) && (ujtag_ir <= 8'h7F));

	// Test-Logic-Reset (active high)
//	assign ujtag_tlr = ~ujtag_tlr_n;

	// Test-Logic-Reset (active high) on global net
	//  * A CLKINT is used to suppress the compile warning:
	//
	//   CMP503: Remapped 16 enable flip-flop(s) to a 2-tile implementation
	//   because the CLR/PRE pin on the enable flip-flop is not being driven
	//   by a global net.
	//
	//  * Synplify did not promote the net to global, so the code
	//    was modified to do it explicitly.
	//
	CLKINT u2 (
		.A (~ujtag_tlr_n),
		.Y ( ujtag_tlr  )
	);

	// DRCK CLKINT buffer
	// * Per Polarfire Macro Libraries Guide recommendation
	CLKINT u3 (
		.A (ujtag_drck_o),
		.Y (ujtag_drck  )
	);

	// ------------------------------------------------------------------------
	// JTAG-to-Register
	// ------------------------------------------------------------------------
	//
	jtag_to_register #(
		.WIDTH      (JTAG_WIDTH     ),
		.UPDATE_CLK (JTAG_UPDATE_CLK)
	) u4 (
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

endmodule

