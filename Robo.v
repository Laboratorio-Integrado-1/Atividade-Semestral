module Robo (clock, reset, head, left, under, barrier, avancar, girar, recolher_entulho);
// Inputs, Outputs, Registradores e Par�metros
input clock, reset, head, left, under, barrier;		// Sinais de Entrada
output reg avancar, girar, recolher_entulho;		// Sinais de Sa�da
reg [2:0] EstadoAtual, EstadoFuturo; 			// Registrador de 3 bits p/ 5 estados
reg [1:0] contador;					// Registrador p/ contador de sa�da recolher entulho
reg flag_Stop;						// Registrador p/ flag de parada do StandBy

// Par�metros do C�digo (Estados da M�quina de Estados)
parameter StandBy = 3'b000,
          Avancando = 3'b001,
          Rotacionando = 3'b010,
          Ret_Entulho = 3'b011,
          Giros = 3'b100;

          
// Defini��o FSM
always @* 
begin
// Reset dos Sinais de Sa�da a cada ciclo
    avancar = 1'b0;
    girar = 1'b0;
    recolher_entulho = 1'b0;

// Estrutura Switch-Case p/ Verifica��o de Estado Atual + Escolha de Pr�ximo Estado
    case (EstadoAtual)
	// Situa��es poss�veis definidas
        StandBy: 
	begin
	if (flag_Stop)
	    begin
	    	EstadoFuturo = StandBy; // Mant�m em StandBy caso flag_Stop estiver ativada
	    end

	else
	    begin
            	casez ({head, left, under, barrier})
		// Situa��es Previstas
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
	    // Situa��es Previstas
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
	    // Situa��es Previstas
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
	    // Situa��es Previstas
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
	    // Situa��es Previstas
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

// Atualiza��o de Estado e Reset
always @(negedge clock or posedge reset) 
begin
    if (reset)						// Verifica��o se bot�o Reset foi presionado
	begin
        	EstadoAtual <= StandBy;			// Estado Inicial/Reset
		//contador <= 2'b00;			// Contador de Pulsos (Ret_Entulho) setado para 0
		flag_Stop <= 1'b0;			// Flag de bot�o Reset desativada
	end

    else 
	begin
		if (EstadoAtual == StandBy && flag_Stop)			// Caso Rob� entrou no Estado StandBy e n�o foi aplicado Reset
			begin
				EstadoAtual <= StandBy;
			end
		
		//else if (EstadoAtual == Ret_Entulho )//&& contador != 2'b11)	// Caso Rob� entrou no Estado Recolher Entulho e n�o se passou 3 pulsos de remo��o
			//begin	
			//	contador <= contador + 1;
			//end
		
		else
			begin
				EstadoAtual <= EstadoFuturo;
				
				if (EstadoFuturo == StandBy)			// Caso Rob� entre em Estado StandBy � necess�rio que permane�a parado at� sinal de Reset
					begin
						flag_Stop <= 1'b1;
					end

				//if (EstadoAtual != Ret_Entulho)			// Caso Rob� n�o entre em Remover Entulho, Reset de contador de pulsos
					//begin
						//contador <= 2'b00;
					//end
			end
	end
end
endmodule

