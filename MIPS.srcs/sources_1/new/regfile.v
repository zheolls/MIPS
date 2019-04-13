`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:22:18
// Design Name: 
// Module Name: regfile
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


module regfile(
	// д�˿�
	input wire					 we,
    input wire[`RegAddrBus]		 waddr,
    input wire[`RegBus]			 wdata,
	
	// ���˿� 1
	input wire					 re1,
    input wire[`RegAddrBus]		 raddr1,
    output reg[`RegBus]          rdata1,
	
	// ���˿� 2
	input wire					 re2,
    input wire[`RegAddrBus]		 raddr2,
    output reg[`RegBus]          rdata2,
    input rst,
    input clk
    );
        // ����8��8λ�Ĵ���
    reg[`RegBus]  regs[0:`RegNum-1];
    
    //test
 /*   always@(posedge clk)begin
         regs[8'b0000]<=8'b1000_0000;
         regs[8'b0001]<=8'b1000_0001;
         regs[8'b0010]<=8'b1000_0010;
         regs[8'b0011]<=8'b1000_0011;
    end*/
    // д����
	always @ (posedge clk) begin
		if (rst == `RstDisable) begin
            // ��� дʹ�� ���� ����û����0�żĴ���д�붫����ʱ�����ǲ���Ĵ�������д��
            // ��Ϊ 0 �żĴ���ֻ��������Զ���� 32'h0
            if(we == `WriteEnable) begin
				regs[waddr] <= wdata;
			end
		end
	end
	    // ���˿�1 �Ķ�����
	always @ (*) begin
       // ������������ 32'h0
	  if(rst == `RstEnable) begin
          rdata1 <= `ZeroWord;
       // ������ַ��д��ַ��ͬ����дʹ�ܣ��Ҷ˿�1��ʹ�ܣ���Ҫ��д�������ֱ�Ӷ�����
       //   ����ǰ�Ƶ�ʵ�֣�������ἰ
	  end else if((raddr1 == waddr) && (we == `WriteEnable) 
            && (re1 == `ReadEnable)) begin // ע��˲��֣���⣡
	  	  rdata1 <= wdata;
       // �����ȡ��Ӧ�Ĵ�����Ԫ
	  end else if(re1 == `ReadEnable) begin
	      rdata1 <= regs[raddr1];
       // �����һ�����˿ڲ���ʹ��ʱ�����0
	  end else begin
	      rdata1 <= `ZeroWord;
	  end
	end

    // ���˿�2 �Ķ�����
    // �Ͷ��˿�1 ����
	always @ (*) begin
		if(rst == `RstEnable) begin
            rdata2 <= `ZeroWord;
	  end else if(raddr2 == `RegNum'h0) begin
	  		rdata2 <= `ZeroWord;
	  end else if((raddr2 == waddr) && (we == `WriteEnable) 
                  && (re2 == `ReadEnable)) begin // ע��˲��֣���⣡
	  	  rdata2 <= wdata;
	  end else if(re2 == `ReadEnable) begin
	      rdata2 <= regs[raddr2];
	  end else begin
	      rdata2 <= `ZeroWord;
	  end
	end

endmodule
