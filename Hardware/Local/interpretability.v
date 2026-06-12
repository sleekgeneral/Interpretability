`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2026 04:21:41 PM
// Design Name: 
// Module Name: interpretability
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


module interpretability(
    input clk,
    input rst,
    input [1007:0]total_memory,
    input clause_op,
    input [48:0]neg_rule,
    input conv_enable,
    input [15:0] ypos,
    input [5:0] xpos,
    input ymatch,
    input xmatch,
    output reg signed [783:0]matrix
    );
    integer i,j,k;
always@(posedge clk)begin
    if(!rst) begin
        for(k = 0;k < 784;k = k + 1)
            matrix[k] = 1'b0;        
    end
    else if(clause_op)begin
        for (j = 0;j < 7;j = j + 1)begin
        	for (i = 0;i < 7;i = i + 1)
            		matrix[(ypos + j)*28 + (xpos + i)] = total_memory[(ypos + j)*28 + (xpos + i)];
        end
    end
end
    
endmodule
