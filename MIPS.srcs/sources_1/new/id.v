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
    input wire                  clk,
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
	output reg                     branch_flag,
	output reg[`InstAddrBus]     branch_op,
	// �͵�EX�׶ε���Ϣ
    output reg[`AluOpBus]         aluop_o,  // ALU������
//    output reg[`AluSelBus]        alusel_o, // ALU�Ӳ�����
    output reg[`RegBus]           reg1_o,   // Դ������ 1
    output reg[`RegBus]           reg2_o,   // Դ������ 2
    output reg[`RegAddrBus]       wd_o,     // Ҫд��ļĴ����ĵ�ַ
	output reg                    wreg_o,    // д�Ĵ���ʹ���ź�
	output reg                     mem_en_o,   //��дд����ʹ���ź�
	output reg                     mem_wr_o,    //��д�����źţ��ߵ�ƽд���͵�ƽ��
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
  //16λָ���ݴ�
  reg[7:0] op16;    //16λָ��ǰ��λ
  reg[7:0] op16_reg;  //�洢16λָ��ǰ��λ�ļĴ���
  wire[3:0] op16_code=op16_reg[7:4]; //16λָ��Ĳ�����
  wire[`RegAddrBus]       op16_addr_rd={6'b0,op16_reg[1:0]};   //loadָ��Ŀ�ļĴ�����ַ
  wire[`RegAddrBus]       op16_addr_rs={6'b0,op16_reg[3:2]};  //storeָ��Դ�Ĵ�����ַ
  
    //����д�����ͻ��״̬��
    reg[3:0]        reg_state[3:0];
    reg[3:0]        reg_state_reg[3:0]; 
        
        //reg_state���ά��
    always @(posedge clk)begin
        reg_state_reg[4'h0]<= reg_state[4'h0]>>1;
        reg_state_reg[4'h1]<= reg_state[4'h1]>>1;
        reg_state_reg[4'h2]<= reg_state[4'h2]>>1;
        reg_state_reg[4'h3]<= reg_state[4'h3]>>1;
    end
    
    //����д���
    always @(*)begin
        
    end
  
    // ����׶Σ�����߼�
    //   ���������������²���
	always @ (*) begin	
        if (rst == `RstEnable) begin
            branch_flag<=1'b0;
            branch_op<=8'b0;
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
			mem_en_o<=1'b0;
			mem_wr_o<=1'b0;;
			op16<=8'b0;
			reg1_o<=8'b0;
			reg2_o<=8'b0;
			stallreq<=`NoStop;
			 reg_state[4'h0]<=4'b0;
			 reg_state[4'h1]<=4'b0;
			 reg_state[4'h2]<=4'b0;
			 reg_state[4'h3]<=4'b0;
     // �����������������²���
	  end else if(op16_reg==8'b0) begin
         // ������ʵ��default�����ֵ
       //   �����ȿ������case
         branch_flag<=1'b0;
         branch_op<=8'b0;
         aluop_o <= `EXE_NOP_OP;
//            alusel_o <= `EXE_RES_NOP;
         wd_o <= inst_i[1:0];
         wreg_o <= `WriteDisable;
         instvalid <= `InstInvalid;       
         reg1_read_o <= 1'b0;
         reg2_read_o <= 1'b0;
         reg1_addr_o <= 8'b0;
         reg2_addr_o <= 8'b11;        
         imm <= `ZeroWord;    ;
         mem_en_o<=1'b0;
         mem_wr_o<=1'b0;
         op16<=8'b0;
         reg1_o<=8'b0;
         reg2_o<=8'b0;
         reg_state[4'h0]<= reg_state_reg[4'h0];
         reg_state[4'h1]<= reg_state_reg[4'h1];
         reg_state[4'h2]<= reg_state_reg[4'h2];
         reg_state[4'h3]<= reg_state_reg[4'h3];
       case (op)
         `EXE_NOP_OP:
         begin
               aluop_o<=`ALU_NOP;
         end
         
           `EXE_MOV:            
         begin
             aluop_o<=`ALU_MOV;
//              alusel_o<=`EXE_RES_LOGIC;
             reg1_read_o<=1'b1;
             wd_o<={6'b0,inst_i[1:0]};
             wreg_o<=`WriteEnable;
             instvalid<=`InstValid;
             reg_state[inst_i[1:0]]<=reg_state_reg[inst_i[1:0]]|4'b1000;
         end     
           
           `EXE_ADD:
           begin
              aluop_o<=`ALU_ADD;
//                 alusel_o<=`EXE_RES_LOGIC;
              reg1_read_o<=1'b1;
              reg2_read_o<=1'b1;
              wd_o<={6'b0,inst_i[1:0]};
              wreg_o<=`WriteEnable;
              instvalid<=`InstValid;
              reg_state[inst_i[1:0]]<=reg_state_reg[inst_i[1:0]]|4'b1000;
           end
           
           `EXE_JMP:
           begin
                op16<=inst_i;
                aluop_o<=`ALU_NOP;
                instvalid<=`InstValid;
           end
           
           `EXE_LOAD:
           begin
                 op16<=inst_i;
                 aluop_o<=`ALU_NOP;
                 instvalid<=`InstValid;
           end
           
           `EXE_STORE:
           begin
                  op16<=inst_i;
                  aluop_o<=`ALU_NOP;
                  instvalid<=`InstValid;
           end                
                    
         `EXE_ORI:            
         begin
               wreg_o <= `WriteEnable; // дʹ��
             aluop_o <= `EXE_OR_OP;
//                  alusel_o <= `EXE_RES_LOGIC; 
             reg1_read_o <= 1'b1;    // �� rs
             reg2_read_o <= 1'b0;    // ���� rt      
//               imm <= {16'h0, inst_i[15:0]};    // �������޷�����չ    
             wd_o <= {6'b0,inst_i[1:0]};  // д�Ĵ�����ַλ rt
             instvalid <= `InstValid;    
           end                              
         default:
             begin 
             end
       endcase
	  end else   begin
    	  branch_flag<=1'b0;
          branch_op<=8'b0;
          aluop_o <= `EXE_NOP_OP;
//          alusel_o <= `EXE_RES_NOP;
          wreg_o <= `WriteDisable;
          instvalid <= `InstInvalid;       
          reg1_read_o <= 1'b0;
          reg2_read_o <= 1'b0;
          reg1_addr_o <= 8'b0;
          reg2_addr_o <= 8'b11;        
          imm <= `ZeroWord;
          mem_en_o<=1'b0;
          mem_wr_o<=1'b0;
          op16<=0; 
          reg_state[4'h0]<= reg_state_reg[4'h0];
          reg_state[4'h1]<= reg_state_reg[4'h1];
          reg_state[4'h2]<= reg_state_reg[4'h2];
          reg_state[4'h3]<= reg_state_reg[4'h3];                    
          case(op16_code)   //for 16-bit inst addr
              `EXE_JMP: begin
                  aluop_o<=`ALU_NOP;
                  branch_flag<=1'b1;
                  branch_op<=inst_i;           
              end
              `EXE_LOAD:begin
                  aluop_o<=`ALU_LOAD;
//                   alusel_o<=`EXE_RES_LOGIC;
                  reg1_o<=inst_i;  //LOADָ���Դ�������ڴ�ĵ�ַ
                  wd_o=op16_addr_rd;
                  wreg_o<=`WriteEnable;
                  instvalid<=`InstValid;
                  mem_en_o<=1'b1;
                  mem_wr_o<=1'b0;
                  reg_state[inst_i[1:0]]<=reg_state_reg[inst_i[1:0]]|4'b1000;
              end
              `EXE_STORE:begin
                    aluop_o<=`ALU_STORE;
//                 alusel_o<=`EXE_RES_LOGIC;
                  reg2_o<=inst_i;  //STOREָ���Դ�������ڴ�ĵ�ַ
                  reg1_read_o<=1'b1;
                  reg1_addr_o<=op16_addr_rs;
                  instvalid<=`InstValid;
                  mem_en_o<=1'b1;
                  mem_wr_o<=1'b1;
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
    
    //16λָ��洢ǰ8λ
    always @(posedge clk)begin
        op16_reg<=op16;
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
