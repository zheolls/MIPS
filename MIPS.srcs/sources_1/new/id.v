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
	input wire                    is_16op_i, 

	// 输出到REGFILE的信息，包括读端口1和2的读使能信号以及读地址信号
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	//送到IF的分支flag和分支地址
	output reg                    branch_flag,
	output reg[`InstAddrBus]      branch_addr,
	
	// 送到EX阶段的信息
    output reg[`AluOpBus]         aluop_o,  // ALU操作码
    //output reg[`AluSelBus]        alusel_o, // ALU子操作码
    output reg[`RegBus]           reg1_o,   // 源操作数 1
    output reg[`RegBus]           reg2_o,   // 源操作数 2
    output reg[`RegAddrBus]       wd_o,     // 要写入的寄存器的地址
	output reg                    wreg_o ,   // 写使能信号
	output reg                     mem_en_o,   //读写写主存使能信号
	output reg                     mem_wr_o,    //读写主存信号，高电平写，低电平读
	output reg is_16op,          //是否是16位指令
	output reg stallreq
    );
    
        // 取得指令的指令码、功能码等；
  wire[3:0] op = inst_i[7:4]; 
  wire[4:0] rs = inst_i[3:2];
  wire[5:0] rd = inst_i[1:0];
    // 保存指令执行需要的立即数
  reg[`RegBus]	imm;
    // 指令是否有效
  reg instvalid;
  
  reg[3:0] op16code;    //16位指令的操作码
  reg[`RegAddrBus]  op16_addr_rd;   //load指令目的寄存器地址
  reg[`RegBus]       op16_addr_rs;  //store指令源寄存器地址
  
  
 
    // 译码阶段，组合逻辑
    //   如果重置则进行以下操作
	always @ (*) begin	
        if (rst == `RstEnable) begin
            branch_flag<= `BranchInvalid;
            branch_addr<=`ZeroWord;
            aluop_o <= `EXE_NOP_OP;
//			alusel_o <= `EXE_RES_NOP;
            wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
            instvalid <= `InstValid;
			reg1_read_o <= `ReadDisable;
			reg2_read_o <= `ReadDisable;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= `ZeroWord;
			op16_addr_rd <= `NOPRegAddr;
			op16_addr_rs <= `NOPRegAddr;
			mem_en_o <= `ChipDisable;
			mem_wr_o <= `WriteDisable;
			is_16op <= `Is16Inst;
			op16code <= `NOP_16OP;

     // 如果不重置则进行以下操作
	  end else if(is_16op_i== `Is8Inst) begin
	       branch_flag <= `BranchInvalid;
           branch_addr <= `NOPRegAddr;
		   op16_addr_rd <= `NOPRegAddr;
           op16_addr_rs <= `NOPRegAddr;
		   aluop_o <= `EXE_NOP_OP;
 //          alusel_o <= `EXE_RES_NOP;
           wreg_o <= `WriteDisable;
           instvalid <= `InstInvalid;       
           reg1_read_o <= `ReadDisable;
           reg2_read_o <= `ReadDisable;
           reg1_addr_o <= `ARegAddr;
           reg2_addr_o <= `BRegAddr;        
           imm <= `ZeroWord;
		   mem_en_o <= `ChipEnable;
           mem_wr_o <= `WriteEnable;
           is_16op <= `Is16Inst;           	       
	       case(op16code)   //for 16-bit inst addr
	           `ALU_JMP: begin
					   branch_flag <= `BranchInvalid;
					   branch_addr <= inst_i;           
					end
	           `ALU_LOAD:begin
		  	       aluop_o <= `ALU_LOAD;
//                   alusel_o<=`EXE_RES_LOGIC;
                   reg1_o <= inst_i;  //LOAD指令的源数据在内存的地址
                   wd_o <= op16_addr_rd;
                   wreg_o <= `WriteEnable;
                   instvalid <=`InstValid;
                   mem_en_o <= `ChipEnable;
                   mem_wr_o <= `WriteDisable;
	           end
	           `ALU_STORE:begin
		  	       aluop_o <= `ALU_STORE;
  //                 alusel_o<=`EXE_RES_LOGIC;
                   reg1_o <= inst_i;  //STORE指令的源数据在内存的地址
                   reg2_read_o <= `ReadEnable;
                   reg2_addr_o <= op16_addr_rs;
                   instvalid <= `InstValid;
                   mem_en_o <= `ChipEnable;
                   mem_wr_o <= `WriteEnable;
	           end
	       endcase
	  end else   begin
          // 这里其实是default里面的值
          //   我们先看下面的case
            branch_flag <= `BranchInvalid;
            branch_addr <= `NOPRegAddr;
			op16_addr_rd <= `NOPRegAddr;
            op16_addr_rs <= `NOPRegAddr;
			aluop_o <= `EXE_NOP_OP;
//			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[1:0];
			wreg_o <= `WriteDisable;
            instvalid <= `InstInvalid;	   
			reg1_read_o <= `ReadDisable;
			reg2_read_o <= `ReadDisable;
			reg1_addr_o <= `ARegAddr;
			reg2_addr_o <= `BRegAddr;		
			imm <= `ZeroWord;	
		    op16code <= `NOP_16OP;
			mem_en_o <= `ChipDisable;
            mem_wr_o <= `WriteDisable;
            is_16op <= `Is16Inst;
		  case (op)
		  	`EXE_MOV:			
				begin
					aluop_o <= `ALU_MOV;
	  //              alusel_o<=`EXE_RES_LOGIC;
					reg1_read_o <=  `ReadEnable;
					wd_o <= inst_i[1:0];
					wreg_o <= `WriteEnable;
					instvalid <= `InstValid;
				end 	
		  	
		  	`EXE_ADD:
				begin
				   aluop_o <= `ALU_ADD;
	//		  	   alusel_o<=`EXE_RES_LOGIC;
				   reg1_read_o <= `ReadEnable;
				   reg2_read_o <= `ReadEnable;
				   wd_o <= inst_i[1:0];
				   wreg_o <= `WriteEnable;
				   instvalid <= `InstValid;
				end
		  	
		  	`EXE_JMP:
				begin
				   op16code <= `ALU_JMP;
				   is_16op <= `Is8Inst;
				end
		  	
		  	`EXE_LOAD:
				begin
				   op16code <= `ALU_LOAD;
				   is_16op <= Is8Inst;
				   op16_addr_rd <= inst_i[1:0];
				end
		  	
		  	`EXE_STORE:
				begin
				   op16code <= `ALU_STORE;
				   is_16op <= `Is8Inst;
				   op16_addr_rs <= inst_i[3:2];
				end				
		  			 
		    `EXE_ORI:			
				begin
					wreg_o <= `WriteEnable; // 写使能
					aluop_o <= `EXE_OR_OP;
	//		  		alusel_o <= `EXE_RES_LOGIC; 
					reg1_read_o <= `ReadEnable;	// 读 rs
					reg2_read_o <= `ReadDisable;	// 不读 rt  	
	//               imm <= {16'h0, inst_i[15:0]};	// 立即数无符号扩展	
					wd_o <= inst_i[1:0];  // 写寄存器地址位 rt
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
        end else if(reg1_read_o == `ReadEnable) begin
            reg1_o <= reg1_data_i;
            // 若没有 读使能，则把立即数作为数据输出为 操作数1
        end else if(reg1_read_o == `ReadDisable) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
	
    // 确定运算的操作数2
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
        end else if(reg2_read_o == `ReadEnable) begin
            reg2_o <= reg2_data_i;
            // 若没有 读使能，则把立即数作为数据输出为 操作数1
        end else if(reg2_read_o == `ReadDisable) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
endmodule
