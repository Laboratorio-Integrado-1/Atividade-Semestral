module TOP_VGA(
	CLOCK_50,
	CLOCK_25,
	SW,
	VGA_VS,
	VGA_HS,
	VGA_BLANK_N,
	VGA_CLK,
	LEDG,
	LEDR,
	VGA_B,
	VGA_G,
	VGA_R
);

input wire	CLOCK_50;
input wire	CLOCK_25;
input wire	[17:17] SW;
output wire	VGA_VS;
output wire	VGA_HS;
output wire	VGA_BLANK_N;
output wire	VGA_CLK;
output wire	[7:0] LEDG;
output wire	[11:0] LEDR;
output wire	[7:0] VGA_B;
output wire	[7:0] VGA_G;
output wire	[7:0] VGA_R;

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
    .Linha(SYNTHESIZED_WIRE_4),
	.Coluna(SYNTHESIZED_WIRE_2),
    .RGB(SYNTHESIZED_WIRE_7));


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

endmodule