module fir_tb;
    reg clk = 0;
    reg rst = 1;

    //in out data
    reg signed [15:0] x_in;
    wire signed [31:0] y_out;
    reg signed [15:0] coeffs [0:15];

    //init fir
    fir_filter #(.N(16)) dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_out(y_out),
        .coeffs(coeffs)
    );
    //square wave of 5
    always #5 clk = ~clk;

    //file stuff
    integer infile, coefffile, outfile, r, i;
    reg signed [15:0] sample;

    initial begin
        infile = $fopen("data/input_samples.txt", "r");
        coefffile = $fopen("data/fir_coeffs.txt", "r");
        outfile = $fopen("data/fir_output.txt", "w");


        if (outfile == 0) begin
            $display("Failed to open output file");
        end
            
        else begin
            $display("Opened output file successfully");
        end

        for (i = 0; i < 16; i = i + 1)
            r = $fscanf(coefffile, "%d\n", coeffs[i]);

        #20 rst = 0;

        for (i = 0; i < 100; i = i + 1) begin
            r = $fscanf(infile, "%d\n", sample);
            x_in = sample;
            #10;
            $fwrite(outfile, "%d\n", y_out);
        end

        $fclose(infile);
        $fclose(coefffile);
        $fclose(outfile);
        $finish;
    end
endmodule