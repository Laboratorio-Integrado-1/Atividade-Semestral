module Graphic(clock, mapa)
input clock
input mapa [3:0] Mapa [0:10][0:19];

 // Configuração do mapa 
 // 0: Caminho Livre -	Célula onde o robô pode se mover livremente.
 // 1: Parede - Obstáculo que impede o movimento do robô.
 // 2: Célula Preta - Célula que indica o inicio ou final de uma tubulação.
 // 3: Entulho Leve - Entulho que requer 3 ciclos para ser removido.
 // 4: Entulho Médio - Entulho que requer 6 ciclos para ser removido.
 // 5: Entulho Pesado - Entulho que requer 9 ciclos para ser removido.
endmodule
