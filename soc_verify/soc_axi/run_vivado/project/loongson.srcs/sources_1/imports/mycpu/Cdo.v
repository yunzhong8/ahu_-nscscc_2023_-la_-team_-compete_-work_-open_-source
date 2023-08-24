/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：

*/
/*************\
bug:
\*************/
`include "define.v"
module Cdo
(
    input  wire  clk      ,
    input  wire  rst_n    ,
    
    
    input  wire       flush_i,                                  
    input  wire       branch_flush_i,                           
    input  wire       now_clk_pre_cache_req_i,                  
    input  wire       cache_rdata_ok_i,                         
    input  wire       cache_buffer_rdata_ok_i,                  
    input  wire       now_wait_data_ok_i,                       
    
    output wire [1:0]      wait_ce_ok_num_o,
    output wire error_o,
    output  wire ce_cs_eq_zero_o,
    output wire  inst_rdata_ce_o
   
);

/***************************************input variable define(输入变量定义)**************************************/
  

/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
wire [1:0]next_inst_rdata_ce_we;
wire [1:0] ce_cs;           
/****************************************input decode(输入解码)***************************************/
    
        
        
/****************************************output code(输出解码)***************************************/
/*******************************complete logical function (逻辑功能实现)*******************************/

  

CdoSq  CdoSq_it(
   .clk                 ( clk   ) ,
   .rst_n               ( rst_n ) ,
                        
   .inst_rdata_ce_we_i  (next_inst_rdata_ce_we) ,//10表示写，01表示使用过啦
   
   .ce_cs_o             (ce_cs),                    
   .inst_rdata_ce_o     (inst_rdata_ce_o) 
   
);
assign wait_ce_ok_num_o=ce_cs;

CdoCb CdoCb_item(
    
     .ce_cs_i                   (ce_cs                   ),       
     .flush_i                   (flush_i                 ),
     .branch_flush_i            (branch_flush_i          ),
     .now_clk_pre_cache_req_i   (now_clk_pre_cache_req_i ),
     .cache_rdata_ok_i          (cache_rdata_ok_i        ),
     .cache_buffer_rdata_ok_i   (cache_buffer_rdata_ok_i ),
     .now_wait_data_ok_i        (now_wait_data_ok_i      ),
       
     .error_o                   (error_o),  
     .ce_cs_eq_zero_o            (ce_cs_eq_zero_o),                                                   
     .next_inst_rdata_ce_we_o   ( next_inst_rdata_ce_we)  
   
);
    

endmodule
























