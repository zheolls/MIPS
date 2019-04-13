`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: mem
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

module mem(
	input wire					  rst,
	
	// 来自执行阶段的消息?
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
    input wire[`RegBus]			  wdata_i,
	input wire                    mem_en_i,
    input wire                    mem_we_i,
    input wire[`InstAddrBus]      mem_addr_i,
	
	//访存
	input wire[`RegBus]       mem_read_data,
	output reg                 mem_ce_o,
	output reg                 mem_we_o,
	output reg[`InstAddrBus] mem_addr_o,
	output reg[`RegBus]       mem_data_o,
	
	// 访存阶段的结果
    output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
    output reg[`RegBus]			  wdata_o
    );
    	// 如果重置则清除结果
	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
		  	wdata_o <= `ZeroWord;
			mem_ce_o <= `ChipDisable;
		  	mem_we_o <= `WriteDisable;
		  	mem_addr_o <= `NOPRegAddr;
		  	mem_data_o <= `ZeroWord;
            // 否则因为ORI在此阶段不需要做任何事情，所以直接传给下个阶段?
		end else begin
		  	wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			mem_ce_o <= mem_en_o_i;
			mem_we_o <= mem_we_o_i;
			mem_addr_o <= mem_addr_o_i;
			if(mem_en_i)begin
			    if(mem_we_i)begin
			          mem_data_o<=wdata_i;
			    end else begin
			         wdata_o<=mem_read_data;
			    end
			end
		end    //if
	end      //always
endmodule
