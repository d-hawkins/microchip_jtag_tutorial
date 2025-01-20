// ----------------------------------------------------------------------------
// sf2_starter.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Emcraft Microchip SmartFusion2 Starter Kit 'jtag_to_register' design.
//
// ----------------------------------------------------------------------------

module sf2_starter (

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
		// I/O
		// --------------------------------------------------------------------
		//
		// LED
		output led
	);

	// ------------------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------------------
	//
	// JTAG-to-Register parameters
	localparam int JTAG_WIDTH      = 8;
	localparam int JTAG_UPDATE_CLK = 0; // Use DRCK during UPDATE

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
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
	// LEDs
	// ------------------------------------------------------------------------
	//
	assign led = control[0];

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
		.UIREG  (ujtag_ir    ),    // Tap IR value
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
	assign ujtag_tlr = ~ujtag_tlr_n;

	// DRCK CLKINT buffer
	// * Per Polarfire Macro Libraries Guide recommendation
	//   (the SmartFusion2 Macro Libraries Guide does not have this detail)
	CLKINT u2 (
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

endmodule

