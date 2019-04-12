`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/11 22:00:48
// Design Name: 
// Module Name: mips_top
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

module mips_top(
    input wire clk,
    input wire rst
    );
    //����ָ��洢��
    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire                rom_ce;
    
    
    //�������ݴ�����
    wire[`DataAddrBus] data_addr;
    wire[`DataBus]     ram_data;
    wire ram_we;
    wire ram_ce;  
    wire[`DataBus]  data;
    
    //ʵ����MIPS
    mainmips mainmips0(
        .rst(rst),
        .clk(clk),
        .rom_data_i(data_addr),
        .ram_data_i(data),
        .rom_ce_o(rom_ce),
        .rom_addr_o(inst_addr),
        .ram_addr_o(data_addr),
        .ram_data_o(ram_data),
        .ram_we_o(ram_we),
        .ram_ce_o(ram_ce)
    );
    
        //ָ��洢��ʵ����
    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );
    
    //���ݴ洢��ʵ����
    data_ram data_ram0(
        .clk(clk),
        .addr(data_addr),
        .data(ram_data),
        .we(ram_we),
        .ce(ram_ce),
        .data_o(data)
    );
    
endmodule