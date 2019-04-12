`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: id_ex
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

module id_ex(
	input wire				      clk,
	input wire					  rst,
    
    input wire[5:0]               stall,
	
	// ��ID�׶δ��ݹ�������Ϣ
	input wire[`AluOpBus]         id_aluop,
	input wire[`RegBus]           id_reg1,
	input wire[`RegBus]           id_reg2,
	input wire[`RegAddrBus]       id_wd,
	input wire                    id_wreg,	
	input wire                    id_mem_en,
	input wire                    id_mem_wr,
	
	// ��Ҫ���ݵ�EX�׶ε���Ϣ
	output reg[`AluOpBus]         ex_aluop,
	output reg[`RegBus]           ex_reg1,
	output reg[`RegBus]           ex_reg2,
	output reg[`RegAddrBus]       ex_wd,
	output reg                    ex_wreg,
	output reg                    ex_mem_en,
	output reg                    ex_mem_wr
    );
        // ������õĻ����������²��������Ϣ
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_mem_en <= `ChipDisable;
			ex_mem_wr <= `WriteDisable;
            // ��������õĻ�����ID�׶εĽ���͵�EX�׶�
		end else if (stall[2] == `Stop && stall[3] == `NoStop ) begin		
		    ex_aluop <= `EXE_NOP_OP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_mem_en <= `ChipDisable;
			ex_mem_wr <= `WriteDisable;
		end else if (stall[2] == `NoStop) begin
			ex_aluop <= id_aluop;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
			ex_mem_en <= id_mem_en;
			ex_mem_wr <= id_mem_wr;				
		end
	end
endmodule
