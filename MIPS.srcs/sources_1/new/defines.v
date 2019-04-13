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
`define RstEnable 1
`define RstDisable 0
`define ChipEnable 1
`define ChipDisable 0
`define InstAddrBus 7:0
`define InstBus 7:0
`define ZeroWord 0
`define RegAddrBus 7:0
`define RegBus 7:0
`define RegNum 4

`define MemBus 7:0
`define InstMemNum 256
`define InstMemNum2 8
`define DataAddrBus 7:0
`define DataBus 7:0
`define ByteWidth 7:0
`define DataMemNum 256
`define DataMemNumLog2 8
`define WriteEnable 1
`define WriteDisable 0
`define ReadEnable 1
`define ReadDisable 0
`define AluOpBus 3:0
`define AluSelBus 1:0

`define NOPRegAddr 4'b0000
`define InstValid 1
`define InstInvalid 0
`define EXE_NOP_OP 4'b0000
`define EXE_RES_NOP 2'b11

`define ALU_NOP 4'b0000
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

//Á÷Ë®ÏßÔÝÍ£
`define Stop 1
`define NoStop 0