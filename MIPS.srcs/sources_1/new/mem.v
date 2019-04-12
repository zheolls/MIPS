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
	
	// ����ִ�н׶ε���Ϣ
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
    input wire[`RegBus]			  wdata_i,
	input wire                    mem_en_i,
    input wire                    mem_wr_i,
    input wire[`InstAddrBus]      mem_addr_i,
	
	//�ô�
	input wire[`RegBus]       mem_read_data,
	output reg                 mem_en,
	output reg                 mem_wr,
	output reg[`InstAddrBus] mem_addr,
	output reg[`RegBus]       mem_write_data,
	
	// �ô�׶εĽ��
    output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
    output reg[`RegBus]			  wdata_o
    );
    	// ���������������
	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
		  	wdata_o <= `ZeroWord;
			mem_en <= `ChiDisable;
		  	mem_wr <= `WriteDisable;
		  	mem_addr <= `NOPRegAddr;
		  	mem_write_data <= `ZeroWord;
            // ������ΪORI�ڴ˽׶β���Ҫ���κ����飬����ֱ���͸��¸��׶Σ�WB��
		end else begin
		  	wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			mem_en <= mem_en_i;
			mem_wr <= mem_wr_i;
			mem_addr <= mem_addr_i;
			if(mem_en_i)begin
			    if(mem_wr_i)begin
			          mem_write_data<=wdata_i;
			    end else begin
			         wdata_o<=mem_read_data;
			    end
			end
		end    //if
	end      //always
endmodule
