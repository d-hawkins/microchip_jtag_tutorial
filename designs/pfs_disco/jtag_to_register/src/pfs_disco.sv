// ----------------------------------------------------------------------------
// pfs_disco.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip PolarFire SoC Discovery Kit 'jtag_to_register' design.
//
// ----------------------------------------------------------------------------
// JTAG Instruction Register Op-Codes
// ----------------------------------
//
// Libero SoC was used to export a BSDL for the Polarfire SoC.
//
// The IR op-codes from the BSDL were:
//
//   BYPASS       11111111
//   IDCODE       00001111
//   EXTEST       00000000
//   EXTEST2      00001001
//   PRELOAD      00000001
//   SAMPLE       00000001
//   HIGHZ        00000111
//   CLAMP        00000101
//   USERCODE     00001110
//   EXTEST_PULSE 00000110
//   EXTEST_TRAIN 00001010
//
// The user op-codes are from 16 to 127 (00010000 to 01111111).
//
// ----------------------------------------------------------------------------

module pfs_disco (

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
		// LEDs
		output [6:0] led,

		// UART
		input        uart_rxd,
		output       uart_txd,

		// RPi Debug (for logic analyzer probing of UTAG signals)
		output [7:0] rpi_debug
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
	// 1 LED driven by 50MHz
	localparam integer WIDTH =
		$clog2(integer'(CLK_50MHZ_FREQUENCY*BLINK_PERIOD));

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
	// LED drivers
	// * led[6]   = 1-bit counter (yellow blinking)
	// * led[5:4] = 00b (off)
	// * led[3:0] = 4-bit UJTAG control
	assign led = {count[WIDTH-1], 2'b00, control[3:0]};

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
		.gpo       (control   ),
		.gpi       (status    )
	);

	// Loopback
	assign status = control;

	// ------------------------------------------------------------------------
	// Raspberry Pi debug
	// ------------------------------------------------------------------------
	//
	// UTAG signals to outputs (for probing using external logic analyzer)
	//
	//   rpi_   RPi   UJTAG   Jumper
	//  debug   Pin   Signal  Color
	//  -----  ----  ------  ------
	//    7     11    DRCK    red
	//    6     13    TDI     grey
	//    5     15    TDO     brown
	//
	//    4     29    SEL     yellow
	//    3     31    TLR     purple
	//    2     33    CDR     blue
	//    1     35    SDR     orange
	//    0     37    UDR     green
	//          39    GND     black
	//
	// These 8-bits plus ground can be connected to a logic analyzer,
	// eg., the Arty board containing a Vivado ILA.
	//
	assign rpi_debug = {
		ujtag_drck,
		ujtag_tdi,
		ujtag_tdo,
		ujtag_sel,
		ujtag_tlr,
		ujtag_cdr,
		ujtag_sdr,
		ujtag_udr
	};

endmodule

