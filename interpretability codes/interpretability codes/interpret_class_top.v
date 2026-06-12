`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.05.2026 22:31:48
// Design Name: 
// Module Name: interpret_class_top
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


module interpret_class_top(
    input clk,
    input i_rst_n,
    input img_rst,
    input [1007:0]total_memory,
    input [3:0] calc_label,
    input label,
    output reg [31:0] value,
    input [10:0] address,
    input [3:0]class_no
    );
    integer file_handle;
reg signed [7:0] matrix1[783:0];
reg signed [7:0] matrix2[783:0];
reg signed [7:0] matrix3[783:0];
reg signed [7:0] matrix4[783:0];
reg signed [7:0] matrix5[783:0];
reg signed [7:0] matrix6[783:0];
reg signed [7:0] matrix7[783:0];
reg signed [7:0] matrix8[783:0];
reg signed [7:0] matrix9[783:0];
reg signed [7:0] matrix0[783:0];
integer i,j,k,n;

always @(posedge clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        value <= 32'd0;
    end
    else begin
        case (class_no)
            4'd0: value <= {matrix0[address+3], matrix0[address+2],
                            matrix0[address+1], matrix0[address]};

            4'd1: value <= {matrix1[address+3], matrix1[address+2],
                            matrix1[address+1], matrix1[address]};

            4'd2: value <= {matrix2[address+3], matrix2[address+2],
                            matrix2[address+1], matrix2[address]};

            4'd3: value <= {matrix3[address+3], matrix3[address+2],
                            matrix3[address+1], matrix3[address]};

            4'd4: value <= {matrix4[address+3], matrix4[address+2],
                            matrix4[address+1], matrix4[address]};

            4'd5: value <= {matrix5[address+3], matrix5[address+2],
                            matrix5[address+1], matrix5[address]};

            4'd6: value <= {matrix6[address+3], matrix6[address+2],
                            matrix6[address+1], matrix6[address]};

            4'd7: value <= {matrix7[address+3], matrix7[address+2],
                            matrix7[address+1], matrix7[address]};

            4'd8: value <= {matrix8[address+3], matrix8[address+2],
                            matrix8[address+1], matrix8[address]};

            4'd9: value <= {matrix9[address+3], matrix9[address+2],
                            matrix9[address+1], matrix9[address]};

            default: value <= 32'd0;
        endcase
    end
end

always @(posedge clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        for(i = 0; i < 784; i = i + 1)begin
            matrix0[i] = 0;
            matrix1[i] = 0;
            matrix2[i] = 0;
            matrix3[i] = 0;
            matrix4[i] = 0;
            matrix5[i] = 0;
            matrix6[i] = 0;
            matrix7[i] = 0;
            matrix8[i] = 0;
            matrix9[i] = 0;   
        end
    end
    else begin
         begin
            if((calc_label == label) && img_rst && label == 0)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix0[j] <= matrix0[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 1)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix1[j] <= matrix1[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 2)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix2[j] <= matrix2[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 3)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix3[j] <= matrix3[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 4)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix4[j] <= matrix4[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 5)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix5[j] <= matrix5[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 6)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix6[j] <= matrix6[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 7)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix7[j] <= matrix7[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 8)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix8[j] <= matrix8[j] +  {6'b00000,total_memory[j]};
                end
            end
            else if((calc_label == label) && img_rst && label == 9)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix9[j] <= matrix9[j] +  {6'b00000,total_memory[j]};
                end
            end
            
            else if((calc_label != label) && img_rst && label == 0)begin
                for(k = 0; k < 784; k = k + 1)begin
                    if(total_memory[k])
                    matrix0[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 1)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix1[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 2)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix2[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 3)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix3[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 4)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix4[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 5)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix5[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 6)begin
                for(j = 0; j < 784; j = j + 1)begin
                    matrix6[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 7)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix7[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 8)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix8[k] <= matrix0[k] + (-8'sd1);
                end
            end
            else if((calc_label != label) && img_rst && label == 9)begin
                for(j = 0; j < 784; j = j + 1)begin
                    if(total_memory[k])
                    matrix9[k] <= matrix0[k] + (-8'sd1);
                end
            end
        end
    end
end

//always @(posedge clk or negedge i_rst_n) begin
//    if (!i_rst_n) begin
//        file_handle = $fopen("matrix_output.txt", "w");
//    end
//    else begin
//        // Example trigger condition:
//        // Replace `final_done` with your actual completion signal
//        if (done_conv_long && pre_checkpoint == 10) begin
//         $fwrite(file_handle, "test = %0d\n", test);
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix0[%0d] = %0d\n", n, matrix0[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix1[%0d] = %0d\n", n, matrix1[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix2[%0d] = %0d\n", n, matrix2[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix3[%0d] = %0d\n", n, matrix3[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix4[%0d] = %0d\n", n, matrix4[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix5[%0d] = %0d\n", n, matrix5[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix6[%0d] = %0d\n", n, matrix6[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix7[%0d] = %0d\n", n, matrix7[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix8[%0d] = %0d\n", n, matrix8[n]);
//            end
//            for (n = 0; n < 784; n = n + 1) begin
//                $fwrite(file_handle, "matrix9[%0d] = %0d\n", n, matrix9[n]);
//            end
//            $fclose(file_handle);
//        end
//    end
//end

endmodule
