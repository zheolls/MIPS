`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 15:37:23
// Design Name: 
// Module Name: defines
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
//各类使能信号
`define RstEnable 1
`define RstDisable 0
`define ChipEnable 1
`define ChipDisable 0
`define WriteEnable 1
`define WriteDisable 0
`define ReadEnable 1
`define ReadDisable 0
`define InstValid 1
`define InstInvalid 0
`define BranchValid 1
`define BranchInvalid 0

//8 or 16 位指令
`define Is8Inst 0
`define Is16Inst 1

//流水线暂停
`define Stop 1
`define NoStop 0
//零
`define ZeroWord 8'b00000000
//字节宽度
`define ByteWidth 7:0
//各类Bus带宽
`define InstAddrBus 7:0
`define InstBus 7:0
`define MemBus 7:0
`define RegAddrBus 7:0
`define RegBus 7:0
`define DataAddrBus 7:0
`define DataBus 7:0
`define AluOpBus 3:0
//各类单元数量
`define RegNum 256
`define InstMemNum 256
`define InstMemNum2 8
`define DataMemNum 256
`define DataMemNumLog2 8

//
`define ARegAddr 8'b00000000
`define BRegAddr 8'b00000011
//空地址
`define NOPRegAddr 8'b00000000
//操作码
`define NOP_16OP 4'b0000
`define EXE_NOP_OP 4'b1111
`define EXE_RES_NOP 2'b11

`define ALU_MOV 4'b0001
`define ALU_ADD 4'b0010
`define ALU_JMP 4'b0011
`define ALU_LOAD 4'b0100
`define ALU_STORE 4'b0101
`define EXE_OR_OP 4'b1000
`define EXE_RES_LOGIC 0

`define EXE_MOV 4'b0001
`define EXE_ADD 4'b0010
`define EXE_JMP 4'b0011
`define EXE_LOAD 4'b0100
`define EXE_STORE 4'b0101
`define EXE_ORI 4'b0110
