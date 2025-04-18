module fir_filter #(
    parameter N = 16
)(
    input clk,
    input rst,
    input signed [15:0] x_in,
    output reg signed [31:0] y_out,
    input signed [15:0] coeffs [0:N-1]
);

    reg signed [15:0] shift_reg [0:N-1];
    integer i;
    reg signed [31:0] sum; // instead of integer

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < N; i = i + 1)
                shift_reg[i] <= 0;
            y_out <= 0;
        end else begin
            //shift reg
            for (i = N-1; i > 0; i = i - 1)
                shift_reg[i] <= shift_reg[i-1];
            shift_reg[0] <= x_in;

            //multiplication stuff
            sum = 0;
            for (i = 0; i < N; i = i + 1)
                sum = sum + shift_reg[i] * coeffs[i];
            y_out <= sum;
        end
    end
endmodule