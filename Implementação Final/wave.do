onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TestBench
add wave -noupdate /TestBenchVGA/CLOCK_50
add wave -noupdate /TestBenchVGA/CLOCK_25
add wave -noupdate /TestBenchVGA/SW
add wave -noupdate /TestBenchVGA/VGA_B
add wave -noupdate /TestBenchVGA/VGA_G
add wave -noupdate /TestBenchVGA/VGA_R
add wave -noupdate /TestBenchVGA/VGA_VS
add wave -noupdate /TestBenchVGA/VGA_HS
add wave -noupdate /TestBenchVGA/ColunasSprites
add wave -noupdate /TestBenchVGA/LinhasSprites
add wave -noupdate /TestBenchVGA/linha
add wave -noupdate /TestBenchVGA/coluna
add wave -noupdate -divider Gráfico
add wave -noupdate /TestBenchVGA/b2v_inst/RGB
add wave -noupdate /TestBenchVGA/b2v_inst/VetorPixels
add wave -noupdate /TestBenchVGA/b2v_inst/EstadoAtual
add wave -noupdate /TestBenchVGA/b2v_inst/EstadoFuturo
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/ColunaCelulaPreta
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/ColunaLixo1
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/ColunaLixo2
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/ColunaLixo3
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/ColunaRobo
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/ColunaCursor
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/LinhaCelulaPreta
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/LinhaLixo1
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/LinhaLixo2
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/LinhaLixo3
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/LinhaRobo
add wave -noupdate -radix hexadecimal /TestBenchVGA/b2v_inst/LinhaCursor
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4999846 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {16376243 ns} {16376438 ns}
