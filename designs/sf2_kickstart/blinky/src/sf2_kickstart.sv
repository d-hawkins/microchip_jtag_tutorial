// ----------------------------------------------------------------------------
// sf2_kickstart.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Avnet Microchip SmartFusion2 Kickstart Kit 'blinky' design.
//
// ----------------------------------------------------------------------------

module sf2_kickstart (

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
	// MSBs 0_0000b to 0_1111b displays the count on the green LEDs
	assign led_g = (count[WIDTH-1] == 1'b0) ? '0 :
		count[(WIDTH-2) -: 4];
	//
	// MSBs 1_0000b to 1_1111b displays the count on the red LEDs
	assign led_r = (count[WIDTH-1] == 1'b1) ? '0 :
		count[(WIDTH-2) -: 4];

	// ------------------------------------------------------------------------
	// UART loopback
	// ------------------------------------------------------------------------
	//
	assign uart_txd = uart_rxd;

endmodule

