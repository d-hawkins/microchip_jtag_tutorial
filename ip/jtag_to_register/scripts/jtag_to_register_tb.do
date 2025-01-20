onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {JTAG Interface}
add wave -noupdate /jtag_to_register_tb/trst_n
add wave -noupdate /jtag_to_register_tb/tck
add wave -noupdate /jtag_to_register_tb/tms
add wave -noupdate /jtag_to_register_tb/tdi
add wave -noupdate /jtag_to_register_tb/tdo
add wave -noupdate -color Yellow /jtag_to_register_tb/u1/state
add wave -noupdate -divider {User JTAG Interface}
add wave -noupdate /jtag_to_register_tb/ujtag_ir
add wave -noupdate /jtag_to_register_tb/ujtag_sel
add wave -noupdate /jtag_to_register_tb/ujtag_tlr_n
add wave -noupdate /jtag_to_register_tb/ujtag_tlr
add wave -noupdate /jtag_to_register_tb/ujtag_cdr
add wave -noupdate /jtag_to_register_tb/ujtag_sdr
add wave -noupdate /jtag_to_register_tb/ujtag_udr
add wave -noupdate /jtag_to_register_tb/ujtag_drck
add wave -noupdate /jtag_to_register_tb/ujtag_tdi
add wave -noupdate -color Cyan /jtag_to_register_tb/ujtag_tdo
add wave -noupdate -divider {User Logic}
add wave -noupdate /jtag_to_register_tb/control
add wave -noupdate /jtag_to_register_tb/status
add wave -noupdate -divider {Testbench Parameters}
add wave -noupdate /jtag_to_register_tb/irval
add wave -noupdate /jtag_to_register_tb/tdival
add wave -noupdate /jtag_to_register_tb/tdoval
add wave -noupdate /jtag_to_register_tb/expval
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 256
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
WaveRestoreZoom {0 ps} {21001554 ps}
