`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: mem_wb
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

module mem_wb(

	input	wire				  clk,
	input wire					  rst,
    input wire[5:0]               stall,


	// ���Էô�׶ε���Ϣ
	input wire[`RegAddrBus]       mem_wd,
	input wire                    mem_wreg,
    input wire[`RegBus]			  mem_wdata,

	// ��Ҫ���ݸ�д�ؽ׶ε���Ϣ
    output reg[`RegAddrBus]       wb_wd,
	output reg                    wb_wreg,
    output reg[`RegBus]			  wb_wdata	       
	
);


    // ������õĻ��������Ϣ�����򴫵ݸ�д�ؽ׶�
	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
		  	wb_wdata <= `ZeroWord;	
		end else if (stall[4] == `Stop && stall[5] == `NoStop ) begin
			wb_wd <= `NOPRegAddr;
			wb_wreg <= `WriteDisable;
		  	wb_wdata <= `ZeroWord;	
		end else if (stall[4] == `NoStop ) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
		end    //if
	end      //always
			

endmodule
