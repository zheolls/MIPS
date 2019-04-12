`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: id
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

module id(
	input wire					  rst,
    input wire[`InstAddrBus]	  pc_i,
	input wire[`InstBus]          inst_i,

    // 读取的REGFILE的值
	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,

	// 输出到REGFILE的信息，包括读端口1和2的读使能信号以及读地址信号
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	// 送到EX阶段的信息
    output reg[`AluOpBus]         aluop_o,  // ALU操作码
    //output reg[`AluSelBus]        alusel_o, // ALU子操作码
    output reg[`RegBus]           reg1_o,   // 源操作数 1
    output reg[`RegBus]           reg2_o,   // 源操作数 2
    output reg[`RegAddrBus]       wd_o,     // 要写入的寄存器的地址
	output reg                    wreg_o ,   // 写使能信号
	output reg stallreq
    );
    
        // 取得指令的指令码、功能码等；
  wire[5:0] op = inst_i[31:26]; //对于ORI指令只需要判断 26-31bit 的值即可判断
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];
  wire[4:0] op4 = inst_i[20:16];
    // 保存指令执行需要的立即数
  reg[`RegBus]	imm;
    // 指令是否有效
  reg instvalid;
  
  
 
    // 译码阶段，组合逻辑
    //   如果重置则进行以下操作
	always @ (*) begin	
        if (rst == `RstEnable) begin
            aluop_o <= `EXE_NOP_OP;
//			alusel_o <= `EXE_RES_NOP;
            wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
            instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 8'h0;
     // 如果不重置则进行以下操作
	  end else begin
          // 这里其实是default里面的值
          //   我们先看下面的case
			aluop_o <= `EXE_NOP_OP;
//			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
            instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			imm <= `ZeroWord;			
		  case (op)
		  	`EXE_MOV:			
            begin

		  	end 	
		  	
		  	`EXE_ADD:
		  	begin
		  	end
		  	
		  	`EXE_JMP:
		  	begin
		  	end
		  	
		  	`EXE_LOAD:
		  	begin
		  	end
		  	
		  	`EXE_STORE:
		  	begin
		  	end				
		  			 
		    `EXE_ORI:			
            begin
		  		wreg_o <= `WriteEnable; // 写使能
                aluop_o <= `EXE_OR_OP;
//		  		alusel_o <= `EXE_RES_LOGIC; 
                reg1_read_o <= 1'b1;	// 读 rs
                reg2_read_o <= 1'b0;	// 不读 rt  	
                imm <= {16'h0, inst_i[15:0]};	// 立即数无符号扩展	
                wd_o <= inst_i[20:16];  // 写寄存器地址位 rt
				instvalid <= `InstValid;	
		  	end 							 
            default:
                // 在上面已经给出
                begin 
                end
		  endcase
		end
	end
	

    // 确定运算的操作数1
	always @ (*) begin
        if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
        end else if(reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
            // 若没有 读使能，则把立即数作为数据输出为 操作数1
        end else if(reg1_read_o == 1'b0) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
	
    // 确定运算的操作数2
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
        end else if(reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
            // 若没有 读使能，则把立即数作为数据输出为 操作数1
        end else if(reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
endmodule
