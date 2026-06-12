`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.05.2026 20:09:44
// Design Name: 
// Module Name: testbench
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


module testbench;
    reg clk;
    reg rst;
    reg [1:0] select;
    reg [11:0]address;
    reg [3:0]class_no;
    wire [31:0] value;
    wire done;
    
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        rst = 0;
        address = 0;
        select = 0;
        class_no = 0;
        #200
        rst = 1;
        select = 2'b10;
        #121750 
        forever #10 address = address + 1;
    end
   always @(posedge done) begin
        #100;
        class_no = (class_no != 10)? class_no + 1 : 9;
    end
global
    uut
    (clk,rst,select,address,class_no,value,done);

endmodule
