module Grafico (Clock50, Clock25, Reset, ColunasSprites, LinhasSprites, Coluna, Linha, RGB, OrientacaoRobo);

input Clock50, Clock25, Reset;
input [29:0] ColunasSprites;
input [9:0] Linha, Coluna;
input [23:0] LinhasSprites;
input [1:0] OrientacaoRobo;
output reg [23:0] RGB;

// Estados
parameter 	IDLE = 0,
				LER_FILEIRA_MAPA = 1,
				AGUARDAR_COLUNA = 2,
				LER_FUNDO = 3,
				LER_CELULA_PRETA = 4,
				MERGE_CELULA_PRETA = 5,
				LER_LIXO_1 = 6,
				MERGE_LIXO_1 = 7,
				LER_LIXO_2 = 8,
				MERGE_LIXO_2 = 9,
				LER_LIXO_3 = 10,
				MERGE_LIXO_3 = 11,
				LER_ROBO = 12,
				MERGE_ROBO = 13,
				LER_CURSOR = 14,
				MERGE_CURSOR = 15,
				FILEIRA_FINAL_LADO_ESQUERDO = 16,
				FILEIRA_FINAL_LADO_DIREITO = 17;
				
parameter 	LINHA_MAPA_1 = 235,
				LINHA_MAPA_2 = 251,
				LINHA_MAPA_3 = 267,
				LINHA_MAPA_4 = 283,
				LINHA_MAPA_5 = 299,
				LINHA_MAPA_6 = 315,
				LINHA_MAPA_7 = 331,
				LINHA_MAPA_8 = 347,
				LINHA_MAPA_9 = 363,
				LINHA_MAPA_10 = 379,
 				LINHA_INFERIOR = 395,
				COLUNA_MAPA_1 = 316,
				COLUNA_MAPA_2 = 332,
				COLUNA_MAPA_3 = 348,
				COLUNA_MAPA_4 = 364,
				COLUNA_MAPA_5 = 380,
				COLUNA_MAPA_6 = 396,
				COLUNA_MAPA_7 = 412,
				COLUNA_MAPA_8 = 428,
				COLUNA_MAPA_9 = 444,
				COLUNA_MAPA_10 = 460,
				COLUNA_MAPA_11 = 476,
				COLUNA_MAPA_12 = 492,
				COLUNA_MAPA_13 = 508,
				COLUNA_MAPA_14 = 524,
				COLUNA_MAPA_15 = 540,
				COLUNA_MAPA_16 = 556,
				COLUNA_MAPA_17 = 572,
				COLUNA_MAPA_18 = 588,
				COLUNA_MAPA_19 = 604,
				COLUNA_MAPA_20 = 620,
//				COLUNA_DIREITA = 636;
				COLUNA_DIREITA = 651;
				
parameter	CODIGO_TRANSPARENTE = 3'b000,
				CODIGO_AZUL = 3'b001,						
				CODIGO_BRANCO = 3'b010, 
				CODIGO_CIANO = 3'b011,
				CODIGO_LARANJA = 3'b100,
				CODIGO_PRETO = 3'b101,
				CODIGO_VERDE = 3'b110,
				CODIGO_VERMELHO = 3'b111;	
	
parameter	COR_TRANSPARENTE = 24'h000000, 
				COR_AZUL = 24'h0000FF,						
				COR_BRANCO = 24'hFFFFFF,
				COR_CIANO = 24'h00FFFF,
				COR_LARANJA = 24'hFFA500,
				COR_PRETO = 24'h000000,
				COR_VERDE = 24'h00FF00,
				COR_VERMELHO = 24'hFF0000;	

parameter N = 2'b00, S = 2'b01, L = 2'b10, O = 2'b11;

reg [4:0] EstadoAtual, EstadoFuturo;
reg [2:0] VetorPixels [0:31];
reg ZonaAtiva;

reg [4:0] IndicePixel, ColunaMapa, LinhaMapa, DeslocamentoLinha;

// Background
wire [1:60] FileiraMapa [1:10]; 
reg [1:60] FileiraMapaTemp;

assign FileiraMapa[1] = 60'b101_101_101_101_101_101_101_101_101_101_101_101_101_101_101_101_101_101_101_101;
assign FileiraMapa[2] = 60'b101_110_110_110_101_110_110_110_110_110_110_110_110_110_110_110_101_101_101_101;
assign FileiraMapa[3] = 60'b101_110_101_110_101_110_101_110_101_101_101_101_101_101_101_110_101_101_101_101;
assign FileiraMapa[4] = 60'b101_110_101_110_101_110_101_110_110_110_110_110_110_110_110_110_110_110_110_101;
assign FileiraMapa[5] = 60'b101_110_101_110_101_110_101_110_101_101_101_101_101_101_101_110_101_101_101_101;
assign FileiraMapa[6] = 60'b101_110_101_110_110_110_101_110_101_101_101_101_101_101_101_110_101_101_101_101;
assign FileiraMapa[7] = 60'b101_110_101_110_101_101_101_110_101_101_101_101_101_101_101_110_101_101_101_101;
assign FileiraMapa[8] = 60'b101_110_101_110_101_101_101_110_101_101_101_101_101_101_101_110_101_101_101_101;
assign FileiraMapa[9] = 60'b101_110_101_110_101_101_101_110_101_101_101_101_101_101_101_110_101_101_101_101;
assign FileiraMapa[10] = 60'b101_110_110_110_110_110_110_110_110_110_110_110_110_110_110_110_101_101_101_101;


// Fusao Final
reg [47:0] FileiraPixelsFinal;
reg [47:0] FileiraPixelsTemp;


// Posicao de Sprites
wire [4:0] ColunaCelulaPreta;
wire [4:0] ColunaLixo1;
wire [4:0] ColunaLixo2;
wire [4:0] ColunaLixo3;
wire [4:0] ColunaRobo;
wire [4:0] ColunaCursor;

wire [3:0] LinhaCelulaPreta;
wire [3:0] LinhaLixo1;
wire [3:0] LinhaLixo2;
wire [3:0] LinhaLixo3;
wire [3:0] LinhaRobo;
wire [3:0] LinhaCursor;

assign ColunaCelulaPreta = ColunasSprites[29:25];
assign ColunaLixo1 = ColunasSprites[24:20];
assign ColunaLixo2 = ColunasSprites[19:15];
assign ColunaLixo3 = ColunasSprites[14:10];
assign ColunaRobo = ColunasSprites[9:5];
assign ColunaCursor = ColunasSprites[4:0];

assign LinhaCelulaPreta = LinhasSprites[23:20];
assign LinhaLixo1 = LinhasSprites[19:16];
assign LinhaLixo2 = LinhasSprites[15:12];
assign LinhaLixo3 = LinhasSprites[11:8];
assign LinhaRobo = LinhasSprites[7:4];
assign LinhaCursor = LinhasSprites[3:0];

// Sprites
// Sprite 000 = Robo
// Sprite 001 = Cursor
// Sprite 010 = Lixo 1
// Sprite 011 = Lixo 2
// Sprite 100 = Lixo 3
// Sprite 101 = Sem Cano
// Sprite 110 = Com Cano
// Sprite 111 = Celula Preta

wire [47:0] Sprites [0:127];

assign Sprites[0] = 48'b000000111111111111111111111111111111111111000000;
assign Sprites[1] = 48'b000000111100100100100100100100100100100111000000;
assign Sprites[2] = 48'b000000111100101101100100100100101101100111000000;
assign Sprites[3] = 48'b000000111100100100100100100100100100100111000000;
assign Sprites[4] = 48'b000000111100001001100001001100001001100111000000;
assign Sprites[5] = 48'b000111111111111111111111111111111111111111111000;
assign Sprites[6] = 48'b111110110110110110110110110110110110110110110111;
assign Sprites[7] = 48'b111110100100100101101100100101101100100100110111;
assign Sprites[8] = 48'b111111111111111101100100100100101111111111111111;
assign Sprites[9] = 48'b111111111111111101100100100100101111111111111111;
assign Sprites[10] = 48'b111110100100100101101100100101101100100100110111;
assign Sprites[11] = 48'b111110100100100100100100100100100100100100110111;
assign Sprites[12] = 48'b111110110110110110110110110110110110110110110111;
assign Sprites[13] = 48'b000111111111111111111111111111111111111111111000;
assign Sprites[14] = 48'b000000111110110110111000000111110110110111000000;
assign Sprites[15] = 48'b000000111111111111111000000111111111111111000000;

assign Sprites[16] = 48'b111111111111111111111111111111111111111111111111;
assign Sprites[17] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[18] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[19] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[20] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[21] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[22] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[23] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[24] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[25] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[26] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[27] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[28] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[29] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[30] = 48'b111000000000000000000000000000000000000000000111;
assign Sprites[31] = 48'b111111111111111111111111111111111111111111111111;

assign Sprites[32] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[33] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[34] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[35] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[36] = 48'b000000000000000000000111111111001000000000000000;
assign Sprites[37] = 48'b000000000000000001101101101101001101000000000000;
assign Sprites[38] = 48'b000000000000101101101001101101101101101000000000;
assign Sprites[39] = 48'b000000000000000101101101101101101101001000000000;
assign Sprites[40] = 48'b000000000000000000001101101001101101101000000000;
assign Sprites[41] = 48'b000000000000000000110111111101101110000000000000;
assign Sprites[42] = 48'b000000000000000000000101111111000000000000000000;
assign Sprites[43] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[44] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[45] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[46] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[47] = 48'b000000000000000000000000000000000000000000000000;

assign Sprites[48] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[49] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[50] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[51] = 48'b000000000000000000000001001001001000000000000000;
assign Sprites[52] = 48'b000000000000000000001111111111001001000000000000;
assign Sprites[53] = 48'b000000000000000001101101101101001101000000000000;
assign Sprites[54] = 48'b000000000000101101101001101101101101101000000000;
assign Sprites[55] = 48'b000000000000001101101101101101101101001000000000;
assign Sprites[56] = 48'b000000000000000001001101101001101101101000000000;
assign Sprites[57] = 48'b000000000000000001110111111101101110001000000000;
assign Sprites[58] = 48'b000000000000000000001101111111001001000000000000;
assign Sprites[59] = 48'b000000000000000000000000001001001000000000000000;
assign Sprites[60] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[61] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[62] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[63] = 48'b000000000000000000000000000000000000000000000000;

assign Sprites[64] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[65] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[66] = 48'b000000000000000000111001001111000000000000000000;
assign Sprites[67] = 48'b000000000000000111001001001001001001111000000000;
assign Sprites[68] = 48'b000000000000000001001111111111001001001111000000;
assign Sprites[69] = 48'b000000000000111001101101101101001101001111000000;
assign Sprites[70] = 48'b000000000111101101101001101101101101101111000000;
assign Sprites[71] = 48'b000000000111001101101101101101101101111111000000;
assign Sprites[72] = 48'b000000000111001001001101101001101101101000000000;
assign Sprites[73] = 48'b000000000000111001110111111101101110001111000000;
assign Sprites[74] = 48'b000000000000000001001101111111001001111000000000;
assign Sprites[75] = 48'b000000000000000111001001001001001111000000000000;
assign Sprites[76] = 48'b000000000000000000111001001001000000000000000000;
assign Sprites[77] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[78] = 48'b000000000000000000000000000000000000000000000000;
assign Sprites[79] = 48'b000000000000000000000000000000000000000000000000;

assign Sprites[80] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[81] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[82] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[83] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[84] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[85] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[86] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[87] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[88] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[89] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[90] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[91] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[92] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[93] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[94] = 48'b101010010010010010010010010010010010010010010101;
assign Sprites[95] = 48'b101101101101101101101101101101101101101101101101;

assign Sprites[96] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[97] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[98] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[99] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[100] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[101] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[102] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[103] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[104] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[105] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[106] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[107] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[108] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[109] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[110] = 48'b101011011011011011011011011011011011011011011101;
assign Sprites[111] = 48'b101101101101101101101101101101101101101101101101;

assign Sprites[112] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[113] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[114] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[115] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[116] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[117] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[118] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[119] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[120] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[121] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[122] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[123] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[124] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[125] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[126] = 48'b101101101101101101101101101101101101101101101101;
assign Sprites[127] = 48'b101101101101101101101101101101101101101101101101;


always @ (*)
begin
	if (Linha < LINHA_MAPA_1 || Linha > LINHA_INFERIOR || Coluna < (COLUNA_MAPA_1 + 16) || Coluna > COLUNA_DIREITA)
	begin
		ZonaAtiva = 0;
		RGB = COR_PRETO;		
	end
	else
	begin
		ZonaAtiva = 1;
		case (VetorPixels[IndicePixel])			
			CODIGO_AZUL:			RGB = COR_AZUL;
			CODIGO_BRANCO: 			RGB = COR_BRANCO;
			CODIGO_CIANO: 			RGB = COR_CIANO;
			CODIGO_LARANJA: 		RGB = COR_LARANJA;
			CODIGO_PRETO:			RGB = COR_PRETO;
			CODIGO_VERDE: 			RGB = COR_VERDE;
			CODIGO_VERMELHO: 		RGB = COR_VERMELHO;			
			default: 				RGB = COR_PRETO; 
		endcase		
	end
end

always @ (posedge Clock50)
begin
	if (Reset)
	begin
		EstadoAtual <= IDLE;
		DeslocamentoLinha <= 0;
		FileiraMapaTemp <= FileiraMapa[1];
	end
	else
	begin
		EstadoAtual <= EstadoFuturo;
	end	
	
	if (EstadoFuturo == IDLE)
	begin
		DeslocamentoLinha <= 0;
		FileiraMapaTemp <= FileiraMapa[1];
	end
		
	if (EstadoFuturo == LER_FILEIRA_MAPA)
	begin
		if (DeslocamentoLinha == 15)
		begin
			DeslocamentoLinha <= 0;
		end
		else
		begin
			DeslocamentoLinha <= DeslocamentoLinha + 1;
		end
		case (Linha)
				LINHA_MAPA_1 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[1];					
				end
				LINHA_MAPA_2 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[2];
				end
				LINHA_MAPA_3 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[3];
				end
				LINHA_MAPA_4 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[4];
				end
				LINHA_MAPA_5 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[5];
				end
				LINHA_MAPA_6 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[6];
				end
				LINHA_MAPA_7 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[7];
				end
				LINHA_MAPA_8 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[8];
				end
				LINHA_MAPA_9 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[9];
				end
				LINHA_MAPA_10 - 1: 
				begin
					FileiraMapaTemp <= FileiraMapa[10];
				end
		endcase
	end
	
	if (EstadoFuturo == LER_FUNDO)
	begin
		case (ColunaMapa)
			1: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[1:3] * 16 + DeslocamentoLinha];
			2: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[4:6] * 16 + DeslocamentoLinha];
			3: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[7:9] * 16 + DeslocamentoLinha];
			4: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[10:12] * 16 + DeslocamentoLinha];
			5: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[13:15] * 16 + DeslocamentoLinha];
			6: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[16:18] * 16 + DeslocamentoLinha];
			7: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[19:21] * 16 + DeslocamentoLinha];
			8: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[22:24] * 16 + DeslocamentoLinha];
			9: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[25:27] * 16 + DeslocamentoLinha];
			10: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[28:30] * 16 + DeslocamentoLinha];
			11: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[31:33] * 16 + DeslocamentoLinha];
			12: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[34:36] * 16 + DeslocamentoLinha];
			13: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[37:39] * 16 + DeslocamentoLinha];
			14: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[40:42] * 16 + DeslocamentoLinha];
			15: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[43:45] * 16 + DeslocamentoLinha];
			16: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[46:48] * 16 + DeslocamentoLinha];
			17: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[49:51] * 16 + DeslocamentoLinha];
			18: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[52:54] * 16 + DeslocamentoLinha];
			19: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[55:57] * 16 + DeslocamentoLinha];
			20: FileiraPixelsFinal <= Sprites[FileiraMapaTemp[58:60] * 16 + DeslocamentoLinha];
		endcase 
	end
	
	if (EstadoFuturo == MERGE_CELULA_PRETA || EstadoFuturo == MERGE_LIXO_1 || EstadoFuturo == MERGE_LIXO_2 || EstadoFuturo == MERGE_LIXO_3 || EstadoFuturo == MERGE_ROBO || EstadoFuturo == MERGE_CURSOR)
	begin
		if (FileiraPixelsTemp[47:45] != 3'b000)
		begin
			FileiraPixelsFinal[47:45] <= FileiraPixelsTemp[47:45];
		end
		
		if (FileiraPixelsTemp[44:42] != 3'b000)
		begin
			FileiraPixelsFinal[44:42] <= FileiraPixelsTemp[44:42];
		end
		
		if (FileiraPixelsTemp[41:39] != 3'b000)
		begin
			FileiraPixelsFinal[41:39] <= FileiraPixelsTemp[41:39];
		end		
		
		if (FileiraPixelsTemp[38:36] != 3'b000)
		begin
			FileiraPixelsFinal[38:36] <= FileiraPixelsTemp[38:36];
		end		
		
		if (FileiraPixelsTemp[35:33] != 3'b000)
		begin
			FileiraPixelsFinal[35:33] <= FileiraPixelsTemp[35:33];
		end		
		
		if (FileiraPixelsTemp[32:30] != 3'b000)
		begin
			FileiraPixelsFinal[32:30] <= FileiraPixelsTemp[32:30];
		end	
		
		if (FileiraPixelsTemp[29:27] != 3'b000)
		begin
			FileiraPixelsFinal[29:27] <= FileiraPixelsTemp[29:27];
		end
		
		if (FileiraPixelsTemp[26:24] != 3'b000)
		begin
			FileiraPixelsFinal[26:24] <= FileiraPixelsTemp[26:24];
		end
		
		if (FileiraPixelsTemp[23:21] != 3'b000)
		begin
			FileiraPixelsFinal[23:21] <= FileiraPixelsTemp[23:21];
		end
		
		if (FileiraPixelsTemp[20:18] != 3'b000)
		begin
			FileiraPixelsFinal[20:18] <= FileiraPixelsTemp[20:18];
		end
		
		if (FileiraPixelsTemp[17:15] != 3'b000)
		begin
			FileiraPixelsFinal[17:15] <= FileiraPixelsTemp[17:15];
		end
		
		if (FileiraPixelsTemp[14:12] != 3'b000)
		begin
			FileiraPixelsFinal[14:12] <= FileiraPixelsTemp[14:12];
		end
		
		if (FileiraPixelsTemp[11:9] != 3'b000)
		begin
			FileiraPixelsFinal[11:9] <= FileiraPixelsTemp[11:9];
		end
		
		if (FileiraPixelsTemp[8:6] != 3'b000)
		begin
			FileiraPixelsFinal[8:6] <= FileiraPixelsTemp[8:6];
		end
		
		if (FileiraPixelsTemp[5:3] != 3'b000)
		begin
			FileiraPixelsFinal[5:3] <= FileiraPixelsTemp[5:3];
		end
		
		if (FileiraPixelsTemp[2:0] != 3'b000)
		begin
			FileiraPixelsFinal[2:0] <= FileiraPixelsTemp[2:0];
		end
	end
	
	
end

always @ (posedge Clock25)
begin
	if (Reset || ZonaAtiva == 0 || IndicePixel == 31)
	begin
		IndicePixel <= 0;
	end
	else 
	begin
		IndicePixel <= IndicePixel + 1;
	end
end

// Proximo Estado e Saida
always @(*)
begin
	case (EstadoAtual)
		
		IDLE:
		begin
			if (Linha == LINHA_MAPA_1)
			begin					
				EstadoFuturo = AGUARDAR_COLUNA;				
			end
			else
			begin
				EstadoFuturo = IDLE;
			end
		end
		
		LER_FILEIRA_MAPA:
		begin
			
			if (Linha > LINHA_INFERIOR)
			begin
				EstadoFuturo = IDLE;
			end
			else
			begin
				EstadoFuturo = AGUARDAR_COLUNA;
			end
		end
		
		AGUARDAR_COLUNA:
		begin
			case (Coluna)
				COLUNA_MAPA_1:
				begin
					ColunaMapa = 1;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_2:
				begin
					ColunaMapa = 2;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_3:
				begin
					ColunaMapa = 3;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_4:
				begin
					ColunaMapa = 4;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_5:
				begin
					ColunaMapa = 5;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_6:
				begin
					ColunaMapa = 6;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_7:
				begin
					ColunaMapa = 7;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_8:
				begin
					ColunaMapa = 8;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_9:
				begin
					ColunaMapa = 9;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_10:
				begin
					ColunaMapa = 10;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_11:
				begin
					ColunaMapa = 11;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_12:
				begin
					ColunaMapa = 12;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_13:
				begin
					ColunaMapa = 13;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_14:
				begin
					ColunaMapa = 14;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_15:
				begin
					ColunaMapa = 15;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_16:
				begin
					ColunaMapa = 16;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_17:
				begin
					ColunaMapa = 17;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_18:
				begin
					ColunaMapa = 18;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_19:
				begin
					ColunaMapa = 19;
					EstadoFuturo = LER_FUNDO;
				end
				COLUNA_MAPA_20:
				begin
					ColunaMapa = 20;
					EstadoFuturo = LER_FUNDO;
				end
				default:
				begin
					ColunaMapa = 0;
					EstadoFuturo = AGUARDAR_COLUNA;
				end
			endcase 
		end
		
		LER_FUNDO:
		begin
			EstadoFuturo = LER_CELULA_PRETA;
		end
		
		LER_CELULA_PRETA:
		begin
			if (ColunaCelulaPreta == ColunaMapa && LinhaCelulaPreta == LinhaMapa)
			begin
				FileiraPixelsTemp = Sprites[112 + DeslocamentoLinha];
			end
			else
			begin
				FileiraPixelsTemp = 0;
			end
			EstadoFuturo = MERGE_CELULA_PRETA;			
		end
		
		MERGE_CELULA_PRETA:
		begin
			EstadoFuturo = LER_LIXO_1;
		end
		
		LER_LIXO_1:
		begin
			if (ColunaLixo1 == ColunaMapa && LinhaLixo1 == LinhaMapa)
			begin
				FileiraPixelsTemp = Sprites[32 + DeslocamentoLinha];
			end
			else
			begin
				FileiraPixelsTemp = 0;
			end
			EstadoFuturo = MERGE_LIXO_1;			
		end
		
		MERGE_LIXO_1:
		begin
			EstadoFuturo = LER_LIXO_2;
		end
		
		LER_LIXO_2:
		begin
			if (ColunaLixo2 == ColunaMapa && LinhaLixo2 == LinhaMapa)
			begin
				FileiraPixelsTemp = Sprites[48 + DeslocamentoLinha];
			end
			else
			begin
				FileiraPixelsTemp = 0;
			end
			EstadoFuturo = MERGE_LIXO_2;				 
		end
		
		MERGE_LIXO_2:
		begin
			EstadoFuturo = LER_LIXO_3;
		end
		
		LER_LIXO_3:
		begin
			if (ColunaLixo3 == ColunaMapa && LinhaLixo3 == LinhaMapa)
			begin
				FileiraPixelsTemp = Sprites[64 + DeslocamentoLinha];
			end
			else
			begin
				FileiraPixelsTemp = 0;
			end
			EstadoFuturo = MERGE_LIXO_3;				 
		end
		
		MERGE_LIXO_3:
		begin
			EstadoFuturo = LER_ROBO;
		end
		
		LER_ROBO:
		begin
			if (ColunaRobo == ColunaMapa && LinhaRobo == LinhaMapa)
			begin
				FileiraPixelsTemp = Sprites[DeslocamentoLinha];
			end
			else
			begin
				FileiraPixelsTemp = 0;
			end
			EstadoFuturo = MERGE_ROBO;			 
		end
		
		MERGE_ROBO:
		begin
			EstadoFuturo = LER_CURSOR;
		end
		
		LER_CURSOR:
		begin
			if (ColunaCursor == ColunaMapa && LinhaCursor == LinhaMapa)
			begin
				FileiraPixelsTemp = Sprites[16 + DeslocamentoLinha];
			end
			else
			begin
				FileiraPixelsTemp = 0;
			end
			EstadoFuturo = MERGE_CURSOR;				 
		end
		
		MERGE_CURSOR:
		begin
			if (ColunaMapa[0] == 1'b1)
			begin
				EstadoFuturo = FILEIRA_FINAL_LADO_ESQUERDO;
			end
			else
			begin
				EstadoFuturo = FILEIRA_FINAL_LADO_DIREITO;
			end			
		end
						
		FILEIRA_FINAL_LADO_ESQUERDO:
		begin
			EstadoFuturo = AGUARDAR_COLUNA;
			VetorPixels[0] = FileiraPixelsFinal[47:45];
			VetorPixels[1] = FileiraPixelsFinal[44:42];
			VetorPixels[2] = FileiraPixelsFinal[41:39];
			VetorPixels[3] = FileiraPixelsFinal[38:36];
			VetorPixels[4] = FileiraPixelsFinal[35:33];
			VetorPixels[5] = FileiraPixelsFinal[32:30];
			VetorPixels[6] = FileiraPixelsFinal[29:27];
			VetorPixels[7] = FileiraPixelsFinal[26:24];
			VetorPixels[8] = FileiraPixelsFinal[23:21];
			VetorPixels[9] = FileiraPixelsFinal[20:18];
			VetorPixels[10] = FileiraPixelsFinal[17:15];
			VetorPixels[11] = FileiraPixelsFinal[14:12];
			VetorPixels[12] = FileiraPixelsFinal[11:9];
			VetorPixels[13] = FileiraPixelsFinal[8:6];
			VetorPixels[14] = FileiraPixelsFinal[5:3];
			VetorPixels[15] = FileiraPixelsFinal[2:0];
		end
			
		FILEIRA_FINAL_LADO_DIREITO:
		begin
			if (ColunaMapa == 10)
			begin
				EstadoFuturo = LER_FILEIRA_MAPA;
			end
			else
			begin
				EstadoFuturo = AGUARDAR_COLUNA;
			end
			VetorPixels[16] = FileiraPixelsFinal[47:45];
			VetorPixels[17] = FileiraPixelsFinal[44:42];
			VetorPixels[18] = FileiraPixelsFinal[41:39];
			VetorPixels[19] = FileiraPixelsFinal[38:36];
			VetorPixels[20] = FileiraPixelsFinal[35:33];
			VetorPixels[21] = FileiraPixelsFinal[32:30];
			VetorPixels[22] = FileiraPixelsFinal[29:27];
			VetorPixels[23] = FileiraPixelsFinal[26:24];
			VetorPixels[24] = FileiraPixelsFinal[23:21];
			VetorPixels[25] = FileiraPixelsFinal[20:18];
			VetorPixels[26] = FileiraPixelsFinal[17:15];
			VetorPixels[27] = FileiraPixelsFinal[14:12];
			VetorPixels[28] = FileiraPixelsFinal[11:9];
			VetorPixels[29] = FileiraPixelsFinal[8:6];
			VetorPixels[30] = FileiraPixelsFinal[5:3];
			VetorPixels[31] = FileiraPixelsFinal[2:0];
		end
		default: EstadoFuturo = AGUARDAR_COLUNA;
	endcase
end

always @(*)
begin
	if (Linha >= LINHA_MAPA_1 && Linha < LINHA_MAPA_2)
	begin
		LinhaMapa = 1;
	end
	else if (Linha >= LINHA_MAPA_2 && Linha < LINHA_MAPA_3)
	begin
		LinhaMapa = 2;
	end
	else if (Linha >= LINHA_MAPA_3 && Linha < LINHA_MAPA_4)
	begin
		LinhaMapa = 3;
	end
	else if (Linha >= LINHA_MAPA_4 && Linha < LINHA_MAPA_5)
	begin
		LinhaMapa = 4;
	end
	else if (Linha >= LINHA_MAPA_5 && Linha < LINHA_MAPA_6)
	begin
		LinhaMapa = 5;
	end
	else if (Linha >= LINHA_MAPA_6 && Linha < LINHA_MAPA_7)
	begin
		LinhaMapa = 6;
	end
	else if (Linha >= LINHA_MAPA_7 && Linha < LINHA_MAPA_8)
	begin
		LinhaMapa = 7;
	end
	else if (Linha >= LINHA_MAPA_8 && Linha < LINHA_MAPA_9)
	begin
		LinhaMapa = 8;
	end
	else if (Linha >= LINHA_MAPA_9 && Linha < LINHA_MAPA_10)
	begin
		LinhaMapa = 9;
	end
	else if (Linha >= LINHA_MAPA_10 && Linha <= LINHA_INFERIOR)
	begin
		LinhaMapa = 10;
	end
	else
	begin
		LinhaMapa = 0;
	end
end

endmodule 