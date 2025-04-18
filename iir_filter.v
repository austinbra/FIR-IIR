module iir_filter #(
    parameter N = 16
)(
    input clk,
    input rst,
    input signed [15:0] x_in,
    output reg signed [15:0] y_out,
    input signed [15:0] b0, b1, b2, //curr and prior input wieght
    input signed [15:0] a1, a2 //prior output weight
);
    reg signed [15:0] x1, x2; //x1 = x[n-1], x2 = x[n-2] prior input calue
    reg signed [31:0] y1, y2; //y1 = y[n-1], y2 = y[n-2] prior output value
    wire signed [31:0] acc;
    reg signed [15:0] y_new;


    assign acc = (b0*x_in + b1*x1 + b2*x2 - a1*y1 - a2*y2);
    $display(acc);


    always @(posedge clk) begin
        if (rst) begin
            x1 <= 0;
            x2 <= 0;
            y1 <= 0;
            y2 <= 0;
            y_out <=0;
        end else begin
            //shift by 15 to get corrrect mult
            y_new = acc >>> 15;
            if (y_new > ((1 << (N-1)) - 1)) begin
                y_new <= ((1 << (N-1)) - 1);  // Positive saturation check
            end else if (y_new < -(1 << (N-1))) begin
                y_new <= -(1 << (N-1)); // Negative saturation check
            end
            y_out <= y_new;
            x2 <= x1;
            x1 <= x_in;
            y2 <= y1;
            y1 <= y_new;
        end
    end
endmodule