
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 27.05.2026 19:35:24
// Design Name:
// Module Name: global
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
module global #
(
    parameter N        = 28,
    parameter M        = 28,
    parameter PATCH_H  = 7,
    parameter PATCH_W  = 7,
    parameter CLAUSEN  = 152,
    parameter F        = 49,
    parameter K        = 42,
    parameter CLAUSE_BITS = 182,
    parameter WEIGHT_W = 16
)
(
    input wire clk,
    input wire rst,
    input [1:0] kselect,
    input wire [9:0]address,
    input wire [3:0]class_no,
    output reg [31:0] value,
    output wire done
);
    localparam BX = N - PATCH_W;
    localparam BY = M - PATCH_H;

    integer i;
    reg [F-1:0] L_pos;
    reg [F-1:0] L_neg;
    wire start;
    reg signed [15:0] matrix[783:0];

    reg [8:0]clause_addr;
    reg [181:0]clause_bits;
    wire [255:0]mnist_clause_write;
    wire [255:0]emnist_clause_write;
    wire signed [8:0] weight;
     
   
    wire mnist,emnist;
    reg [11:0] weight_addr;
    reg signed [15:0] max = -1000;
    reg [3:0]class_number_delay;
    reg [3:0]class_number_delay2;
    reg [2:0]counter;
   
    wire class_done;
    wire class_change;
    wire clause_check;
    wire test;
    wire weight_check;
    assign weight_check_emnist = ((weight_addr+1)%304 == 0);
    assign weight_check_mnist = ((weight_addr+1)%152 == 0) && !weight_check_emnist;
    assign start = kselect[1];
    assign clause_check = (clause_addr == 151);
    assign done = (clause_check) && ((weight_check_emnist && emnist) || (weight_check_mnist && mnist));
    assign class_change = (class_number_delay2 != class_no);
    assign mnist = kselect[0];
    assign emnist = !kselect[0];
   
    blk_mem_gen_0 mnist_clauses_inp(
    .clka(clk),
    .ena(mnist),
    .wea(1'b0),
    .addra(clause_addr),
    .dina(255'b0),
    .douta(mnist_clause_write));

    blk_mem_gen_1 weights_inp0(
    .clka(clk),
    .ena(1'b1),
    .wea(1'b0),
    .addra(weight_addr),
    .dina(255'b0),
    .douta(weight));

    blk_mem_gen_2 emnist_clauses_inp(
    .clka(clk),
    .ena(emnist),
    .wea(1'b0),
    .addra(clause_addr),
    .dina(255'b0),
    .douta(emnist_clause_write));

    integer j;
    reg [BY-1:0] y_bits_pos;
    reg [BX-1:0] x_bits_pos;
    reg [BY-1:0] y_bits_neg;
    reg [BX-1:0] x_bits_neg;
    integer x_idx_pos;
    integer y_idx_pos;
    integer x_idx_neg;
    integer y_idx_neg;
    integer x_min;
    reg [9:0]id;
    reg [2:0]it;
    reg added;
    integer y_min;
    integer file_id;
    reg write_done;
    initial begin
        file_id = $fopen("matrices.txt", "w");
    end
    always @(posedge clk)begin
        if(!rst)begin
            clause_addr <= 0;
            counter <= 0;
            class_number_delay <= 0;
            class_number_delay2 <= 0;
            clause_bits <= 0;
            weight_addr <= 0;
            added <= 0;
        end
        else begin
        if(!start)begin
            clause_addr <= 0;
            counter <= 0;
            clause_bits <= 0;
            added <= 0;
            weight_addr <= 0;
        end
        else if(class_change) begin
            clause_addr <= -1;
            counter <= 0;
            write_done <= 0;
            clause_bits <= 0;
            weight_addr <= weight_addr + 76;
        end
        else begin
            if(!done) begin
                counter <= counter + 1;
                if(counter == 2)begin
                    clause_addr <= clause_addr + 1'b1;
                    weight_addr <= weight_addr + 1'b1;
              
                end
                if(counter == 6)begin
                    counter <= 0;
                end
                if(emnist & !added)begin
                    weight_addr <= weight_addr + CLAUSEN;
                    added <= 1;
                end    
            end
            else begin
                clause_addr <= clause_addr;
                weight_addr <= weight_addr;
                end
            end
            end
            clause_bits <= mnist ?  mnist_clause_write : emnist_clause_write;
            class_number_delay <= class_no;
            class_number_delay2 <= class_number_delay;
        end
      always @(posedge clk)begin
      if(!rst)
        begin
            value <= 0;
            write_done <= 0;
        end
        else begin
        if(start && done)begin
            value <= {matrix[address+1],matrix[address]};
            end
            end
      end
//    always @(posedge clk) begin
//      if (done && !write_done) begin
//            file_id = $fopen("matrices.txt", "a");
//            for (i = 0; i < 784; i = i + 1) begin
//                  $fwrite(file_id, "matrix[%0d][%0d] = %0d\n",class_no,i,matrix[i]);
//            end
//            $fclose(file_id);
//            write_done <= 1'b1;
//        end
//    end
    always @(posedge clk)
    begin
        if(!rst)
        begin
            for ( i = 0 ; i < 784 ; i = i + 1 ) begin
                matrix[i] <= 0;
            end    
            it <= 0;  
           
            L_pos <= 0;
            L_neg <= 0;    
            x_bits_pos <= 0;
            y_bits_neg <= 0;
            x_bits_neg <= 0;
            x_idx_pos = 0;
            y_idx_pos = 0;
        end
        else
        begin
            if(start)
            begin
                if(!done)
                begin
                    if(class_change)begin
                        for ( i = 0 ; i < 784 ; i = i + 1 ) begin
                            matrix[i] <= 0;
                        end 
                    end
                    else begin
                        L_pos     <= clause_bits[90:42];
                        L_neg     <= clause_bits[181:133];
                        y_bits_pos <= clause_bits[20:0];
                        x_bits_pos <= clause_bits[41:21];
                        y_bits_neg <= clause_bits[111:91];
                        x_bits_neg <= clause_bits[132:112];
                        x_idx_pos = -1;
                        y_idx_pos = -1;
                        for(i = 0; i < BX; i = i + 1)
                        begin
                            if(x_bits_pos[i])
                                x_idx_pos = i;
                        end
                        for(i = 0; i < BY; i = i + 1)
                        begin
                            if(y_bits_pos[i])
                                y_idx_pos = i;
                        end
                        x_idx_neg = BX;
                        y_idx_neg = BY;
                        for(i = 0; i < BX; i = i + 1)
                        begin
                            if(x_bits_neg[i] && x_idx_neg == BX)
                                x_idx_neg = i;
                        end
                        for(i = 0; i < BY; i = i + 1)
                        begin
                            if(y_bits_neg[i] && y_idx_neg == BY)
                                y_idx_neg = i;
                        end
                        if(x_idx_pos == -1)
                            x_min = 0;
                        else
                            x_min = x_idx_pos + 1;
   
                        if(y_idx_pos == -1)
                            y_min = 0;
                        else
                            y_min = y_idx_pos + 1'b1;
                        
                        for (j = 0;j < 7;j = j + 1)begin
                                id = ((y_min + y_idx_neg)/2 + j) * 28 + (x_min + x_idx_neg)/2 + it;
                                if(weight > 0)begin
                                   matrix[id] <= matrix[id] +(L_pos[j*7+it] ? weight : 0) - (L_neg[j*7+it] ? weight : 0);
                                end
                        end
                        it <= it + 1;
                        if(it == 6)begin
                            it <= 0;
                        end
                    end
                end
            end
        end
    end
endmodule
	
