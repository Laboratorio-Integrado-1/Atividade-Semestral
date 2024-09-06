module Graphic(clock, reset, map, vga_R, vga_G, vga_B);

input [3:0] Mapa [0:10][0:19]; // Atualizacao para 10 linhas e 20 colunas
output vga_R, vga_G, vga_B;

wire vga_R, vga_G, vga_B;

for (int i=0; i<10; i++) begin
	for (int j=0; j<20; j++) begin
		VGA DUV(clock, reset, Mapa[i][j], i*30, j*30, vga_R, vga_G, vga_B);
	end
end

endmodule
