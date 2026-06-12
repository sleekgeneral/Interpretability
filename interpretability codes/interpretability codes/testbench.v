`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2025 13:02:46
// Design Name: 
// Module Name: class_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//number 0
module class_top_tb2;
    reg clk;
    reg rst;
    reg [17:0]model_params;
    reg [14:0]count = 0;
    reg [127:0] total_img;
    wire tready;
    integer j,r,fd;
    reg tvalid;
    reg [15:0]tkeep;
    reg stop;
    reg tlast;
    reg [3:0]label;
    reg [3:0]calc_label;
    reg [20:0] success;
    reg [20:0] fail;
    reg [127:0] total_img;   // 128-bit chunk sent to DUT
    reg [5:0]x;
    reg [2:0]   cycle_count; // 0..7 (8 cycles per image)
    integer  img_count;
    wire [3:0]output_params;
    
     initial clk = 0;
    always #5 clk = ~clk;
    integer img_count = 0;
    class_top
    uut
    (clk,rst,stop,total_img,model_params,x,output_params,tready);
    initial 
    begin    
        fd = $fopen("images.hex", "r");
        if (fd == 0) begin
            $display("ERROR: Could not open image file");
            $finish;
        end
        cycle_count = 0;
        tlast = 0;
        tkeep = 0;
        img_count   = 0;
        x = 1;
        count = 0;
        success = 0;
        stop = 0;
        fail = 0; 
        tvalid = 1;
        rst = 0;
        model_params = 18'b1010_10001100_001_111;
        #200
        rst = 1;
        stop = 1;
        #10
//number 0
       #10 total_img = 128'b11100110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
       #10 total_img = 128'b00000000001110000000011100000000000000011000000001100000000000000000111000111110000000000000000001111111110000000000000000000001;
       #10 total_img = 128'b00000000001110000000000001110000000000111000000000000111000000000011100000000000001100000000001110000000000000110000000001110000;
       #10 total_img = 128'b10000000000001110000000000011000000000000111000000000001100000000000011100000000000110000000000001110000000000011000000000000111;
       #10 total_img = 128'b00000111111111000000000000000000111111001110000000000000000111100000001100000000000000111100000000111000000000000011100000000001;
       #10 total_img = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111100000000000000000;
       #10 total_img = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
       #10 total_img = 128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
end

    always @(posedge tready) begin
        label = img_count / 108; // example label logic
        calc_label = output_params;
        if (label == calc_label)
            success = success + 1;
        else
            fail = fail + 1;

        // load next image (8 cycles)
        repeat (8) begin
            #10 load_next_chunk();
            x = x + 1;
        end
        #10
        x = 1;
    end

    // ----------------------------
    // Task: Load one 128-bit chunk
    // ----------------------------
    task load_next_chunk;
    begin
        // Read exactly 128 bits from file
        for (j = 0; j < 128; j = j + 1) begin
            r = $fgetc(fd);
            if (r == "0")
                total_img[127-j] = 1'b0;
            else if (r == "1")
                total_img[127-j] = 1'b1;
            else
                j = j - 1; // skip newline or junk
        end

        // Update cycle/image counters
        if (cycle_count == 7) begin
            cycle_count = 0;
            img_count   = img_count + 1;
        end
        else begin
            cycle_count = cycle_count + 1;
        end
    end
    endtask
        
endmodule
