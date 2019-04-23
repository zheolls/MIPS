`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: ex
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

module ex(
	input wire					  rst,
	input wire[`AluOpBus]         aluop_i,
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
	input wire                     mem_ce_i,
	input wire                     mem_we_i,


	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
    output reg[`RegBus]			  wdata_o,
	output reg                      mem_ce_o,
    output reg                      mem_we_o,
	output reg[`InstAddrBus]      mem_addr_o,
    output reg stallreq
    );

	reg[`RegBus] logicout;
    

	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
			wd_o<= `WriteEnable;
			wreg_o<= `WriteEnable;
			mem_ce_o<= `ChipEnable;
			mem_we_o<= `WriteEnable;
			mem_addr_o<= `NOPRegAddr;
			wdata_o<= `ZeroWord;
			stallreq<=`NoStop;
		end else begin
			mem_addr_o <= `NOPRegAddr;
			wdata_o <= `ZeroWord;
            wd_o <= wd_i;          
            wreg_o <= wreg_i;
            mem_ce_o<=mem_ce_i;
            mem_we_o<=mem_we_i;
			case (aluop_i)
                `EXE_OR_OP:	begin
					wdata_o <= reg1_i | reg2_i;
				end
				`ALU_ADD:begin
				    wdata_o <=reg1_i+reg2_i;
				end
				`ALU_MOV:begin
				    wdata_o<=reg1_i;
				end
				`ALU_LOAD:begin
				    mem_addr_o<=reg1_i;
				end
				`ALU_STORE:begin
				    mem_addr_o<=reg2_i;
				    wdata_o<=reg1_i;
				end
				default: begin
					wdata_o <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

endmodule
