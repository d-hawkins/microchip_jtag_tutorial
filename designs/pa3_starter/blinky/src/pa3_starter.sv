// ----------------------------------------------------------------------------
// pa3_starter.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip ProASIC3 Starter Kit  'blinky' design.
//
// ----------------------------------------------------------------------------

module pa3_starter (

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
	// 8 LEDs driven by the 40MHz clock
	localparam integer WIDTH =
		$clog2(integer'(CLK_40MHZ_FREQUENCY*BLINK_PERIOD))+7;

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
	always_ff @(posedge clk_40mhz) begin
		count <= count + 1;
	end

	// ------------------------------------------------------------------------
	// LED outputs
	// ------------------------------------------------------------------------
	//
	assign led = count[(WIDTH-1) -: 8];

endmodule

