module Interface_VGA (Clock, Reset, v_sync, h_sync, blank, RGB, R, G, B, ColunaOut, LinhaOut);

input Clock, Reset;
input [23:0] RGB;
output v_sync, h_sync, blank;
output [7:0] R;
output [7:0] G;
output [7:0] B;
output [9:0] LinhaOut, ColunaOut;

reg [9:0] Linha, Coluna;

always @ (posedge Clock)
begin
	if (Reset)
	begin
		Linha <= 0;
		Coluna <= 0;
	end
	else
	begin
		Coluna <= Coluna + 1;
		if (Coluna == 794)
		begin
			Coluna <= 0;
			Linha <= Linha + 1;
			if (Linha == 525)
			begin
				Linha <= 0;
			end
		end
	end
end

assign blank = ((Coluna < 140) || (Coluna > 778) || (Linha < 35) || (Linha > 515))?0:1;
assign h_sync = (Coluna < 95)? 0 : 1;
assign v_sync = (Linha < 2)? 0 : 1;
assign LinhaOut = Linha;
assign ColunaOut = Coluna;
assign R = RGB[23:16];
assign G = RGB[15:8];
assign B = RGB[7:0];

endmodule 