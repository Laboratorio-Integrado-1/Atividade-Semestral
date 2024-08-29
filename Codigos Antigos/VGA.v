module VGA(clock, reset, icon, pos_x, pos_y, o_red, o_green, o_blue);
input clock, reset;
//input [7:0] color;
input [4:0] pos_x;
input [4:0] pos_y;
input string icon;
output [7:0] o_red, o_green, o_blue;

reg [9:0] counter_x = 0;  // horizontal counter
reg [9:0] counter_y = 0;  // vertical counter
reg [7:0] r_red = 0;
reg [7:0] r_blue = 0;
reg [7:0] r_green = 0;

wire clk25MHz;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// clk divider 50 MHz to 25 MHz
ip ip1(
	.areset(reset),
	.inclk0(clk),
	.c0(clk25MHz),
	.locked()
	);  
// end clk divider 50 MHz to 25 MHz

always @(posedge clk25MHz)  // horizontal counter
	begin 
		if (counter_x < 799)
			counter_x <= counter_x + 1;  // horizontal counter (including off-screen horizontal 160 pixels) total of 800 pixels 
		else
			counter_x <= 0;              
	end  // always 

always @ (posedge clk25MHz)  // vertical counter
	begin 
		if (counter_x == 799)  // only counts up 1 count after horizontal finishes 800 counts
			begin
				if (counter_y < 525)  // vertical counter (including off-screen vertical 45 pixels) total of 525 pixels
					counter_y <= counter_y + 1;
				else
					counter_y <= 0;              
			end  // if (counter_x...
	end  // always	

	
// por hora apenas sprite todo branco
always @ (posedge clk)
		begin
			if(counter_x >= pos_x && counter_x <= pos_x + 16)
				if(counter_y >= pos_y && counter_y <= pos_y + 16)
					begin
						if(icon == '0') begin
							r_red <= 8'hf; // branco
							r_blue <= 8'hf;
							r_green <= 8'hf; 
							end
						if(icon == '1') begin
							r_red <= 8'0; // preto
							r_blue <= 8'0;
							r_green <= 8'0; 
							end
					end
		end
	
	assign o_red = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_red;
	assign o_blue = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_blue;
	assign o_green = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_green;
endmodule