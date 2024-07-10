module Robo (clock, reset, head, left, avancar, girar, under, barrier, recolher_entulho);
// Inputs, Outputs, Registradores e Parâmetros
input clock, reset, head, left, under, barrier;
output reg avancar, girar, recolher_entulho;
reg [2:0] EstadoAtual, EstadoFuturo; // Corrigido para 3 bits, já que temos 5 estados
reg [1:0] contador;
reg flag_Stop;

parameter StandBy = 3'b000,
          Avancando = 3'b001,
          Rotacionando = 3'b010,
          Ret_Entulho = 3'b011,
          Giros = 3'b100;
          
// Definição FSM
always @* 
begin
    avancar = 1'b0;
    girar = 1'b0;
    recolher_entulho = 1'b0;

    case (EstadoAtual)
        StandBy: 
	begin
            case ({head, left, under, barrier})
                4'b1??1: EstadoFuturo = StandBy;

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

                default: EstadoFuturo = StandBy;
            endcase
        end
        
        Avancando: 
	begin
            case ({head, left, under, barrier})
                4'b1??1: EstadoFuturo = StandBy;

                4'b??1?: EstadoFuturo = StandBy;

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

                default: EstadoFuturo = StandBy;
            endcase
        end

        Rotacionando:
	 begin
            case ({head, left, under, barrier})
                4'b1??1: EstadoFuturo = StandBy;

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

                default: EstadoFuturo = StandBy;
            endcase
        end
        
        Ret_Entulho: 
	begin
            case ({head, left, under, barrier})
                4'b1???: EstadoFuturo = StandBy;

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

                default: EstadoFuturo = StandBy;
            endcase
        end
        
        Giros: 
	begin
            case ({head, left, under, barrier})
                4'b1??1: EstadoFuturo = StandBy;

                4'b00?0: 
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

                default: EstadoFuturo = StandBy;
            endcase
        end
        
        default: EstadoFuturo = StandBy;
    endcase
end

// Atualização de Estado e Reset
always @(negedge clock or posedge reset) 
    begin
    if (reset)
	begin
        EstadoAtual <= StandBy;
	contador <= 2'b00;			// Contador de Pulsos (Ret_Entulho) setado para 0
	flag_Stop <= 1'b1;			// Flag de botão Reset setado para 1
	end

    else 
	begin
	if (EstadoAtual == Ret_Entulho && contador != 2'b11)
		begin
		contador <= contador + 1;
		end

      	else
		begin
		if (EstadoAtual == StandBy && flag_Stop == 1'b1)
			begin
			EstadoAtual <= EstadoFuturo;
			flag_Stop <= 1'b0;
			end
		
		else
			begin
        		EstadoAtual <= EstadoFuturo;
        		if (EstadoAtual != Ret_Entulho)
				contador <= 2'b00;
			end
		end
	end
   end
endmodule

