module Robo (clock, reset, head, left, avancar, girar, under, rubble);
// Inputs, Outputs, Registradores e Parâmetros
input clock, reset, head, left, under, rubble;
output reg avancar, girar, recolher_entulho;
reg [1:0] EstadoAtual, EstadoFuturo;
reg[1:0] contador = 1'b1;

parameter StandBy = 3'b000,
	  Avancando = 3'b001,
	  Rotacionando = 3'b010,
	  Ret_Entulho = 3'b011,
	  Giros = 3'b100;
	  

// Definição FSM
always @*
avancar = 1'b0;
girar = 1'b0;
recolher_entulho = 1'b0;

begin
// Switch (Case):
case (EstadoAtual)
	StandBy: case({head, left, under, rubble})
			4'b1??1: 
				begin
				EstadoFuturo = StandBy;
				end
			4'b0??0:
				begin
				EstadoFuturo = Avancando;
				avancar = 1'b1;
				end
			4'b10?0:
				begin
				EstadoFuturo = Rotacionando;
				girar = 1'b1;
				end
			4'b0??1:
				begin
				EstadoFuturo = Ret_Entulho;
				recolher_entulho = 1'b1;
				end
			4'b11?0:
				begin
				EstadoFuturo = Giros;
				girar = 1'b1;
				end
		endcase

	Avancando: case({head, left, under, rubble})
			4'1??1: 
				begin
				EstadoFuturo = StandBy;
				end
			4'??1?:
				begin
				EstadoFuturo = StandBy;
				end
			4'b0100:
				begin
				EstadoFuturo = Avancando;
				avancar = 1'b1;
				end
			4'b?000:
				begin
				EstadoFuturo = Rotacionando;
				girar = 1'b1;
				end
			4'b0?01:
				begin
				EstadoFuturo = Ret_Entulho;
				recolher_entulho = 1'b1;
				end
			4'b1100:
				begin
				EstadoFuturo = Giros;
				girar = 1'b1;
				end
			endcase	

	Rotacionando: case({head, left, under, rubble})
			4'1??1: 
				begin
				EstadoFuturo = StandBy;
			4'b0??0:
				begin
				EstadoFuturo = Avancando;
				avancar = 1'b1;
				end
			4'b1??0:
				begin
				EstadoFuturo = Rotacionando;
				girar = 1'b1;
				end
			4'b0??1:
				begin
				EstadoFuturo = Ret_Entulho;
				recolher_entulho = 1'b1;
				end
			endcase	

	Ret_Entulho: case({head, left, under, rubble})
			4'1???: 
				begin
				EstadoFuturo = StandBy;
				end
			4'b0??0:
				begin
				EstadoFuturo = Avancando;
				avancar = 1'b1;
				end
			4'b0??1:
				begin
				EstadoFuturo = Ret_Entulho;
				recolher_entulho = 1'b1;
				end
			endcase	

	Giros: case({head, left, under, rubble})
			4'1??1: 
				begin
				EstadoFuturo = StandBy;
				end
			4'00?0:
				begin
				EstadoFuturo = Avancando;
				girar = 1'b1;
				end
			4'b01?0:
				begin
				EstadoFuturo = Avancando;
				avancar = 1'b1;
				end
			4'b11?0:
				begin
				EstadoFuturo = Rotacionando;
				girar = 1'b1;
				end
			4'b0??1:
				begin
				EstadoFuturo = Ret_Entulho;
				recolher_entulho = 1'b1;
				end
			4'b10?0:
				begin
				EstadoFuturo = Giros;
				girar = 1'b1;
				end
			endcase	

	
	default:
		begin
		EstadoFuturo = StandBy;
		end
endcase
end

// Att de Estado e Reset
always @(negedge clock or negedge reset)
if(reset)
	EstadoAtual <= StandBy;

else
	begin
	if (contador)
		EstadoAtual <= EstadoFuturo;
	contador <= ~contador;
	end
end

endmodule
