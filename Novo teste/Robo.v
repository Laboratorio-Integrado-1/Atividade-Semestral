module Robo (clock, reset, head, left, under, barrier, avancar, girar, recolher_entulho);
// Inputs, Outputs, Registradores e Par�metros
input clock, reset, head, left, under, barrier;		// Sinais de Entrada
output reg avancar, girar, recolher_entulho;		// Sinais de Saida
reg [2:0] EstadoAtual, EstadoFuturo; 			// Registrador de 3 bits p/ 5 estados
reg [1:0] contador;					// Registrador p/ contador de saida recolher entulho
reg flag_Stop;						// Registrador p/ flag de parada do StandBy

// Parametros do Codigo (Estados da FSM)
parameter StandBy = 3'b000,
          Avancando = 3'b001,
          Rotacionando = 3'b010,
          Ret_Entulho = 3'b011,
          Giros = 3'b100;

          
// Definicao FSM
always @(posedge clock)
begin
	// Reset dos Sinais de Saida a cada ciclo
	avancar <= 1'b0;
	girar <= 1'b0;
	recolher_entulho <= 1'b0;
	if(!reset)
	begin
		// Estrutura Switch-Case p/ Verificacao de Estado Atual + Escolha de Proximo Estado
		case (EstadoAtual)
		// Situacoes Possiveis
			StandBy: 
		begin
		if (flag_Stop)
			begin
				EstadoFuturo <= StandBy; // Mantem em StandBy caso flag_Stop estiver ativada
			end

		else
			begin
					case ({head, left, under, barrier})
			// Situacoes Previstas
						4'b0000: 
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0001:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0010:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0011:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0100:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0101:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0110:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0111:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b1000:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1001: EstadoFuturo <= StandBy;

				4'b1010:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1011: EstadoFuturo <= StandBy;

				4'b1100:
					begin
						EstadoFuturo <= Giros;
						girar <= 1'b1;
					end

				4'b1101: EstadoFuturo <= StandBy;

				4'b1110:
					begin
						EstadoFuturo <= Giros;
						girar <= 1'b1;
					end

				4'b1111: EstadoFuturo <= StandBy;
						
						default: EstadoFuturo <= StandBy;
					endcase
			end
			end
			
			Avancando: 
		begin
				case ({head, left, under, barrier})
			// Situacoes Previstas
						4'b0000: 
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b0001:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0010: EstadoFuturo <= StandBy;

				4'b0011: EstadoFuturo <= StandBy;

				4'b0100:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0101:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0110: EstadoFuturo <= StandBy;

				4'b0111: EstadoFuturo <= StandBy;

				4'b1000:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1001: EstadoFuturo <= StandBy;

				4'b1010: EstadoFuturo <= StandBy;

				4'b1011: EstadoFuturo <= StandBy;

				4'b1100:
					begin
						EstadoFuturo <= Giros;
						girar <= 1'b1;
					end

				4'b1101: EstadoFuturo <= StandBy;

				4'b1110: EstadoFuturo <= StandBy;

				4'b1111: EstadoFuturo <= StandBy;

					default: EstadoFuturo <= StandBy;
				endcase
			end

			Rotacionando:
		begin
				case ({head, left, under, barrier})
			// Situacoes Previstas
						4'b0000: 
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0001:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0010:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0011:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0100:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0101:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0110:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0111:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b1000:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1001: EstadoFuturo <= StandBy;

				4'b1010:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1011: EstadoFuturo <= StandBy;

				4'b1100:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1101: EstadoFuturo <= StandBy;

				4'b1110:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1111: EstadoFuturo <= StandBy;

					default: EstadoFuturo <= StandBy;
				endcase
			end
			
			Ret_Entulho: 
		begin
				case ({head, left, under, barrier})
			// Situacoes Previstas
						4'b0000: 
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0001:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0010:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0011:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0100:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0101:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0110:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0111:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b1000: EstadoFuturo <= StandBy;

				4'b1001: EstadoFuturo <= StandBy;

				4'b1010: EstadoFuturo <= StandBy;

				4'b1011: EstadoFuturo <= StandBy;

				4'b1100: EstadoFuturo <= StandBy;

				4'b1101: EstadoFuturo <= StandBy;

				4'b1110: EstadoFuturo <= StandBy;

				4'b1111: EstadoFuturo <= StandBy;

					default: EstadoFuturo <= StandBy;
				endcase
			end
			
			Giros: 
		begin
				case ({head, left, under, barrier})
			// Situacoes Previstas
						4'b0000: 
					begin
						EstadoFuturo <= Avancando;
						girar <= 1'b1;
					end

				4'b0001:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0010:
					begin
						EstadoFuturo <= Avancando;
						girar <= 1'b1;
					end

				4'b0011:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0100:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0101:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b0110:
					begin
						EstadoFuturo <= Avancando;
						avancar <= 1'b1;
					end

				4'b0111:
					begin
						EstadoFuturo <= Ret_Entulho;
						recolher_entulho <= 1'b1;
					end

				4'b1000: 
					begin
						EstadoFuturo <= Giros;
						girar <= 1'b1;
					end

				4'b1001: EstadoFuturo <= StandBy;

				4'b1010: 
					begin
						EstadoFuturo <= Giros;
						girar <= 1'b1;
					end

				4'b1011: EstadoFuturo <= StandBy;

				4'b1100:
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1101: EstadoFuturo <= StandBy;

				4'b1110: 
					begin
						EstadoFuturo <= Rotacionando;
						girar <= 1'b1;
					end

				4'b1111: EstadoFuturo <= StandBy;

					default: EstadoFuturo <= StandBy;
				endcase
			end
			
			default: EstadoFuturo <= StandBy;
		endcase
	end
end

// Atualizacao de Estado e Reset
always @(negedge clock or posedge reset) 
begin
    if (reset)						// Verificacaoo se botao Reset foi presionado
	begin
        	EstadoAtual <= StandBy;			// Estado Inicial/Reset
		flag_Stop <= 1'b0;			// Flag de botao Reset desativada
	end

    else 
	begin
		if (EstadoAtual == StandBy && flag_Stop)			// Caso Robo entrou no Estado StandBy e nao foi aplicado Reset
			begin
				EstadoAtual <= StandBy;
			end
		
		else
			begin
				EstadoAtual <= EstadoFuturo;
				
				if (EstadoFuturo == StandBy)			// Caso Robo entre em Estado StandBy -> necessario que permaneca parado ate sinal de Reset
					begin
						flag_Stop <= 1'b1;
					end
			end
	end
end
endmodule