/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：

输入0条有效指令,则不移动
*/
/*************\
bug:
\*************/
//`include "DefineModuleBus.h"
`include "define.v"
module CdoCb
(
    
     input  wire [1:0]ce_cs_i,//10表示写，01表示使用过啦
     input  wire flush_i,
     input  wire branch_flush_i,
     input  wire now_clk_pre_cache_req_i,
     input  wire cache_rdata_ok_i,
     input  wire cache_buffer_rdata_ok_i,
     input  wire now_wait_data_ok_i,
    //队列写使能
    output  wire error_o,
    output  wire ce_cs_eq_zero_o,
    output  wire [1:0]next_inst_rdata_ce_we_o
   
);

/***************************************input variable define(输入变量定义)**************************************/


/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
wire ce_cs_eq_zero; 
wire ce_cs_eq_one;  
wire ce_cs_eq_two; 
wire error1,error2,error3,error4;

assign error1 = ~ce_cs_eq_zero&cache_buffer_rdata_ok_i ;
assign error2 =(ce_cs_eq_one| ce_cs_eq_two)&now_wait_data_ok_i ;
          
assign error3 = ce_cs_eq_two&now_clk_pre_cache_req_i;
           
assign error4 =cache_rdata_ok_i&~now_wait_data_ok_i&ce_cs_eq_zero;

assign error_o =error1|error2|error3|error4;
/****************************************input decode(输入解码)***************************************/

        
/****************************************output code(输出解码)***************************************/

      assign ce_cs_eq_zero = ce_cs_i==2'b00;
      assign ce_cs_eq_one  = ce_cs_i==2'b01;
      assign ce_cs_eq_two  = ce_cs_i==2'b10;
      
      
      assign next_inst_rdata_ce_we_o =  ( (
                                            ce_cs_eq_zero & (
                                                                flush_i& (
                                                                            now_wait_data_ok_i&( 
                                                                                                now_clk_pre_cache_req_i  &cache_rdata_ok_i 
                                                                                                |~now_clk_pre_cache_req_i&~cache_rdata_ok_i
                                                                                             ) 
                                                                            |(~now_wait_data_ok_i)&now_clk_pre_cache_req_i 
                                                                       )            
                                                            )
                                        )
                                        |(ce_cs_eq_one&flush_i&(now_wait_data_ok_i|now_clk_pre_cache_req_i)&~cache_rdata_ok_i) 
                                      ) ? 2'b10:
                                    
                                      (ce_cs_eq_zero& flush_i&(now_wait_data_ok_i&now_clk_pre_cache_req_i)&(~cache_buffer_rdata_ok_i&~cache_rdata_ok_i)
                                      ) ? 2'b11:
                                      
                                      ( (ce_cs_eq_one &( (flush_i&(~now_wait_data_ok_i&~now_clk_pre_cache_req_i)&cache_rdata_ok_i)
                                                         |((~flush_i)&cache_rdata_ok_i)
                                                       )
                                        )   
                                        |(ce_cs_eq_two&cache_rdata_ok_i)
                                      ) ?2'b01:2'b00;
                                      
                                      

assign ce_cs_eq_zero_o=ce_cs_eq_zero;
endmodule
























