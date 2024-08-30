module TOP(
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

input wire	CLOCK_50;
input wire	CLOCK_25;
input wire	Pino1;
input wire	Pino2;
input wire	Pino3;
input wire	Pino4;
input wire	Pino6;
input wire	Pino9;
input wire	[17:17] SW;
output wire	VGA_VS;
output wire	VGA_HS;
output wire	VGA_BLANK_N;
output wire	VGA_CLK;
output wire	Select;
output wire	[7:0] LEDG;
output wire	[11:0] LEDR;
output wire	[7:0] VGA_B;
output wire	[7:0] VGA_G;
output wire	[7:0] VGA_R;
output wire PRINT;

wire [9:0] SYNTHESIZED_WIRE_2;
wire [29:0] SYNTHESIZED_WIRE_3;
wire [9:0] SYNTHESIZED_WIRE_4;
wire [23:0] SYNTHESIZED_WIRE_5;
wire [23:0] SYNTHESIZED_WIRE_7;
wire SYNTHESIZED_WIRE_15;
wire [11:0] SYNTHESIZED_WIRE_10;
wire SYNTHESIZED_WIRE_11;
wire SYNTHESIZED_WIRE_12;
wire SYNTHESIZED_WIRE_13;
wire SYNTHESIZED_WIRE_14;
wire SYNTHESIZED_WIRE_16;
wire SYNTHESIZED_WIRE_17;
wire SYNTHESIZED_WIRE_18;
wire [0:1]SYNTHESIZED_WIRE_19;
wire SYNTHESIZED_WIRE_20;


//assign	VGA_VS = SYNTHESIZED_WIRE_15;
assign	VGA_CLK = CLOCK_25;
assign PRINT = SYNTHESIZED_WIRE_20;
//assign	LEDR = SYNTHESIZED_WIRE_10;
//assign	Head = SYNTHESIZED_WIRE_11;
//assign	Left = SYNTHESIZED_WIRE_12;
//assign	Under = SYNTHESIZED_WIRE_13;
//assign	Barrier = SYNTHESIZED_WIRE_14;
//assign	Avancar = SYNTHESIZED_WIRE_16;
//assign	Girar = SYNTHESIZED_WIRE_17;
//assign	Recolher_Entulho = SYNTHESIZED_WIRE_18;


Grafico	b2v_inst(
    .Clock50(CLOCK_50),
    .Clock25(CLOCK_25),
	.Reset(SW),
	.ColunasSprites(SYNTHESIZED_WIRE_3),
	.LinhasSprites(SYNTHESIZED_WIRE_5),
    .Linha(SYNTHESIZED_WIRE_4),
	.Coluna(SYNTHESIZED_WIRE_2),
    .RGB(SYNTHESIZED_WIRE_7),
	.OrientacaoRobo(SYNTHESIZED_WIRE_19));


Interface_VGA b2v_inst1(
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

Controlador	b2v_inst4(
	.Clock50(CLOCK_50),
	.reset(SW),
	.Entradas(SYNTHESIZED_WIRE_10),
	.v_sync(SYNTHESIZED_WIRE_15),
	.avancar(Avancar),
	.head(SYNTHESIZED_WIRE_11),
	.left(SYNTHESIZED_WIRE_12),
	.under(SYNTHESIZED_WIRE_13),
	.barrier(SYNTHESIZED_WIRE_14),
	.girar(SYNTHESIZED_WIRE_17),
	.remover(SYNTHESIZED_WIRE_18),
	.LEDG(LEDG),
	.LEDR(LEDR),
	.ColunasSprites(SYNTHESIZED_WIRE_3),
	.LinhasSprites(SYNTHESIZED_WIRE_5),
	.OrientacaoRobo(SYNTHESIZED_WIRE_19),
	.AtivaRobo(SYNTHESIZED_WIRE_20));


Controle b2v_inst7(
	.Clock50(CLOCK_50),
	.Reset(SW),
	.Pino1(Pino1),
	.Pino2(Pino2),
	.Pino3(Pino3),
	.Pino4(Pino4),
	.Pino6(Pino6),
	.Pino9(Pino9),
	.v_sync(SYNTHESIZED_WIRE_15),
	.Select(Select),
	.Saidas(SYNTHESIZED_WIRE_10));


Robo b2v_inst8(
	.clock(SYNTHESIZED_WIRE_20), 
	.reset(SW), 
	.head(SYNTHESIZED_WIRE_11), 
	.left(SYNTHESIZED_WIRE_12), 
	.under(SYNTHESIZED_WIRE_13), 
	.barrier(SYNTHESIZED_WIRE_14), 
	.avancar(Avancar), 
	.girar(SYNTHESIZED_WIRE_17), 
	.recolher_entulho(SYNTHESIZED_WIRE_18));

endmodule