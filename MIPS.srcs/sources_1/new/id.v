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
	input wire                    clk,
	input wire					  rst,
    input wire[`InstAddrBus]	  pc_i,
	input wire[`InstBus]          inst_i,


	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,


	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	

	output reg                    branch_flag,
	output reg[`InstAddrBus]      branch_addr,
	
	//处于执行阶段的指令的运算结果
	input wire     				  ex_wreg_i,
	input wire[`RegBus]			  ex_wdata_i,
	input wire[`RegAddrBus]       ex_wd_i,
	//处于访存阶段的指令的运算结果
	input wire                    mem_wreg_i,
	input wire[`RegBus]           mem_wdata_i,
	input wire[`RegAddrBus]       mem_wd_i,
	

    output reg[`AluOpBus]         aluop_o,  
    output reg[`RegBus]           reg1_o,   // 源操作数 1
    output reg[`RegBus]           reg2_o,   // 源操作数 2
    output reg[`RegAddrBus]       wd_o,     // 要写入的寄存器的地址
	output reg                    wreg_o ,   
	output reg                     mem_ce_o,   //读写写主存使能信号?
	output reg                     mem_we_o,    //读写主存信号，高电平写，低电平读
	output reg stallreq
    );
    
			// 取得指令的指令码、功能码等；
	wire[3:0] op = inst_i[7:4]; 
	wire[4:0] rs = inst_i[3:2];
	wire[5:0] rd = inst_i[1:0];
		
	reg[`RegBus]	imm;
		// 指令是否有效
	reg instvalid;
	  
	reg[7:0] op16;    //16位指令前八位
	reg[7:0] op16_reg;  //存储16位指令前八位的寄存器
	wire[3:0] op16_code=op16_reg[7:4]; 
	wire[`RegAddrBus]       op16_addr_rd={6'b0,op16_reg[1:0]};   
	wire[`RegAddrBus]       op16_addr_rs={6'b0,op16_reg[3:2]};  
  
	reg stallreq_reg;
	reg[1:0] nowrd;

    reg[3:0]        reg_state[3:0];
    reg[3:0]        reg_state_reg[3:0]; 
        
        //reg_state表的维护
    always @(posedge clk)begin
        reg_state_reg[4'h0]<= reg_state[4'h0]>>1;
        reg_state_reg[4'h1]<= reg_state[4'h1]>>1;
        reg_state_reg[4'h2]<= reg_state[4'h2]>>1;
        reg_state_reg[4'h3]<= reg_state[4'h3]>>1;
    end
     


     // 如果不重置则进行以下操作
	always @ (*) begin	
      if ( rst == `RstEnable )
             begin
                branch_flag <= `BranchInvalid;
                branch_addr <= `NOPRegAddr;
                aluop_o <= `EXE_NOP_OP;
                wd_o <= `NOPRegAddr;
                wreg_o <= `WriteDisable;
                instvalid <= `InstValid;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                reg1_addr_o <= `NOPRegAddr;
                reg2_addr_o <= `NOPRegAddr;
                imm <= `ZeroWord;
                mem_ce_o <= `ChipDisable;
                mem_we_o <= `WriteDisable;;
                op16 <= `NOP_16OP;
                reg1_o <= `NOPRegAddr;
                reg2_o <= `NOPRegAddr;
                stallreq<=`NoStop;
                reg_state[4'h0] <= 4'b0;
                reg_state[4'h1] <= 4'b0;
                reg_state[4'h2] <= 4'b0;
                reg_state[4'h3] <= 4'b0;
                nowrd <= 2'b0;
          end 
	  else if ( op16_reg== `ZeroWord ) 
           begin
             branch_flag <= `BranchInvalid;
             branch_addr <= `NOPRegAddr;
             aluop_o <= `EXE_NOP_OP;
             wd_o <= inst_i[1:0];
             wreg_o <= `WriteDisable;
             instvalid <= `InstInvalid;       
             reg1_read_o <= `ReadDisable;
             reg2_read_o <=  `ReadDisable;
             reg1_addr_o <= `ARegAddr;
             reg2_addr_o <= `BRegAddr;        
             imm <= `ZeroWord;    ;
             mem_ce_o <= `ChipDisable;
             mem_we_o <= `WriteDisable;
             op16 <= `NOP_16OP;
             reg1_o <= `NOPRegAddr;
             reg2_o <= `NOPRegAddr;
             reg_state[4'h0] <= reg_state_reg[4'h0];
             reg_state[4'h1] <= reg_state_reg[4'h1];
             reg_state[4'h2] <= reg_state_reg[4'h2];
             reg_state[4'h3] <= reg_state_reg[4'h3];
             stallreq <= 0;
             case (op)
              `EXE_NOP_OP:
                 begin
                    aluop_o<=`ALU_NOP;
                 end
             
               `EXE_MOV:   
               begin         
                    if(reg_state_reg[rs]==4'b0010||reg_state_reg[rs]==4'b0011)begin 
                            aluop_o <= `ALU_MOV;
                            reg1_o <= mem_wdata_i;
                            wd_o <= {6'b0,inst_i[1:0]};
                            wreg_o <= `WriteEnable;
                            instvalid <=`InstValid;
                            reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                            reg_state[rs]<=reg_state_reg[rs]&4'b1101;
                    end  else if(reg_state_reg[rs]!=4'b0)begin //数据冲突
                            stallreq<=`Stop;
                    end else begin           
                            aluop_o <= `ALU_MOV;
                            reg1_read_o <= `ReadEnable;
                            wd_o <= {6'b0,inst_i[1:0]};
                            wreg_o <= `WriteEnable;
                            instvalid <=`InstValid;
                            reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                    end
                end     
               
               `EXE_ADD:
                    begin
                        if(reg_state_reg[4'b0]!=4'b0|reg_state_reg[4'b0011]!=4'b0) begin
                            stallreq<=`Stop;
                        end else begin
                            aluop_o <= `ALU_ADD;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            wd_o <= {6'b0,inst_i[1:0]};
                            wreg_o <= `WriteEnable;
                            instvalid <= `InstValid;
                            reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                        end
                    end
               
               `EXE_JMP:
                    begin
                        op16 <= inst_i;
                        aluop_o <= `ALU_NOP;
                        instvalid <= `InstValid;
                    end
               
               `EXE_LOAD:
                    begin
                        if(reg_state_reg[rs]!=4'b0)begin
                             stallreq<=`Stop;
                        end else begin
                            op16 <=inst_i;
                            aluop_o <=`ALU_NOP;
                            instvalid <=`InstValid;
                        end
                    end
               
               `EXE_STORE:
                    begin
                        if(reg_state_reg[rs]==4'b0100)begin 
                            op16 <=inst_i;
                            aluop_o <=`ALU_NOP;
                             instvalid <=`InstValid;
                        end else if(reg_state_reg[rs]!=4'b0)begin
                             stallreq<=`Stop;
                        end else begin
                            op16 <=inst_i;
                            aluop_o <=`ALU_NOP;
                            instvalid <=`InstValid;
                        end
                    end                
                        
             `EXE_ORI:            
                 begin
                       wreg_o <= `WriteEnable; 
                     aluop_o <= `EXE_OR_OP;
                     reg1_read_o <= `ReadEnable;    
                     reg2_read_o <= `ReadDisable;       
                     wd_o <= {6'b0,inst_i[1:0]};  
                     instvalid <= `InstValid;    
                   end                              
             default:
                 begin 
                 end
           endcase
          end 
	  else   
           begin
              branch_flag <= `BranchInvalid;
              branch_addr <= `NOPRegAddr;
              aluop_o <= `EXE_NOP_OP;
              wreg_o <= `WriteDisable;
              instvalid <= `InstInvalid;       
              reg1_read_o <= `ReadDisable;
              reg2_read_o <= `ReadDisable;
              reg1_addr_o <= `ARegAddr;
              reg2_addr_o <= `BRegAddr;        
              imm <= `ZeroWord;
              mem_ce_o <= `ChipDisable;
              mem_we_o <= `WriteDisable;
              op16 <= `NOP_16OP; 
              reg_state[4'h0] <= reg_state_reg[4'h0];
              reg_state[4'h1] <= reg_state_reg[4'h1];
              reg_state[4'h2] <= reg_state_reg[4'h2];
              reg_state[4'h3] <= reg_state_reg[4'h3];                    
              case(op16_code)   //for 16-bit inst addr
                  `EXE_JMP: begin
                      aluop_o <= `ALU_NOP;
                      branch_flag <= `BranchValid;
                      branch_addr <= inst_i;           
                  end
                  `EXE_LOAD:begin
                      aluop_o <= `ALU_LOAD;
    //                   alusel_o<=`EXE_RES_LOGIC;
                      reg1_o<=inst_i;  //LOAD指令的源数据在内存的地址
                      wd_o <= op16_addr_rd;
                      wreg_o <= `WriteEnable;
                      instvalid<=`InstValid;
                      mem_ce_o <= `ChipEnable;
                      mem_we_o <= `WriteDisable;
                      reg_state[inst_i[1:0]] <= reg_state_reg[inst_i[1:0]]|4'b1000;
                  end
                  `EXE_STORE:begin
                      aluop_o <= `ALU_STORE;
    //                 alusel_o<=`EXE_RES_LOGIC;
                      reg2_o <= inst_i;  //STORE指令的源数据在内存的地址
					  if(reg_state_reg[op16_reg[3:2]]==4'b0010)begin
					       reg1_o<= mem_wdata_i;
					       reg_state[op16_reg[3:2]]<=reg_state_reg[op16_reg[3:2]]&4'b1101;
					  end else begin 
					  reg1_read_o <= `ReadEnable;
				      reg1_addr_o <= op16_addr_rs;
					  end
					  instvalid <= `InstValid;
                      mem_ce_o <= `ChipEnable;
                      mem_we_o <= `WriteEnable;
                  end
              endcase
     
            end
	end

	

  
	always @ (*) begin
        if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
        end else if(reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
        end else if(reg1_read_o == 1'b0) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end

    always @(posedge clk)begin
        op16_reg<=op16;
    end


	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
        end else if(reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
        end else if(reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
endmodule
