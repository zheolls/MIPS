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
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,

	// 执行的结果
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
    output reg[`RegBus]			  wdata_o,
    output reg stallreq
    );
        // 保存逻辑运算的结果
	reg[`RegBus] logicout;
    
    // 组合逻辑：根据运算子类型进行运算，此处只有"或运算"
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
                `EXE_OR_OP:	begin
					logicout <= reg1_i | reg2_i;
				end
				default: begin
					logicout <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always


    // 组合逻辑: 根据主运算类型选择一个选择一个运算结果最为最终结果输出
 always @ (*) begin
     // 需要写入的寄存器的地址
	 wd_o <= wd_i;	 	 
     // 寄存器写使能
	 wreg_o <= wreg_i;
     // 根据主运算类型选择一个选择一个运算结果最为最终结果输出

 end	
endmodule
