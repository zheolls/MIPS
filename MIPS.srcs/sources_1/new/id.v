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
  wire[5:0] op = inst_i[31:26]; //����ORIָ��ֻ��Ҫ�ж� 26-31bit ��ֵ�����ж�
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];
  wire[4:0] op4 = inst_i[20:16];
    // ����ָ��ִ����Ҫ��������
  reg[`RegBus]	imm;
    // ָ���Ƿ���Ч
  reg instvalid;
  
  
 
    // ����׶Σ�����߼�
    //   ���������������²���
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
     // �����������������²���
	  end else begin
          // ������ʵ��default�����ֵ
          //   �����ȿ������case
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
		  		wreg_o <= `WriteEnable; // дʹ��
                aluop_o <= `EXE_OR_OP;
//		  		alusel_o <= `EXE_RES_LOGIC; 
                reg1_read_o <= 1'b1;	// �� rs
                reg2_read_o <= 1'b0;	// ���� rt  	
                imm <= {16'h0, inst_i[15:0]};	// �������޷�����չ	
                wd_o <= inst_i[20:16];  // д�Ĵ�����ַλ rt
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
        end else if(reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
            // ��û�� ��ʹ�ܣ������������Ϊ�������Ϊ ������1
        end else if(reg1_read_o == 1'b0) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
	
    // ȷ������Ĳ�����2
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
        end else if(reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
            // ��û�� ��ʹ�ܣ������������Ϊ�������Ϊ ������1
        end else if(reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
endmodule
