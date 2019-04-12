`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/09 16:58:37
// Design Name: 
// Module Name: mainmips
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


module mainmips(
    input	wire				  clk,
	input wire					  rst,
	
	input wire[`RegBus]           rom_data_i,
    output wire[`RegBus]          rom_addr_o,
    output wire                   rom_ce_o,
    input wire[`RegBus]           ram_data_i,
    output reg[`RegBus]           ram_addr_o,
    output reg[`RegBus]           ram_data_o,
    output reg                    ram_we,
    output reg                    ram_ce
    
    );
    
    // IF/ID模块的输出，连接到ID模块的输入
	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	
	// ID模块输出，连接到ID/EX模块的输入
	wire[`AluOpBus] id_aluop_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	
	// ID/EX模块输出，连接到EX模块的输入
	wire[`AluOpBus] ex_aluop_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	
	// EX模块的输出，连接到EX/MEM模块的输入
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;

	// EX/MEM模块的输出，连接到MEM模块的输入
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;

	// MEM模块的输出，连接到MEM/WB模块的输入
	wire mem_wreg_o;
	wire[`RegAddrBus] mem_wd_o;
	wire[`RegBus] mem_wdata_o;
	
	// MEM/WB模块的输出，连接到WB模块的输入
	wire wb_wreg_i;
	wire[`RegAddrBus] wb_wd_i;
	wire[`RegBus] wb_wdata_i;
	
	// WB模块的输出，连接到ID阶段RegFile模块的输入
    wire reg1_read;
    wire reg2_read;
    wire[`RegBus] reg1_data;
    wire[`RegBus] reg2_data;
    wire[`RegAddrBus] reg1_addr;
    wire[`RegAddrBus] reg2_addr;
    
    //流水线暂停控制
    wire stallreq_id;
    wire stallreq_ex;
    wire[5:0] stall;
    
    //流水线暂停控制实例化
    ctrl ctrl0(
        .rst(rst),
        .stallreq_from_id(stallreq_id),
        .stallreq_from_ex(stallreq_ex),
        .stall(stall)
    );
    
    
  // PC_REG 的实例化
	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.ce(rom_ce_o)	
			
	);
	
  assign rom_addr_o = pc;

  // IF/ID模块的实例化
	if_id if_id0(
		.clk(clk),
		.rst(rst),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i),
        .stall(stall)
 	
	);
	
	// ID模块实例化
	id id0(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		// 来自REGFILE的数据输入
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  

		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
	  
		// 送到ID/EX模块的数据
		.aluop_o(id_aluop_o),
//		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
		.stallreq(stallreq_id)
	);

  //? RegFile模块的实例化
	regfile regfile1(
		.clk (clk),
		.rst (rst),
		.we	(wb_wreg_i),
		.waddr (wb_wd_i),
		.wdata (wb_wdata_i),
		.re1 (reg1_read),
		.raddr1 (reg1_addr),
		.rdata1 (reg1_data),
		.re2 (reg2_read),
		.raddr2 (reg2_addr),
		.rdata2 (reg2_data)
	);

	// ID/EX模块的实例化
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),
		
		// 来自ID阶段的数据
		.id_aluop(id_aluop_o),
//		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
	
		// 要送到EX阶段的数据
		.ex_aluop(ex_aluop_i),
//		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.stall(stall)
	);		
	
	// EX模块的实例化
	ex ex0(
		.rst(rst),
	
		// 来自ID/EX的数据
		.aluop_i(ex_aluop_i),
//		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
	  
	  // EX阶段的结果，输出到EX/MEM的数据
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		.stallreq(stallreq_ex)
	);

  // EX/MEM的实例化
  ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  
		// 来自EX模块的数据	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
	

		// 将要送到MEM阶段的数据
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
        
        .stall(stall)
						       	
	);
	
  // MEM模块的实例化
	mem mem0(
		.rst(rst),
	
		// 来自EX/MEM模块的数据
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
	  
		// 要送到MEM/WB模块的数据
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o)
	);

  // MEM/WB 模块的实例化
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

		// 来自MEM的数据
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
	
		// 将要送到RegFile的数据
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i),
        .stall(stall)
							       	
	);
endmodule
