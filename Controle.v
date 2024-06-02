module Controle(
    input wire clock,
    input wire reset, 
    output reg btn_reset, // Botão de reset
    output reg btn_mode,  // Botão de alteração de modo
    output reg btn_step   // Botão de passo-a-passo
);

    initial begin
        btn_reset = 0;
        btn_mode = 0;
        btn_step = 0;
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // Resetar os botões
            btn_reset <= 0;
            btn_mode <= 0;
            btn_step <= 0;
        end else begin
            // Lógica do controle
            // A principio pode ser substituido por outra lógica
            // Implementação da interface com gamepad
        end
    end
endmodule
