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
	
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
    input wire[`RegBus]			  wdata_i,
	input wire                    mem_ce,
    input wire                    mem_we,
    input wire[`InstAddrBus]      mem_addr_i,
	
	//访存
	input wire[`RegBus]       mem_read_data,

	
	output reg                 mem_ce_o,
	output reg                 mem_we_o,
	output reg[`InstAddrBus] mem_addr_o,
	output reg[`RegBus]       mem_data_o,
	
    output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
    output reg[`RegBus]			  wdata_o
    );

	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
		  	wdata_o <= `ZeroWord;
			mem_ce_o <= `ChipDisable;
		  	mem_we_o <= `WriteDisable;
		  	mem_addr_o <= `NOPRegAddr;
		  	mem_data_o <= `ZeroWord;

		end else begin
		  	wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			mem_ce_o <= mem_ce;
			mem_we_o <= mem_we;
            if (mem_ce == `ChipEnable && mem_we == `WriteEnable ) begin
                mem_data_o <= wdata_i;   
                mem_addr_o <= mem_addr_i;
            end else if (mem_ce == `ChipEnable ) begin
                wdata_o<=mem_read_data;
                mem_addr_o <= mem_addr_i;
                mem_data_o <= `ZeroWord;
            end else
            begin
                mem_data_o <= `ZeroWord;
                mem_addr_o <= `NOPRegAddr;
            end
		end    //if
	end      //always
endmodule
