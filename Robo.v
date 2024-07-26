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
always @* 
begin
// Reset dos Sinais de Saida a cada ciclo
    avancar = 1'b0;
    girar = 1'b0;
    recolher_entulho = 1'b0;

// Estrutura Switch-Case p/ Verificacao de Estado Atual + Escolha de Proximo Estado
    case (EstadoAtual)
	// Situacoes Possiveis
        StandBy: 
	begin
	if (flag_Stop)
	    begin
	    	EstadoFuturo = StandBy; // Mantem em StandBy caso flag_Stop estiver ativada
	    end

	else
	    begin
            	casez ({head, left, under, barrier})
		// Situacoes Previstas
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
        end
        
        Avancando: 
	begin
            casez ({head, left, under, barrier})
	    // Situacoes Previstas
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
            casez ({head, left, under, barrier})
	    // Situacoes Previstas
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
            casez ({head, left, under, barrier})
	    // Situacoes Previstas
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
            casez ({head, left, under, barrier})
	    // Situacoes Previstas
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

