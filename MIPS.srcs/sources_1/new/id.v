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

    // ��ȡ��REGFILE��ֵ
	input wire[`RegBus]           reg1_data_i,
	input wire[`RegBus]           reg2_data_i,

	// �����REGFILE����Ϣ���������˿�1��2�Ķ�ʹ���ź��Լ�����ַ�ź�
	output reg                    reg1_read_o,
	output reg                    reg2_read_o,     
	output reg[`RegAddrBus]       reg1_addr_o,
	output reg[`RegAddrBus]       reg2_addr_o, 	      
	
	//�͵�IF�ķ�֧flag�ͷ�֧��ַ
	output reg                    branch_flag,
	output reg[`InstAddrBus]      branch_addr,
	
	// �͵�EX�׶ε���Ϣ
    output reg[`AluOpBus]         aluop_o,  // ALU������
    //output reg[`AluSelBus]        alusel_o, // ALU�Ӳ�����
    output reg[`RegBus]           reg1_o,   // Դ������ 1
    output reg[`RegBus]           reg2_o,   // Դ������ 2
    output reg[`RegAddrBus]       wd_o,     // Ҫд��ļĴ����ĵ�ַ
	output reg                    wreg_o ,   // дʹ���ź�
	output reg stallreq
    );
    
        // ȡ��ָ���ָ���롢������ȣ�
  wire[3:0] op = inst_i[7:4]; 
  wire[4:0] rs = inst_i[3:2];
  wire[5:0] rd = inst_i[1:0];
    // ����ָ��ִ����Ҫ��������
  reg[`RegBus]	imm;
    // ָ���Ƿ���Ч
  reg instvalid;
  
  reg[3:0] op16code;    //16λָ��Ĳ�����
  reg[`RegAddrBus]  op16_addr_rd;   //loadָ��Ŀ�ļĴ�����ַ
  reg[`RegBus]       op16_addr_rs;  //storeָ��Դ�Ĵ�����ַ
  
  
 
    // ����׶Σ�����߼�
    //   ���������������²���
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
			mem_wr_o <= `WritDisnable;
			is_16op <= `Is16Inst;
			op16code <= `NOP_16OP;

     // �����������������²���
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
                   reg1_o <= inst_i;  //LOADָ���Դ�������ڴ�ĵ�ַ
                   wd_o <= op16_addr_rd;
                   wreg_o <= `WriteEnable;
                   instvalid <=`InstValid;
                   mem_en_o <= `ChipEnable;
                   mem_wr_o <= `WriteDisable;
	           end
	           `ALU_STORE:begin
		  	       aluop_o <= `ALU_STORE;
  //                 alusel_o<=`EXE_RES_LOGIC;
                   reg1_o <= inst_i;  //STOREָ���Դ�������ڴ�ĵ�ַ
                   reg2_read_o <= `ReadEnable;
                   reg2_addr_o <= op16_addr_rs;
                   instvalid <= `InstValid;
                   mem_en_o <= `ChipEnable;
                   mem_wr_o <= `WriteEnable;
	           end
	       endcase
	  end else   begin
          // ������ʵ��default�����ֵ
          //   �����ȿ������case
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
            mem_wr_o <= `WritDisnable;
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
					wreg_o <= `WriteEnable; // дʹ��
					aluop_o <= `EXE_OR_OP;
	//		  		alusel_o <= `EXE_RES_LOGIC; 
					reg1_read_o <= `ReadEnable;	// �� rs
					reg2_read_o <= `ReadDisable;	// ���� rt  	
	//               imm <= {16'h0, inst_i[15:0]};	// �������޷�����չ	
					wd_o <= inst_i[1:0];  // д�Ĵ�����ַλ rt
					instvalid <= `InstValid;	
				end 							 
            default:
                // �������Ѿ�����
                begin 
                end
		  endcase
		end
	end

	

    // ȷ������Ĳ�����1
	always @ (*) begin
        if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
        end else if(reg1_read_o == `ReadEnable) begin
            reg1_o <= reg1_data_i;
            // ��û�� ��ʹ�ܣ������������Ϊ�������Ϊ ������1
        end else if(reg1_read_o == `ReadDisable) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
	
    // ȷ������Ĳ�����2
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
        end else if(reg2_read_o == `ReadEnable) begin
            reg2_o <= reg2_data_i;
            // ��û�� ��ʹ�ܣ������������Ϊ�������Ϊ ������1
        end else if(reg2_read_o == `ReadDisable) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
endmodule
