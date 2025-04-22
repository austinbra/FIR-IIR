`timescale 1ns/1ps

module iir_tb;

    reg clk = 0;
    reg rst = 1;

    //in out data
    reg signed [15:0] x_in;
    wire signed [15:0] y_out;

    //coeffs - Use 32-bit to match DUT ports
    reg signed [31:0] b0, b1, b2, a1, a2;

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
        //open files ONCE
        infile = $fopen("data/input_samples.txt", "r");
        coefffile = $fopen("data/iir_coeffs.txt", "r"); // open coefficient file
        outfile = $fopen("data/iir_output.txt", "w");


        $monitor("Monitor time=%t, clk=%b", $time, clk);

        // check file opens
        if (coefffile == 0) begin
            $display("Failed to open data/iir_coeffs.txt!");
            $finish;
        end else begin
            $display("Opened coefficient file successfully (Descriptor: %d)", coefffile);
        end
        if (infile == 0) $display("Failed to open input file");
        if (outfile == 0) $display("Failed to open output file");
        else              $display("Opened output file successfully");


        // read coefficients
        r = $fscanf(coefffile, "%d\n%d\n%d\n%d\n%d\n", b0, b1, b2, a1, a2);

        // Check fscanf correctness
        if (r != 5) begin
             $display("FATAL: fscanf failed! Read %d items instead of 5.", r);
             $display("Current values: b0=%d b1=%d b2=%d a1=%d a2=%d", b0, b1, b2, a1, a2);
             $finish;
        end else begin
             $display("fscanf read 5 items successfully.");
        end

        //displayed values after good read confirmed
        $display("Loaded coeffs: b0=%d b1=%d b2=%d a1=%d a2=%d", $signed(b0), $signed(b1), $signed(b2), $signed(a1), $signed(a2));
        $display("Initial x_in=%d, y_out=%d", x_in, y_out);

        $fclose(coefffile);

        // deassert reset
        #20 rst = 0;

        // input samples
        for (i = 0; i < 100; i = i + 1) begin
            r = $fscanf(infile, "%d\n", sample);
             if (r != 1) begin // check for fscanf success
               $display("Error reading input sample at index %d", i);
               $finish;
            end
            x_in = sample;
            #10;
            $fwrite(outfile, "%d\n", y_out);
        end

        $fclose(infile);
        $fclose(outfile);
        $finish;
    end

endmodule
