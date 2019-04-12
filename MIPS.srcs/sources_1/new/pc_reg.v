`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: pc_reg
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
`include "defines.v"

module pc_reg(
    input wire rst,
    input wire clk,  
    input wire[5:0] stall, 
    input wire[`InstAddrBus] pc_branch,  
    output reg[`InstAddrBus] pc,
    output reg ce,
	output reg is_16op_o

    );
        // 指令存储器禁用的时候 PC值需要归零
	always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
			pc <= 8'h00000000;
			is_16op_o<=1'b0;

		end else if (stall[0] == `NoStop) begin
			is_16op_o <= is_16op_i;
		    if (branch_flag == `BranchValid ) begin
		           pc <= pc_branch;
		    end else begin
	 		       pc <= pc + 8'b1;
		    end
		end
	end
	
    // 复位的时候需要禁用指令存储器
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
            ce <= `ChipDisable;
			is_16op_o <= `Is8Inst;
        end 
        else begin
            ce<= `ChipEnable;
        end
	end
endmodule
