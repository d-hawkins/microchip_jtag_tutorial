// ----------------------------------------------------------------------------
// sf2_security.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip SmartFusion2 Security Evaluation Kit 'blinky' design.
//
// ----------------------------------------------------------------------------

module sf2_security (

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
		//  * [7:0] = {blue, blue, red, red, green green, amber, amber}
		//  * drive low to turn on
		output [7:0] led,

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
	// 8 LEDs driven by the 50MHz clock
	localparam integer WIDTH =
		$clog2(integer'(CLK_50MHZ_FREQUENCY*BLINK_PERIOD))+7;

	// ------------------------------------------------------------------------
	// Local signals
	// ------------------------------------------------------------------------
	//
	// Counter
	logic [WIDTH-1:0] count;
	//
	// LED outputs
	logic [7:0] led_out;

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
	always_ff @(posedge clk_50mhz) begin
		led_out <= ~count[(WIDTH-1) -: 8];
	end
	assign led = led_out;

	// ------------------------------------------------------------------------
	// UART loopback
	// ------------------------------------------------------------------------
	//
	assign uart_txd = uart_rxd;

endmodule

