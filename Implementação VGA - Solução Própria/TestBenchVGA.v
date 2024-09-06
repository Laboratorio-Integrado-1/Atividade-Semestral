`timescale 1ns/1ns;

module TestBenchVGA;

reg	CLOCK_50;
reg	CLOCK_25;
reg	[17:17] SW;
wire VGA_VS;
wire VGA_HS;
wire VGA_BLANK_N;
wire VGA_CLK;
wire [7:0] VGA_B;
wire [7:0] VGA_G;
wire [7:0] VGA_R;
wire	[9:0] SYNTHESIZED_WIRE_2;
wire	[23:0] SYNTHESIZED_WIRE_3;
wire	[9:0] SYNTHESIZED_WIRE_4;
wire	[17:0] SYNTHESIZED_WIRE_5;
wire	[23:0] SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_15;
wire	[11:0] SYNTHESIZED_WIRE_10;
assign	VGA_VS = SYNTHESIZED_WIRE_15;
assign	VGA_CLK = CLOCK_25;

VGA_GRAPHS b2v_inst(
    .reset(SW),
    .clock_50(CLOCK_50),
    .clock_25(CLOCK_25),
    .Linha(SYNTHESIZED_WIRE_4),
	.Coluna(SYNTHESIZED_WIRE_2),
    .RGB(SYNTHESIZED_WIRE_7)
);

Interface_VGA	b2v_inst1(
	.Clock(CLOCK_25),
	.Reset(SW),
	.RGB(SYNTHESIZED_WIRE_7),
	.v_sync(SYNTHESIZED_WIRE_15),
	.h_sync(VGA_HS),
	.blank(VGA_BLANK_N),
	.B(VGA_B),
	.ColunaOut(SYNTHESIZED_WIRE_2),
	.G(VGA_G),
	.LinhaOut(SYNTHESIZED_WIRE_4),
	.R(VGA_R));

integer Arquivo, i, linha, coluna;
reg [23:0] Imagem [0:479] [0:639];

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
	Arquivo = $fopen("VGA.bmp", "w");
	//Cabecalho = 432'h42_4D_36_10_0E_00_00_00_00_00_36_00_00_00_28_00_00_00_80_02_00_00_E0_01_00_00_01_00_18_00_00_00_00_00_00_10_0E_00_25_16_00_00_25_16_00_00_00_00_00_00_00_00_00_00;
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
	GerarImagem;
	$fclose(Arquivo);
	$stop;
end

task GerarZeros(input integer N);
begin
	for (i = 0; i < N; i = i + 1)
	begin
		$fwrite(Arquivo, "%c", 0);
	end
end
endtask 

task GerarImagem();
begin
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
end
endtask 

endmodule 
