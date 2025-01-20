// ----------------------------------------------------------------------------
// ujtag_wrapper_pa3.sv
//
// 1/15/2025 D. W. Hawkins (dwh@caltech.edu)
//
// Microchip UJTAG for ProASIC3.
//
// The ProASIC3 UJTAG component has individual ports for the UIREG[] bus.
// This wrapper component is used to make the ProASIC3 component have the
// same top-level pinout as the SmartFusion2 and newer components.
//
// The ProASIC3 UJTAG and the SmartFusion2 UJTAG cannot be included in a
// testbench using an if-generate statement as Questasim recognizes that
// the component name is the same, but the port list is different. The
// work-around for this, is to use a different component name in the
// testbench, i.e., ujtag_wrapper, along with a ProASIC3 implementation
// of that wrapper and the SmartFusion2 version of that wrappper. The
// Questasim simulation script then compiles the appropriate wrapper.
//
// ----------------------------------------------------------------------------

module ujtag_wrapper (

		// JTAG
		input   TRSTB,
		input   TMS,
		input   TDI,
		input   TCK,
		output  TDO,

		// User JTAG
		output  [7:0] UIREG,
		output  URSTB,
		output  UDRCAP,
		output  UDRSH,
		output  UDRUPD,
		output  UDRCK,
		output  UTDI,
		input   UTDO

	);

	UJTAG u1 (
		// JTAG
		.TRSTB  (TRSTB   ),
		.TCK    (TCK     ),
		.TMS    (TMS     ),
		.TDI    (TDI     ),
		.TDO    (TDO     ),

		// User JTAG
		.UIREG0 (UIREG[0]),
		.UIREG1 (UIREG[1]),
		.UIREG2 (UIREG[2]),
		.UIREG3 (UIREG[3]),
		.UIREG4 (UIREG[4]),
		.UIREG5 (UIREG[5]),
		.UIREG6 (UIREG[6]),
		.UIREG7 (UIREG[7]),
		.URSTB  (URSTB   ),
		.UDRCAP (UDRCAP  ),
		.UDRSH  (UDRSH   ),
		.UDRUPD (UDRUPD  ),
		.UDRCK  (UDRCK   ),
		.UTDI   (UTDI    ),
		.UTDO   (UTDO    )
	);

endmodule
