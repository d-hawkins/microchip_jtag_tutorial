// ----------------------------------------------------------------------------
// jtag_to_register.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// JTAG to register component.
//
// This component can be used with Xilinx BSCAN and MicroSemi UJTAG.
//
// This component interfaces with the BSCAN or UJTAG component to implement:
//
//   * Serial-to-parallel conversion of host-to-FPGA (write) data
//   * Parallel-to-serial conversion of FPGA-to-host (read)  data
//
// ----------------------------------------------------------------------------
// Notes
// -----
//
// 1. Synplify pruning of UJTAG logic
//
//    Synplify may prune (delete) the UJTAG and jtag_to_register components
//    in designs that instantiate these components without also making
//    connections to I/O pins on the FPGA.
//
//    For example, a valid design is to connect the gpi and gpo ports on the
//    jtag_to_register component together to implement a JTAG data loopback.
//
// ----------------------------------------------------------------------------

module jtag_to_register #(
		// Parallel register bit-width
		parameter int WIDTH      = 32,

		// Use Update-DR as a clock
		// * Xilinx BSCAN requires UPDATE_CLK = 1
		parameter int UPDATE_CLK = 0
	) (
		// --------------------------------------------------------------------
		// JTAG
		// --------------------------------------------------------------------
		//
		// JTAG serial interface
		input              jtag_sel,   // IR loaded with a user instruction
		input              jtag_drck,  // Gated TCK
		input              jtag_tdi,
		output             jtag_tdo,

		// JTAG TAP states
		input              jtag_tlr,
		input              jtag_cdr,
		input              jtag_sdr,
		input              jtag_udr,

		// --------------------------------------------------------------------
		// General Purpose Output/Input
		// --------------------------------------------------------------------
		//
		output [WIDTH-1:0] control,
		input  [WIDTH-1:0] status
	);

	// ------------------------------------------------------------------------
	// Internal Signals
	// ------------------------------------------------------------------------
	//
	// Shift register
	logic [WIDTH-1:0] serial;
	//
	// Parallel register
	logic [WIDTH-1:0] parallel;

	// ------------------------------------------------------------------------
	// JTAG serial shift register
	// ------------------------------------------------------------------------
	//
	always_ff @(posedge jtag_tlr, posedge jtag_drck) begin
		if (jtag_tlr) begin
			serial <= '0;
		end
		else begin
			if (jtag_sel) begin
				if (jtag_cdr) begin
					serial <= status;
				end
				else if (jtag_sdr) begin
					// LSB-to-MSB shift register
					serial <= {jtag_tdi, serial[WIDTH-1:1]};
				end
			end
		end
	end

	// LSB-to-MSB shift data out
	// * UTDO data must be driven on the DRCK rising-edge as the UTDO-to-TDO
	//   path contains a TCK falling-edge register (on BSCAN and UJTAG)
	assign jtag_tdo = serial[0];

/*
	// Output on falling-edge of DRCK
	// * This logic was used to generate documentation logic analyzer traces
	logic jtag_tdo_out;
	always_ff @(negedge jtag_drck) begin
		jtag_tdo_out <= serial[0];
	end
	assign jtag_tdo = jtag_tdo_out;
*/

	// ------------------------------------------------------------------------
	// Parallel register
	// ------------------------------------------------------------------------
	//
	// The Xilinx BSCAN component DRCK is gated and does not toggle during
	// the Update-DR state, so Update-DR needs to be used as a clock.
	//
	if (UPDATE_CLK == 0) begin: g0

		// This register uses DRCK as a clock and Update-DR as a condition
		always_ff @(posedge jtag_tlr, posedge jtag_drck) begin
			if (jtag_tlr) begin
				parallel <= '0;
			end
			else begin
				if (jtag_sel) begin
					if (jtag_udr) begin
						parallel <= serial;
					end
				end
			end
		end
	end
	else begin: g1

		// This register uses Update-DR as a clock
		always_ff @(posedge jtag_tlr, posedge jtag_udr) begin
			if (jtag_tlr) begin
				parallel <= '0;
			end
			else begin
				if (jtag_sel) begin
					parallel <= serial;
				end
			end
		end
	end

	// Output
	assign control = parallel;

endmodule

