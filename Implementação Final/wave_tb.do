onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TestBench
add wave -noupdate -divider Geral
add wave -noupdate /TestBench/CLOCK_50
add wave -noupdate /TestBench/CLOCK_25
add wave -noupdate /TestBench/SW
add wave -noupdate -divider Robo
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst8/reset
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst8/head
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst8/left
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst8/under
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst8/barrier
add wave -noupdate /TestBench/DUV/b2v_inst8/avancar
add wave -noupdate /TestBench/DUV/b2v_inst8/girar
add wave -noupdate /TestBench/DUV/b2v_inst8/recolher_entulho
add wave -noupdate /TestBench/DUV/b2v_inst8/EstadoAtual
add wave -noupdate /TestBench/DUV/b2v_inst8/EstadoFuturo
add wave -noupdate /TestBench/DUV/b2v_inst8/contador
add wave -noupdate /TestBench/DUV/b2v_inst8/flag_Stop
add wave -noupdate /TestBench/DUV/b2v_inst4/AtivaRobo
add wave -noupdate -divider Controlador
add wave -noupdate -radix hexadecimal -childformat {{{/TestBench/DUV/b2v_inst4/Mapa[0]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[1]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[2]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[3]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[4]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[5]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[6]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[7]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[8]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Mapa[9]} -radix hexadecimal}} -subitemconfig {{/TestBench/DUV/b2v_inst4/Mapa[0]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[1]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[2]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[3]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[4]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[5]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[6]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[7]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[8]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Mapa[9]} {-height 15 -radix hexadecimal}} /TestBench/DUV/b2v_inst4/Mapa
add wave -noupdate -radix hexadecimal -childformat {{{/TestBench/DUV/b2v_inst4/MapaTemp[0]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[1]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[2]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[3]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[4]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[5]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[6]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[7]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[8]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[9]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/MapaTemp[10]} -radix hexadecimal}} -subitemconfig {{/TestBench/DUV/b2v_inst4/MapaTemp[0]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[1]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[2]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[3]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[4]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[5]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[6]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[7]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[8]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[9]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/MapaTemp[10]} {-height 15 -radix hexadecimal}} /TestBench/DUV/b2v_inst4/MapaTemp
add wave -noupdate /TestBench/DUV/b2v_inst4/entulho_life
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ColunaCursor
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/LinhaCursor
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ColunaCelulaPreta
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/LinhaCelulaPreta
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ColunaRobo
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/LinhaRobo
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ColunaEntulhoLeve
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/LinhaEntulhoLeve
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ColunaEntulhoMedio
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/LinhaEntulhoMedio
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ColunaEntulhoPesado
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/LinhaEntulhoPesado
add wave -noupdate -radix binary -childformat {{{/TestBench/DUV/b2v_inst4/Orientacao_Robo[1]} -radix hexadecimal} {{/TestBench/DUV/b2v_inst4/Orientacao_Robo[0]} -radix hexadecimal}} -subitemconfig {{/TestBench/DUV/b2v_inst4/Orientacao_Robo[1]} {-height 15 -radix hexadecimal} {/TestBench/DUV/b2v_inst4/Orientacao_Robo[0]} {-height 15 -radix hexadecimal}} /TestBench/DUV/b2v_inst4/Orientacao_Robo
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ContadorFramesRobo
add wave -noupdate /TestBench/DUV/b2v_inst4/OrientacaoRobo
add wave -noupdate /TestBench/DUV/b2v_inst4/IteracaoRobo
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst4/Flag
add wave -noupdate /TestBench/DUV/b2v_inst4/LEDG
add wave -noupdate /TestBench/DUV/b2v_inst4/LEDR
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/ColunasSprites
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst4/LinhasSprites
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst4/v_sync
add wave -noupdate -divider Controle
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst7/Saidas
add wave -noupdate -radix binary /TestBench/DUV/b2v_inst7/Flag
add wave -noupdate -divider Grafico
add wave -noupdate -radix binary /TestBench/VGA_VS
add wave -noupdate -radix binary /TestBench/VGA_HS
add wave -noupdate /TestBench/VGA_B
add wave -noupdate /TestBench/VGA_G
add wave -noupdate /TestBench/VGA_R
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/ColunaCelulaPreta
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/LinhaCelulaPreta
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/ColunaLixo1
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/LinhaLixo1
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/ColunaLixo2
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/LinhaLixo2
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/ColunaLixo3
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/LinhaLixo3
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/ColunaRobo
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/LinhaRobo
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/ColunaCursor
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/LinhaCursor
add wave -noupdate -radix binary -childformat {{{/TestBench/DUV/b2v_inst/OrientacaoRobo[1]} -radix binary} {{/TestBench/DUV/b2v_inst/OrientacaoRobo[0]} -radix binary}} -subitemconfig {{/TestBench/DUV/b2v_inst/OrientacaoRobo[1]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/OrientacaoRobo[0]} {-height 15 -radix binary}} /TestBench/DUV/b2v_inst/OrientacaoRobo
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/Linha
add wave -noupdate -radix hexadecimal /TestBench/DUV/b2v_inst/Coluna
add wave -noupdate -radix binary -childformat {{{/TestBench/DUV/b2v_inst/FileiraMapa[1]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[2]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[3]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[4]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[5]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[6]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[7]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[8]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[9]} -radix binary} {{/TestBench/DUV/b2v_inst/FileiraMapa[10]} -radix binary}} -subitemconfig {{/TestBench/DUV/b2v_inst/FileiraMapa[1]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[2]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[3]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[4]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[5]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[6]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[7]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[8]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[9]} {-height 15 -radix binary} {/TestBench/DUV/b2v_inst/FileiraMapa[10]} {-height 15 -radix binary}} /TestBench/DUV/b2v_inst/FileiraMapa
add wave -noupdate -divider TOP
add wave -noupdate -radix hexadecimal /TestBench/DUV/SYNTHESIZED_WIRE_3
add wave -noupdate -radix hexadecimal /TestBench/DUV/SYNTHESIZED_WIRE_5
add wave -noupdate /TestBench/linha
add wave -noupdate /TestBench/coluna
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1720743725 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 218
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
WaveRestoreZoom {1720743559 ns} {1720743683 ns}
