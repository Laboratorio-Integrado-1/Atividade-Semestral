`timescale 1ns/1ns;

module TestBench;

reg	CLOCK_50;
reg	CLOCK_25;
reg	Pino1;
reg	Pino2;
reg	Pino3;
reg	Pino4;
reg	Pino6;
reg	Pino9;
reg	[17:17] SW;
wire VGA_VS;
wire VGA_HS;
wire VGA_BLANK_N;
wire VGA_CLK;
wire Select;
wire [7:0] LEDG;
wire [11:0] LEDR;
wire [7:0] VGA_B;
wire [7:0] VGA_G;
wire [7:0] VGA_R;
wire PRINT;

TOP DUV (
	CLOCK_50,
	CLOCK_25,
	Pino1,
	Pino2,
	Pino3,
	Pino4,
	Pino6,
	Pino9,
	SW,
	VGA_VS,
	VGA_HS,
	VGA_BLANK_N,
	VGA_CLK,
	Select,
	LEDG,
	LEDR,
	VGA_B,
	VGA_G,
	VGA_R,
	PRINT
);


integer Arquivo, i, linha, coluna;
reg [23:0] Imagem [0:479] [0:639];
integer contador_imagens;
reg [8*20:1] nome_arquivo;

integer frame_counter;
reg capture_enable;
reg v_sync_prev;

always
begin
	#10 CLOCK_50 = !CLOCK_50;
end	

always
begin
	#20 CLOCK_25 = !CLOCK_25;
end	

initial
begin
	CLOCK_50 = 0;
	CLOCK_25 = 0;
	SW = 1;
	#105 SW = 0;
	contador_imagens = 0;
	frame_counter = 0;

	repeat (30) begin 
		@(negedge PRINT);
		GerarImagem;
		contador_imagens = contador_imagens + 1; // Incrementa o contador de imagens
	end
end

task GerarImagem();
begin
	$sformat(nome_arquivo, "VGA_%0d.bmp", contador_imagens); // Nome do arquivo com o contador
	Arquivo = $fopen(nome_arquivo, "w");
	
	// Gerar o cabeçalho da imagem
	$fwrite(Arquivo, "%s", 40'h42_4D_36_10_0E);
	GerarZeros(5);
	$fwrite(Arquivo, "%s", 8'h36);
	GerarZeros(3);
	$fwrite(Arquivo, "%s", 8'h28);
	GerarZeros(3);
	$fwrite(Arquivo, "%s", 16'h80_02);
	GerarZeros(2);
	$fwrite(Arquivo, "%s", 16'hE0_01);
	GerarZeros(2);
	$fwrite(Arquivo, "%s", 8'h01);
	GerarZeros(1);
	$fwrite(Arquivo, "%s", 8'h18);
	GerarZeros(6);
	$fwrite(Arquivo, "%s", 16'h10_0E);
	GerarZeros(1);
	$fwrite(Arquivo, "%s", 16'h25_16);
	GerarZeros(2);
	$fwrite(Arquivo, "%s", 16'h25_16);
	GerarZeros(10);
	
	// Capturar e escrever os pixels
	for (linha = 0; linha < 480; linha = linha + 1)
	begin
		@(posedge VGA_BLANK_N);
		for (coluna = 0; coluna < 640; coluna = coluna + 1)
		begin
			@(negedge VGA_CLK);			
			Imagem[linha][coluna] = {VGA_B, VGA_G, VGA_R}; // BGR
		end
	end
	
	for (linha = 479; linha >= 0; linha = linha - 1)
	begin
		for (coluna = 0; coluna < 640; coluna = coluna + 1)
		begin
			$fwrite(Arquivo, "%s", Imagem[linha][coluna]);
		end
	end
	
	$fclose(Arquivo); // Fechar o arquivo
end
endtask 

task GerarZeros(input integer N);
begin
	for (i = 0; i < N; i = i + 1)
	begin
		$fwrite(Arquivo, "%c", 0);
	end
end
endtask 

endmodule 
