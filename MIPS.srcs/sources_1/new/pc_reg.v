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
    input rst,
    input clk,
    input wire[5:0] stall,
    input wire branch_flag,
    input wire[`InstAddrBus] pc_branch,  
    output reg[`InstAddrBus] pc,
    output reg ce
    );
        // 指令存储器禁用的时候 PC值需要归零
	always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
			pc <= 8'b0;
		end else if(stall[0]==`NoStop) begin
		      if(branch_flag)begin
		           pc<=pc_branch;
		      end else begin
	 		       pc <= pc + 8'b1;
		      end
		end
	end
	
    // 复位的时候需要禁用指令存储器
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end 
        else begin
            ce<= `ChipEnable;
        end
	end
endmodule
