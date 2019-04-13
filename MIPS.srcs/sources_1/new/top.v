`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/11 17:18:27
// Design Name: 
// Module Name: top
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

module top(
    input clk,
    input rst
    );
    wire[`InstAddrBus]      ins_addr;
    wire[`RegBus]           ins_data;
    wire[`RegBus]           datarom_addr;
    wire[`RegBus]           datarom_data_i;
    wire[`RegBus]           datarom_data_o;
    wire                    instrom_ce;
    wire                    datarom_en;
    wire                    datarom_wr;
    
    //cpu实例化
    mainmips mips0(
        .clk(clk),
        .rst(rst),
        .ins_addr_o(ins_addr),
        .ins_data_i(ins_data),
        .datarom_addr_o(datarom_addr),
        .datarom_data_i(datarom_data_i),
        .datarom_data_o(datarom_data_o),
        .instrom_ce_o(instrom_ce),
        .datarom_en_o(datarom_en),
        .datarom_wr_o(datarom_wr)
    );
    
    //代码存储器实例化
    inst_rom inst_rom0(
        .ce(instrom_ce),
        .addr(ins_addr),
        .inst(ins_data)
    );
    
    //数据存储器实例化
    data_ram data_ram0(
        .clk(clk),
        .ce(datarom_en),
        .we(datarom_wr),
        .addr(datarom_addr),
        .data_i(datarom_data_o),
        .data_o(datarom_data_i)
    );
    
endmodule
