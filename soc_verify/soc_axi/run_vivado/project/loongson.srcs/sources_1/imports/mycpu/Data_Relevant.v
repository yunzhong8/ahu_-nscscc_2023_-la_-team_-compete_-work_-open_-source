/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：reg类型在if中要更新
*
*/
/*************\
\*************/

`include "define.v"
module Data_Relevant(
     input wire [`ExForwardBusWidth]    ex_forward_ibus,
     input wire  [`MmForwardBusWidth]   mm_forward_ibus,
     input wire [`MemForwardBusWidth]   mem_forward_ibus,
     input wire [`RegsOldReadBusWidth]  regs_old_read_ibus,
     
     output wire [`RegsRigthReadBusWidth]regs_rigth_read_obus   //  
     
    );
/***************************************input variable define(输入变量定义)**************************************/
wire [`LineExForwardBusWidth] line1_ex_to_ibus ;
wire [`LineExForwardBusWidth] line2_ex_to_ibus ;

wire [`LineMemForwardBusWidth] line1_mem_to_ibus;
wire [`LineMemForwardBusWidth] line2_mem_to_ibus;

wire [`LineMmForwardBusWidth] line1_mm_to_ibus;
wire [`LineMmForwardBusWidth] line2_mm_to_ibus;

wire [`RegsReadObusWidth]  regs_old_rdata_ibus;
wire [`RegsReadIbusWidth] regs_old_raddr_ibus;

//执行阶段寄存器组信息
         wire                   line1_ex_regs_we_i          ,line2_ex_regs_we_i;
         wire [`RegsAddrWidth]  line1_ex_regs_waddr_i       ,line2_ex_regs_waddr_i;
         wire [`RegsDataWidth]  line1_ex_regs_wdata_i       ,line2_ex_regs_wdata_i;
            
    //存储阶段寄存器组信息
        wire                   line2_mem_regs_we_i               ,line1_mem_regs_we_i;             
        wire[`RegsAddrWidth]   line2_mem_regs_waddr_i            ,line1_mem_regs_waddr_i;          
        wire[`RegsDataWidth]   line2_mem_regs_wdata_i            ,line1_mem_regs_wdata_i;          
       
     //存储阶段寄存器组信息                                                                                                                                           
         wire                   line2_mm_regs_we_i               ,line1_mm_regs_we_i;          
         wire[`RegsAddrWidth]   line2_mm_regs_waddr_i            ,line1_mm_regs_waddr_i;      
         wire[`RegsDataWidth]   line2_mm_regs_wdata_i            ,line1_mm_regs_wdata_i;       
        
              
    //正常寄存器组读出数据和读地址      
        
         wire line2_regs_re1_i,line1_regs_re1_i; 
         wire [`RegsAddrWidth]    line2_regs_raddr1_i,line1_regs_raddr1_i; 
         wire [`RegsDataWidth]    line2_regs_rdata1_i,line1_regs_rdata1_i; 
         
         wire line2_regs_re2_i,line1_regs_re2_i;                                              
         wire [`RegsAddrWidth]    line2_regs_raddr2_i,line1_regs_raddr2_i;  
         wire [`RegsDataWidth]    line2_regs_rdata2_i,line1_regs_rdata2_i;  
         
         
         
               
/***************************************output variable define(输出变量定义)**************************************/ 
  wire [`RegsDataWidth]   line2_regs_rdata1_o,line1_regs_rdata1_o;    
  wire [`RegsDataWidth]   line2_regs_rdata2_o,line1_regs_rdata2_o;    
  
  
  wire [`LineRegsReadObusWidth]line2_to_id_obus,line1_to_id_obus;
  wire line2_regs_read_ready_o,line1_regs_read_ready_o;
 
/***************************************inner variable define(内部变量定义)**************************************/
        
//line2寄存器1读相关                       
    wire line2_line1_exe_relate1, line1_line1_exe_relate1;   
    wire line2_line1_mem_relate1, line1_line1_mem_relate1; 
    wire line2_line1_mm_relate1, line1_line1_mm_relate1;   
    wire line2_line2_exe_relate1, line1_line2_exe_relate1;   
    wire line2_line2_mem_relate1, line1_line2_mem_relate1;   
    wire line2_line2_mm_relate1, line1_line2_mm_relate1;
//line2寄存器2读相关                         
    wire line2_line1_exe_relate2, line1_line1_exe_relate2;    
    wire line2_line1_mem_relate2, line1_line1_mem_relate2; 
    wire line2_line1_mm_relate2, line1_line1_mm_relate2;   
    wire line2_line2_exe_relate2, line1_line2_exe_relate2;    
    wire line2_line2_mem_relate2, line1_line2_mem_relate2;   
    wire line2_line2_mm_relate2, line1_line2_mm_relate2; 


//line2 执行部分的exe相关



wire line2_line1_exe_relate ,line1_line1_exe_relate ;
wire line2_line2_exe_relate ,line1_line2_exe_relate ;

//line2 执行部分mem相关                         
wire line2_line1_mem_relate ,line1_line1_mem_relate ;
wire line2_line2_mem_relate ,line1_line2_mem_relate ;
wire line2_line1_mm_relate ,line1_line1_mm_relate ;                          
wire line2_line2_mm_relate ,line1_line2_mm_relate ;                           


//请求暂停信号
wire line2_exe_stall ,line1_exe_stall ;
wire line2_mem_stall ,line1_mem_stall ;
wire line2_mm_stall ,line1_mm_stall ;


wire line2_line1_regs_read_ready,line1_line1_regs_read_ready;  
wire line2_line2_regs_read_ready,line1_line2_regs_read_ready;  

/****************************************input decode(输入解码)***************************************/
   //线级解码
   assign {line2_ex_to_ibus,line1_ex_to_ibus} = ex_forward_ibus;
   assign {line2_mem_to_ibus,line1_mem_to_ibus} = mem_forward_ibus;
   assign {line2_mm_to_ibus,line1_mm_to_ibus} = mm_forward_ibus;
   assign {regs_old_rdata_ibus ,regs_old_raddr_ibus} =  regs_old_read_ibus;
   
   
   //变量级解码
   assign{
         line1_ex_regs_we_i,line1_ex_regs_waddr_i,line1_ex_regs_wdata_i,
         line1_exe_stall} = line1_ex_to_ibus; 
         
   assign{
        line1_mm_regs_we_i,line1_mm_regs_waddr_i,line1_mm_regs_wdata_i,
        line1_mm_stall} = line1_mm_to_ibus;      
         
           
  assign{
        line1_mem_regs_we_i,line1_mem_regs_waddr_i,line1_mem_regs_wdata_i,
        line1_mem_stall} = line1_mem_to_ibus;
        
  assign{
         line2_regs_re2_i,line2_regs_raddr2_i,line2_regs_re1_i,line2_regs_raddr1_i,
         line1_regs_re2_i,line1_regs_raddr2_i,line1_regs_re1_i,line1_regs_raddr1_i 
              
         } = regs_old_raddr_ibus;
         
         
  assign{
         line2_ex_regs_we_i,line2_ex_regs_waddr_i,line2_ex_regs_wdata_i,
         line2_exe_stall} = line2_ex_to_ibus; 
         
   assign{
        line2_mm_regs_we_i,line2_mm_regs_waddr_i,line2_mm_regs_wdata_i,
        line2_mm_stall} = line2_mm_to_ibus;       
         
         
           
  assign{
        line2_mem_regs_we_i,line2_mem_regs_waddr_i,line2_mem_regs_wdata_i,
        line2_mem_stall} = line2_mem_to_ibus;
        
  assign{
         line2_regs_rdata2_i,line2_regs_rdata1_i,
         line1_regs_rdata2_i,line1_regs_rdata1_i} = regs_old_rdata_ibus;

/****************************************output code(输出解码)***************************************/
   assign line1_to_id_obus ={
                             line1_regs_rdata2_o,line1_regs_rdata1_o};
   assign line2_to_id_obus ={
                             line2_regs_rdata2_o,line2_regs_rdata1_o};
                             
   assign regs_rigth_read_obus = {line2_regs_read_ready_o,line2_to_id_obus,
                                 line1_regs_read_ready_o,line1_to_id_obus} ;
/*******************************complete logical function (逻辑功能实现)*******************************/



//相关性信号检
//line1 1
assign line1_line1_exe_relate1 = (line1_regs_re1_i && line1_regs_raddr1_i != 5'd0 && line1_regs_raddr1_i  == line1_ex_regs_waddr_i  && line1_ex_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0;
assign line1_line1_mem_relate1 = (line1_regs_re1_i && line1_regs_raddr1_i != 5'd0 && line1_regs_raddr1_i  == line1_mem_regs_waddr_i && line1_mem_regs_we_i == `WriteEnable ) ? 1'b1 : 1'b0;
assign line1_line1_mm_relate1  = (line1_regs_re1_i && line1_regs_raddr1_i != 5'd0 && line1_regs_raddr1_i  == line1_mm_regs_waddr_i  && line1_mm_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0;
assign line1_line2_exe_relate1 = (line1_regs_re1_i && line1_regs_raddr1_i != 5'd0 && line1_regs_raddr1_i  == line2_ex_regs_waddr_i  && line2_ex_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0; 
assign line1_line2_mm_relate1  = (line1_regs_re1_i && line1_regs_raddr1_i != 5'd0 && line1_regs_raddr1_i  == line2_mm_regs_waddr_i  && line2_mm_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0;      
assign line1_line2_mem_relate1 = (line1_regs_re1_i && line1_regs_raddr1_i != 5'd0 && line1_regs_raddr1_i  == line2_mem_regs_waddr_i && line2_mem_regs_we_i == `WriteEnable ) ? 1'b1 : 1'b0;    

//line1 2
assign line1_line1_exe_relate2 = (line1_regs_re2_i && line1_regs_raddr2_i != 5'd0 && line1_regs_raddr2_i  == line1_ex_regs_waddr_i  && line1_ex_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0;
assign line1_line1_mem_relate2 = (line1_regs_re2_i && line1_regs_raddr2_i != 5'd0 && line1_regs_raddr2_i  == line1_mem_regs_waddr_i && line1_mem_regs_we_i == `WriteEnable ) ? 1'b1 : 1'b0;
assign line1_line1_mm_relate2  = (line1_regs_re2_i && line1_regs_raddr2_i != 5'd0 && line1_regs_raddr2_i  == line1_mm_regs_waddr_i  && line1_mm_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0;
assign line1_line2_exe_relate2 = (line1_regs_re2_i && line1_regs_raddr2_i != 5'd0 && line1_regs_raddr2_i  == line2_ex_regs_waddr_i  && line2_ex_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0;
assign line1_line2_mm_relate2  = (line1_regs_re2_i && line1_regs_raddr2_i != 5'd0 && line1_regs_raddr2_i  == line2_mm_regs_waddr_i  && line2_mm_regs_we_i  == `WriteEnable ) ? 1'b1 : 1'b0;    
assign line1_line2_mem_relate2 = (line1_regs_re2_i && line1_regs_raddr2_i != 5'd0 && line1_regs_raddr2_i  == line2_mem_regs_waddr_i && line2_mem_regs_we_i == `WriteEnable ) ? 1'b1 : 1'b0; 

//line2 1
assign line2_line1_exe_relate1 = (line2_regs_re1_i && line2_regs_raddr1_i != 5'd0 && line2_regs_raddr1_i  == line1_ex_regs_waddr_i  && line1_ex_regs_we_i  ==`WriteEnable ) ? 1'b1 : 1'b0;
assign line2_line1_mem_relate1 = (line2_regs_re1_i && line2_regs_raddr1_i != 5'd0 && line2_regs_raddr1_i  == line1_mem_regs_waddr_i && line1_mem_regs_we_i ==`WriteEnable ) ? 1'b1 : 1'b0;
assign line2_line1_mm_relate1  = (line2_regs_re1_i && line2_regs_raddr1_i != 5'd0 && line2_regs_raddr1_i  == line1_mm_regs_waddr_i  && line1_mm_regs_we_i  ==`WriteEnable ) ? 1'b1 : 1'b0;
assign line2_line2_exe_relate1 = (line2_regs_re1_i && line2_regs_raddr1_i != 5'd0 && line2_regs_raddr1_i  == line2_ex_regs_waddr_i  && line2_ex_regs_we_i  ==`WriteEnable ) ? 1'b1 : 1'b0;  
assign line2_line2_mm_relate1  = (line2_regs_re1_i && line2_regs_raddr1_i != 5'd0 && line2_regs_raddr1_i  == line2_mm_regs_waddr_i  && line2_mm_regs_we_i ==`WriteEnable  ) ? 1'b1 : 1'b0; 
assign line2_line2_mem_relate1 = (line2_regs_re1_i && line2_regs_raddr1_i != 5'd0 && line2_regs_raddr1_i  == line2_mem_regs_waddr_i && line2_mem_regs_we_i ==`WriteEnable ) ? 1'b1 : 1'b0;    

//line2
assign line2_line1_exe_relate2 = (line2_regs_re2_i && line2_regs_raddr2_i != 5'd0 && line2_regs_raddr2_i  == line1_ex_regs_waddr_i  && line1_ex_regs_we_i  ==`WriteEnable  ) ? 1'b1:1'b0;
assign line2_line1_mem_relate2 = (line2_regs_re2_i && line2_regs_raddr2_i != 5'd0 && line2_regs_raddr2_i  == line1_mem_regs_waddr_i && line1_mem_regs_we_i ==`WriteEnable  ) ? 1'b1:1'b0;
assign line2_line1_mm_relate2  = (line2_regs_re2_i && line2_regs_raddr2_i != 5'd0 && line2_regs_raddr2_i  == line1_mm_regs_waddr_i  && line1_mm_regs_we_i  ==`WriteEnable  ) ? 1'b1:1'b0;
assign line2_line2_exe_relate2 = (line2_regs_re2_i && line2_regs_raddr2_i != 5'd0 && line2_regs_raddr2_i  == line2_ex_regs_waddr_i  && line2_ex_regs_we_i  ==`WriteEnable  ) ? 1'b1:1'b0;   
assign line2_line2_mm_relate2  = (line2_regs_re2_i && line2_regs_raddr2_i != 5'd0 && line2_regs_raddr2_i  == line2_mm_regs_waddr_i  && line2_mm_regs_we_i ==`WriteEnable   ) ? 1'b1:1'b0; 
assign line2_line2_mem_relate2 = (line2_regs_re2_i && line2_regs_raddr2_i != 5'd0 && line2_regs_raddr2_i  == line2_mem_regs_waddr_i && line2_mem_regs_we_i ==`WriteEnable  ) ? 1'b1:1'b0; 


//更新寄存器读出数据
assign line1_regs_rdata1_o =  line1_line2_exe_relate1? line2_ex_regs_wdata_i :
	                          line1_line1_exe_relate1? line1_ex_regs_wdata_i :
	                          line1_line2_mm_relate1 ? line2_mm_regs_wdata_i :
	                          line1_line1_mm_relate1 ? line1_mm_regs_wdata_i :
	                          line1_line2_mem_relate1? line2_mem_regs_wdata_i:
	                          line1_line1_mem_relate1? line1_mem_regs_wdata_i:line1_regs_rdata1_i;

assign line1_regs_rdata2_o =  line1_line2_exe_relate2? line2_ex_regs_wdata_i :
	                          line1_line1_exe_relate2? line1_ex_regs_wdata_i:
	                          line1_line2_mm_relate2 ? line2_mm_regs_wdata_i :
	                          line1_line1_mm_relate2 ? line1_mm_regs_wdata_i :
	                          line1_line2_mem_relate2? line2_mem_regs_wdata_i:
	                          line1_line1_mem_relate2? line1_mem_regs_wdata_i:line1_regs_rdata2_i;	  

assign line2_regs_rdata1_o =  line2_line2_exe_relate1? line2_ex_regs_wdata_i :        
                              line2_line1_exe_relate1? line1_ex_regs_wdata_i:  
                              line2_line2_mm_relate1 ? line2_mm_regs_wdata_i :
                              line2_line1_mm_relate1 ? line1_mm_regs_wdata_i :             
                              line2_line2_mem_relate1? line2_mem_regs_wdata_i:        
                              line2_line1_mem_relate1? line1_mem_regs_wdata_i:line2_regs_rdata1_i;

assign line2_regs_rdata2_o =  line2_line2_exe_relate2? line2_ex_regs_wdata_i :
	                          line2_line1_exe_relate2? line1_ex_regs_wdata_i:
	                          line2_line2_mm_relate2 ? line2_mm_regs_wdata_i :
	                          line2_line1_mm_relate2 ? line1_mm_regs_wdata_i :
	                          line2_line2_mem_relate2? line2_mem_regs_wdata_i:
	                          line2_line1_mem_relate2? line1_mem_regs_wdata_i:line2_regs_rdata2_i;


assign line1_line1_exe_relate = line1_line1_exe_relate1 || line1_line1_exe_relate2;
assign line1_line2_exe_relate = line1_line2_exe_relate1 || line1_line2_exe_relate2;
assign line2_line1_exe_relate = line2_line1_exe_relate1 || line2_line1_exe_relate2;
assign line2_line2_exe_relate = line2_line2_exe_relate1 || line2_line2_exe_relate2;

assign line1_line1_mem_relate = line1_line1_mem_relate1 || line1_line1_mem_relate2;
assign line1_line2_mem_relate = line1_line2_mem_relate1 || line1_line2_mem_relate2;
assign line2_line1_mem_relate = line2_line1_mem_relate1 || line2_line1_mem_relate2;
assign line2_line2_mem_relate = line2_line2_mem_relate1 || line2_line2_mem_relate2;

assign line1_line1_mm_relate = line1_line1_mm_relate1 || line1_line1_mm_relate2;
assign line1_line2_mm_relate = line1_line2_mm_relate1 || line1_line2_mm_relate2;
assign line2_line1_mm_relate = line2_line1_mm_relate1 || line2_line1_mm_relate2;
assign line2_line2_mm_relate = line2_line2_mm_relate1 || line2_line2_mm_relate2;

//检测发生相关的数据是否已经准备好啦
assign line1_line1_regs_read_ready = ~( ( line1_line1_exe_relate && line1_exe_stall ) || (line1_line1_mem_relate && line1_mem_stall)|| (line1_line1_mm_relate && line1_mm_stall)  );
assign line1_line2_regs_read_ready = ~( ( line1_line2_exe_relate && line2_exe_stall ) || (line1_line2_mem_relate && line2_mem_stall)|| (line1_line2_mm_relate && line2_mm_stall)  );
assign line2_line1_regs_read_ready = ~( ( line2_line1_exe_relate && line1_exe_stall ) || (line2_line1_mem_relate && line1_mem_stall)|| (line2_line1_mm_relate && line1_mm_stall)  );    
assign line2_line2_regs_read_ready = ~( ( line2_line2_exe_relate && line2_exe_stall ) || (line2_line2_mem_relate && line2_mem_stall)|| (line2_line2_mm_relate && line2_mm_stall)  );    

//line1和linew2是否准备好了
assign line1_regs_read_ready_o = line1_line1_regs_read_ready & line1_line2_regs_read_ready ;
assign line2_regs_read_ready_o = line2_line1_regs_read_ready & line2_line2_regs_read_ready ;




















endmodule
