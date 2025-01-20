onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {JTAG Interface}
add wave -noupdate /ujtag_tb/trst_n
add wave -noupdate /ujtag_tb/tck
add wave -noupdate -color Yellow /ujtag_tb/tap/state
add wave -noupdate /ujtag_tb/dut/u1/STATE
add wave -noupdate /ujtag_tb/tms
add wave -noupdate /ujtag_tb/tdi
add wave -noupdate /ujtag_tb/tdo
add wave -noupdate -divider {User JTAG Interface}
add wave -noupdate /ujtag_tb/ujtag_tlr_n
add wave -noupdate /ujtag_tb/ujtag_ir
add wave -noupdate /ujtag_tb/ujtag_cdr
add wave -noupdate /ujtag_tb/ujtag_sdr
add wave -noupdate /ujtag_tb/ujtag_udr
add wave -noupdate /ujtag_tb/ujtag_drck
add wave -noupdate /ujtag_tb/ujtag_tdi
add wave -noupdate -color Cyan /ujtag_tb/ujtag_tdo
add wave -noupdate -divider {User Logic}
add wave -noupdate /ujtag_tb/serial
add wave -noupdate /ujtag_tb/control
add wave -noupdate /ujtag_tb/status
add wave -noupdate -divider {Testbench Parameters}
add wave -noupdate /ujtag_tb/irval
add wave -noupdate /ujtag_tb/tdival
add wave -noupdate /ujtag_tb/tdoval
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19398042 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {22470 ns}
