// ----------------------------------------------------------------------------
// pfs_disco.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip PolarFire SoC Discovery Kit 'blinky' design.
//
// ----------------------------------------------------------------------------

module pfs_disco (

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
	// 7 LEDs driven by 50MHz
	localparam integer WIDTH =
		$clog2(integer'(CLK_50MHZ_FREQUENCY*BLINK_PERIOD)) + 6;

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Counter
	logic [WIDTH-1:0] count;

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
	assign led = count[WIDTH-1 -: 7];

	// ------------------------------------------------------------------------
	// UART loopback
	// ------------------------------------------------------------------------
	//
	assign uart_txd = uart_rxd;

endmodule

