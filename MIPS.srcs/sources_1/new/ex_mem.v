`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: ex_mem
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

module ex_mem(
	input	wire				  clk,
	input wire					  rst,
    input wire[5:0]              stall,

	
	// 来自执行阶段的信息
	input wire[`RegAddrBus]       ex_wd,
	input wire                    ex_wreg,
    input wire[`RegBus]		      ex_wdata, 	
	
	// 送到访存阶段的信息
    output reg[`RegAddrBus]       mem_wd,
	output reg                    mem_wreg,
    output reg[`RegBus]			  mem_wdata
    );
        // 时序逻辑
	always @ (posedge clk) begin
        // 如果重置的话，清除信息
		if(rst == `RstEnable) begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
		    mem_wdata <= `ZeroWord;	
            // 不重置的话，把信息传递到MEM阶段
		end else if (stall[3] == `Stop && stall[4] == `NoStop ) begin
		    mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
		    mem_wdata <= `ZeroWord;	
		end else if (stall[3] == `NoStop ) begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;			
		end    //if
	end      //always
endmodule
