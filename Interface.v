module teste (clk, rst, v_sync, h_sync, blank, xr, yr, dr, R, G, B, enable);

// mapa 11x20, sendo primeira linha referente a orientação do robo,
// o mapa em si tem dimensão 10x20

// tradução do mapa
// 0: caminho livre     (branco)
// 1: parede            (cinza)
// 2: célula preta      (preto)
// 3: entulho leve      (amarelo)
// 4: entulho médio     (laranja)
// 5: entulho pesado    (vermelho)
// R: robo              (verde)

// orientação robo (dr)
// 0: Norte
// 1: Oeste
// 2: Sul
// 3: Leste

// tamanho pixel: 640/10 x 480/20
//                64 x 24

input clk, rst;
input [3:0] xr, yr, dr;
output v_sync, h_sync, blank;
output [7:0] R;
output [7:0] G;
output [7:0] B;
output reg enable;

reg [9:0] linha, coluna;
reg [7:0] red_o, green_o, blue_o;

reg [3:0] x, y;
reg [23:0] RGB;

reg flag = 0;
reg [79:0] temp [0:10]; // Array temporario para armazenar linhas lidas
reg map[0:9][0:19];
integer i, j;

parameter	COR_CINZA = 24'h808080, 
				COR_AZUL = 24'h0000FF,
				COR_BRANCO = 24'hFFFFFF,
				COR_AMARELO = 24'hFFFF00,
				COR_LARANJA = 24'hFFA500,
				COR_PRETO = 24'h000000,
				COR_VERDE = 24'h00FF00,
				COR_VERMELHO = 24'hFF0000,

				X_INIT = 140,
				Y_INIT = 778,
				X_END = 35,
				Y_END = 515;

always @ (posedge clk)
begin
	if(flag)
	begin
		 $readmemh("Mapa.txt", temp);
		 // Preencher a matriz com os valores restantes
		 for (i = 0; i < 10; i = i + 1) begin
			for (j = 0; j < 20; j = j + 1) begin
			  map[i][j] = temp[i+1][79 - j*4 -: 4]; // Preencher a matriz ignorando a primeira linha
			end
		 end

	end

	if (!rst)
	begin
		linha <= 0;
		coluna <= 0;
		enable <= 0;
	end
	else
	begin
		enable <= ((coluna > X_INIT) && (coluna < X_END) && (linha > Y_INIT) && (linha < Y_END))?1:0;
		coluna <= coluna + 1;
		if (coluna == 794)
		begin
			coluna <= 0;
			linha <= linha + 1;
			if (linha == 525)
			begin
				linha <= 0;
			end
		end
	end

	if(enable)
	begin
		// x - x_init / 64 < 1 -> col 1
		// 		  		   < 2 -> col 2
		// ...
		// y - y_init / 24 < 1 -> row 1
		// 		  		   < 2 -> row 2
		// ...
		
		// TODO: Corrigir para considerar área não visível
		// para corrigir a área não visível basta subtrair x_init e y_init
		x <= (coluna - X_INIT) / 64;
		y <= (linha - Y_INIT) / 24;

		x <= x + 1;

		// pega valor referente em (x,y)
		// atribui a cor correspondente
		
		//TODO: indicar frente do robo
		
		// robo              	(verde)
		if (x==xr && y==yr)
		begin
			RGB = COR_VERDE;
		end
		
		// 0: caminho livre     (branco)
		else if(map[x][y] == 0)
		begin
			RGB = COR_BRANCO;
		end
		// 1: parede            (cinza)
		else if (map[x][y] == 1)
		begin
			RGB = COR_CINZA;
		end
		// 2: célula preta      (preto)
		else if (map[x][y] == 2)
		begin
			RGB = COR_PRETO;
		end
		// 3: entulho leve      (amarelo)
		else if (map[x][y] == 3)
		begin
			RGB = COR_AMARELO;
		end
		// 4: entulho médio     (laranja)
		else if (map[x][y] == 4)
		begin
			RGB = COR_LARANJA;
		end
		// 5: entulho pesado    (vermelho)
		else if (map[x][y] == 5)
		begin
			RGB = COR_VERMELHO;
		end


	end
end

assign blank = ((coluna < X_INIT) || (coluna > X_END) || (linha < X_INIT) || (linha > X_END))?0:1;
assign h_sync = (coluna < 95)? 0 : 1;
assign v_sync = (linha < 2)? 0 : 1;
assign R = RGB[23:16];
assign G = RGB[15:8];
assign B = RGB[7:0];

endmodule 
