onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Robo_TB/clock
add wave -noupdate /Robo_TB/reset
add wave -noupdate -radix binary /Robo_TB/avancar
add wave -noupdate -radix binary /Robo_TB/girar
add wave -noupdate -radix binary /Robo_TB/remover
add wave -noupdate /Robo_TB/String_Orientacao_Robo
add wave -noupdate /Robo_TB/entulho_life
add wave -noupdate -divider Posição
add wave -noupdate -radix decimal /Robo_TB/Coluna_Robo
add wave -noupdate -radix decimal /Robo_TB/Linha_Robo
add wave -noupdate -radix decimal /Robo_TB/Celula_Mapa
add wave -noupdate -divider Controle
add wave -noupdate /Robo_TB/step_mode
add wave -noupdate /Robo_TB/btn_step
add wave -noupdate /Robo_TB/btn_mode
add wave -noupdate /Robo_TB/btn_reset
add wave -noupdate -divider Sensores
add wave -noupdate /Robo_TB/head
add wave -noupdate /Robo_TB/left
add wave -noupdate /Robo_TB/under
add wave -noupdate /Robo_TB/barrier
add wave -noupdate -divider Estados
add wave -noupdate -radix binary -childformat {{{/Robo_TB/DUV/EstadoAtual[2]} -radix binary} {{/Robo_TB/DUV/EstadoAtual[1]} -radix binary} {{/Robo_TB/DUV/EstadoAtual[0]} -radix binary}} -subitemconfig {{/Robo_TB/DUV/EstadoAtual[2]} {-height 15 -radix binary} {/Robo_TB/DUV/EstadoAtual[1]} {-height 15 -radix binary} {/Robo_TB/DUV/EstadoAtual[0]} {-height 15 -radix binary}} /Robo_TB/DUV/EstadoAtual
add wave -noupdate -radix binary -childformat {{{/Robo_TB/DUV/EstadoFuturo[2]} -radix binary} {{/Robo_TB/DUV/EstadoFuturo[1]} -radix binary} {{/Robo_TB/DUV/EstadoFuturo[0]} -radix binary}} -subitemconfig {{/Robo_TB/DUV/EstadoFuturo[2]} {-height 15 -radix binary} {/Robo_TB/DUV/EstadoFuturo[1]} {-height 15 -radix binary} {/Robo_TB/DUV/EstadoFuturo[0]} {-height 15 -radix binary}} /Robo_TB/DUV/EstadoFuturo
add wave -noupdate /Robo_TB/Situacoes_Anomalas/Situacoes_Anomalas
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
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
WaveRestoreZoom {0 ns} {250 ns}
