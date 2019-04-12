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
	// 从译码阶段送过来的信息
	input wire[`AluOpBus]         aluop_i,
//	input wire[`AluSelBus]        alusel_i,
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,
	input wire                     mem_en_i,
	input wire                     mem_wr_i,


	// 执行的结果
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
    output reg[`RegBus]			  wdata_o,
	output reg                      mem_en_o,
    output reg                      mem_wr_o,
	output reg[`InstAddrBus]      mem_addr_o,
    output reg stallreq
    );
        // 保存逻辑运算的结果
	reg[`RegBus] logicout;
    
    // 组合逻辑：根据运算子类型进行运算，此处只有"或运算"
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
			wd_o<= `WriteEnable;
			wreg_o<= `WriteEnable;
			mem_en_o<= `ChipEnble;
			mem_wr_o<= `WriteEnable;
			mem_addr_o<= `NOPRegAddr;
			wdata_o<= `ZeroWord;
		end else begin
		 // 需要写入的寄存器的地址
            wd_o <= wd_i;          
            // 寄存器写使能
            wreg_o <= wreg_i;
            //主存写使能
            mem_en_o<=mem_en_i;
            //主存读\写信号
            mem_wr_o<=mem_wr_i;
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
				    mem_addr_o<=reg1_i;
				    wdata_o<=reg2_i;
				end
				default: begin
					wdata_o <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

 end	
endmodule
