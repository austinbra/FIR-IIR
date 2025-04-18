`timescale 1ns/1ps

module iir_tb;

    reg clk = 0;
    reg rst = 1;

    //in out data
    reg signed [15:0] x_in;
    wire signed [15:0] y_out;

    //coeffs
    reg signed [15:0] b0, b1, b2, a1, a2;

    //init iir
    iir_filter dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_out(y_out),
        .b0(b0), .b1(b1), .b2(b2),
        .a1(a1), .a2(a2)
    );

    // square wave ivnert after 5
    always #5 clk = ~clk;

    //file stuff
    integer infile, coefffile, outfile, i, r;
    reg signed [15:0] sample;

    initial begin
        //open files
        infile = $fopen("data/input_samples.txt", "r");
        coefffile = $fopen("data/iir_coeffs.txt", "r");
        outfile = $fopen("data/iir_output.txt", "w");

        if (outfile == 0) $display("❌ Failed to open output file");
        else              $display("✅ Opened output file successfully");


        // Read coefficients
        r = $fscanf(coefffile, "%d\n%d\n%d\n%d\n%d\n", b0, b1, b2, a1, a2);
        $display("Loaded coeffs: b0=%d b1=%d b2=%d a1=%d a2=%d", b0, b1, b2, a1, a2);
        $display("x_in=%d, y_out=%d, acc=%d", x_in, y_out, acc);


        // Deassert reset
        #20 rst = 0;

        // Feed input samples
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
