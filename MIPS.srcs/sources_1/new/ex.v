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
	// ������׶��͹�������Ϣ
	input wire[`AluOpBus]         aluop_i,
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	input wire[`RegAddrBus]       wd_i,
	input wire                    wreg_i,

	// ִ�еĽ��
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
    output reg[`RegBus]			  wdata_o,
    output reg stallreq
    );
        // �����߼�����Ľ��
	reg[`RegBus] logicout;
    
    // ����߼����������������ͽ������㣬�˴�ֻ��"������"
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


    // ����߼�: ��������������ѡ��һ��ѡ��һ����������Ϊ���ս�����
 always @ (*) begin
     // ��Ҫд��ļĴ����ĵ�ַ
	 wd_o <= wd_i;	 	 
     // �Ĵ���дʹ��
	 wreg_o <= wreg_i;
     // ��������������ѡ��һ��ѡ��һ����������Ϊ���ս�����

 end	
endmodule
