// ----------------------------------------------------------------------------
// sf2_kickstart.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Avnet Microchip SmartFusion2 Kickstart Kit 'jtag_to_register' design.
//
// ----------------------------------------------------------------------------

module sf2_kickstart (

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
		input        clk_50mhz,

		// --------------------------------------------------------------------
		// User I/O
		// --------------------------------------------------------------------
		//
		// Bi-color LEDs
		output [3:0] led_g,
		output [3:0] led_r,

		// UART
		input        uart_rxd,
		output       uart_txd
	);

	// ------------------------------------------------------------------------
	// Local parameters
	// ------------------------------------------------------------------------
	//
	// Clock frequency
	localparam real CLK_50MHZ_FREQUENCY = 50.0e6;

	// LED blink rate
	localparam real BLINK_PERIOD = 0.5;

	// Counter width
	//
	// Note: the integer'() casts are important, without them Vivado
	// generates incorrect counter widths (much wider than expected)
	//
	// 4 LEDs driven by the 50MHz clock
	localparam integer WIDTH =
		$clog2(integer'(CLK_50MHZ_FREQUENCY*BLINK_PERIOD))+3+1;

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
	always_ff @(posedge clk_50mhz) begin
		count <= count + 1;
	end

	// ------------------------------------------------------------------------
	// LED outputs
	// ------------------------------------------------------------------------
	//
/*
	// MSBs 0_0000b to 0_1111b displays the count on the green LEDs
	assign led_g = (count[WIDTH-1] == 1'b0) ? '0 :
		count[(WIDTH-2) -: 4];
	//
	// MSBs 1_0000b to 1_1111b displays the count on the red LEDs
	assign led_r = (count[WIDTH-1] == 1'b1) ? '0 :
		count[(WIDTH-2) -: 4];
*/
	// MSBs 0_0000b to 0_1111b displays the count on the green LEDs
	assign led_g = (count[WIDTH-1] == 1'b0) ? '0 :
		{count[(WIDTH-4)], control[2:0]};
	//
	// MSBs 1_0000b to 1_1111b displays the count on the red LEDs
	assign led_r = (count[WIDTH-1] == 1'b1) ? '0 :
		{count[(WIDTH-4)], control[2:0]};

	// ------------------------------------------------------------------------
	// UART loopback
	// ------------------------------------------------------------------------
	//
	assign uart_txd = uart_rxd;

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

