module iir_filter #(
    parameter N = 16
)(
    input clk,
    input rst,
    input signed [15:0] x_in,
    output reg signed [N-1:0] y_out,
    input signed [31:0] b0, b1, b2, //curr and prior input wieght
    input signed [31:0] a1, a2 //prior output weight
);
    reg signed [15:0] x1, x2; //x1 = x[n-1], x2 = x[n-2] prior input calue
    reg signed [N-1:0] y1_state, y2_state; //y1 = y[n-1], y2 = y[n-2] prior output value
    wire signed [48:0] acc;
    reg signed [48:0] acc_scaled_down;


    localparam MAX_OUT = (1 << (N-1)) - 1; // Max positive for N bits
    localparam MIN_OUT = -(1 << (N-1));    // Min negative for N bits

    assign acc = ($signed(b0) * $signed(x_in))   + 
             ($signed(b1) * $signed(x1))   + 
             ($signed(b2) * $signed(x2))   - 
             ($signed(a1) * $signed(y1_state)) - 
             ($signed(a2) * $signed(y2_state));


    always @(posedge clk) begin

        if (rst) begin
            x1 <= 0;
            x2 <= 0;
            y1_state <= 0;
            y2_state <= 0;
            y_out <=0;
            acc_scaled_down <= 0;
        end else begin
            //shift by 15 to match coeff scaling
            acc_scaled_down  = acc >>> 15;

            //saturation stuff
            if (acc_scaled_down > MAX_OUT) begin
                y_out <= MAX_OUT; // saturate positive
            end else if (acc_scaled_down < MIN_OUT) begin
                y_out <= MIN_OUT; // saturate negative
            end else begin
                // value is within range so we gotta truncate to N bits
                y_out <= acc_scaled_down[N-1:0];
            end
            x2 <= x1;
            x1 <= x_in;
            y2_state <= y1_state;
            y1_state <= acc_scaled_down[N-1:0];
            $strobe("time=%t, x_in=%d, acc=%d, acc_scaled_down=%d, y_out=%d, y1_state=%d", $realtime, x_in, acc, acc_scaled_down, y_out, y1_state);
        end
    end
endmodule