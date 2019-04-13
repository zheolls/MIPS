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
	
	input wire[`RegBus]            ins_data_i,
	input wire[`RegBus]          datarom_data_i,
    output wire[`RegBus]          datarom_addr_o,
    output wire[`RegBus]         datarom_data_o,
    output wire[`RegBus]         ins_addr_o,
	output wire                   instrom_ce_o,
	output wire                    datarom_en_o,
	output wire                    datarom_wr_o
    );
    
    //IF模块的输出，连接到IF/ID模块
    
    // IF/ID模块的输出，连接到ID模块的输入
	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	
	// ID模块输出，连接到ID/EX模块的输入
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_reg1_o;
	wire[`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire[`RegAddrBus] id_wd_o;
	wire               id_mem_en_o;
    wire               id_mem_wr_o;	

	//ID模块输出，连接到IF模块的输入
	wire       branch_flag_o;
	wire[`InstAddrBus] branch_op_o;

	
	// ID/EX模块输出，连接到EX模块的输入
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_reg1_i;
	wire[`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire[`RegAddrBus] ex_wd_i;
	wire               ex_mem_en_i;
	wire               ex_mem_wr_i;
	
	// EX模块的输出，连接到EX/MEM模块的输入
	wire ex_wreg_o;
	wire[`RegAddrBus] ex_wd_o;
	wire[`RegBus] ex_wdata_o;
	wire           ex_mem_en_o;
	wire           ex_mem_wr_o;
	wire[`InstAddrBus] ex_mem_addr_o;

	// EX/MEM模块的输出，连接到MEM模块的输入
	wire mem_wreg_i;
	wire[`RegAddrBus] mem_wd_i;
	wire[`RegBus] mem_wdata_i;
	wire           mem_en_i;
	wire           mem_wr_i;
	wire[`InstAddrBus]   mem_addr_i;

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
    assign ins_addr_o = pc;
 
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
		.stall(stall),
		.branch_flag(branch_flag_o),
		.pc_branch(branch_op_o),
		.pc(pc),
		.ce(instrom_ce_o)
			
	);


  // IF/ID模块的实例化
	if_id if_id0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.if_pc(pc),
		.if_inst(ins_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)  	
	);
	
	// ID模块实例化
	id id0(
	    .clk(clk),
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),
		
		//送到IF段的输出
		.branch_flag(branch_flag_o),
		.branch_op(branch_op_o),
		
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
		.mem_en_o(id_mem_en_o),
		.mem_wr_o(id_mem_wr_o),
		
		//送到ctrl模块
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
		.stall(stall),
		
		// 来自ID阶段的数据
		.id_aluop(id_aluop_o),
//		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
		.id_mem_en(id_mem_en_o),
		.id_mem_wr(id_mem_wr_o),
	
		// 要送到EX阶段的数据
		.ex_aluop(ex_aluop_i),
//		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
		.ex_mem_en(ex_mem_en_i),
		.ex_mem_wr(ex_mem_wr_i)
		
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
		.mem_en_i(ex_mem_en_i),
		.mem_wr_i(ex_mem_wr_i),
	  
	  // EX阶段的结果，输出到EX/MEM的数据
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		.mem_en_o(ex_mem_en_o),
		.mem_wr_o(ex_mem_wr_o),
		.mem_addr_o(ex_mem_addr_o),
		
		//送到ctrk模块
		.stallreq(stallreq_ex)
		
	);

  // EX/MEM的实例化
  ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
		.stall(stall),
	  
		// 来自EX模块的数据	
		.ex_wd(ex_wd_o),
		.ex_wreg(ex_wreg_o),
		.ex_wdata(ex_wdata_o),
	    .ex_mem_en(ex_mem_en_o),
	    .ex_mem_wr(ex_mem_wr_o),
	    .ex_mem_addr(ex_mem_addr_o),

		// 将要送到MEM阶段的数据
		.mem_wd(mem_wd_i),
		.mem_wreg(mem_wreg_i),
		.mem_wdata(mem_wdata_i),
        .mem_en(mem_en_i),
        .mem_wr(mem_wr_i),
        .mem_addr(mem_addr_i)
						       	
	);
	
  // MEM模块的实例化
	mem mem0(
		.rst(rst),
	
		// 来自EX/MEM模块的数据
		.wd_i(mem_wd_i),
		.wreg_i(mem_wreg_i),
		.wdata_i(mem_wdata_i),
		.mem_en_i(mem_en_i),
		.mem_wr_i(mem_wr_i),
		.mem_addr_i(mem_addr_i),
	  
	  //接受数据存储器的数据
	    .mem_read_data(datarom_data_i),
	  
	  //送到数据存储器
        .mem_en(datarom_en_o),
        .mem_wr(datarom_wr_o),
        .mem_addr(datarom_addr_o),	  
	    .mem_write_data(datarom_data_o),
	    
		// 要送到MEM/WB模块的数据
		.wd_o(mem_wd_o),
		.wreg_o(mem_wreg_o),
		.wdata_o(mem_wdata_o)
	);

  // MEM/WB 模块的实例化
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),
		.stall(stall),

		// 来自MEM的数据
		.mem_wd(mem_wd_o),
		.mem_wreg(mem_wreg_o),
		.mem_wdata(mem_wdata_o),
	
		// 将要送到RegFile的数据
		.wb_wd(wb_wd_i),
		.wb_wreg(wb_wreg_i),
		.wb_wdata(wb_wdata_i)
									       	
	);
endmodule
