/*
*作者：zzq
*创建时间：2023-04-22
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：
*
*/
/*************\

\*************/
`include "define.v"
module IfStage(
    input   wire                        clk                          ,
    input   wire                        rst_n                        ,
                                                                        
    input   wire                        next_allowin_i               ,                        
    input   wire                        pre_to_now_valid_i           ,   
              
                                                                               
    output  wire                        line1_now_to_next_valid_o    ,          
          
    output  wire                        now_allowin_o                ,                        
                                                                          
    input   wire                        excep_flush_i                , 
    input   wire                        other_flush_i                ,
                            
                                          
    input  wire [`PreifToNextBusWidth]  pre_to_ibus                  ,
       
  
    
    input  wire [`MmuToIfBusWidth]      mmu_to_ibus                  ,
    input  wire [`PrToIfBusWidth]       pr_to_ibus                   ,
    input  wire                            pre_uncache_i,
    output wire [`PucAddrWidth]                      puc_raddr_o,

    output wire                         if_now_clk_ram_req_o         ,                                                                   
    output wire [`IfToPreBusWidth]      to_pre_obus                  ,
    output wire [`IfToMmuBusWidth]      to_mmu_obus                  ,
    output wire [`IfToNextSignleBusWidth]   to_next_signle_data_obus     ,  
    output wire [`IfToNextBusWidth]     to_next_obus                 
);

/***************************************input variable define(输入变量定义)**************************************/

/***************************************output variable define(输出变量定义)**************************************/

/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
wire now_valid;
wire [`PreifToNextBusWidth]pre_to_bus;


wire branch_flush;

wire pr_buffer_we;
wire [`PrToIfDataBusWidth]pr_data;
wire [`PrToIfDataBusWidth]pr_to_if_data;
/****************************************input decode(输入解码)***************************************/
/****************************************output code(输出解码)***************************************/
/*******************************complete logical function (逻辑功能实现)*******************************/
 
       
 //PC缓存
    Preif_IF Preif_IFI(
        
        .rst_n (rst_n),
        .clk  (clk),
        
        .preif_to_if_valid_i(pre_to_now_valid_i),
        .if_allowin_i(now_allowin_o),
        .if_valid_o(now_valid),
        
        .excep_flush_i(excep_flush_i),
        .banch_flush_i(branch_flush),
        
        
        .preif_to_ibus (pre_to_ibus ),     
        .to_if_obus (pre_to_bus),
        
        
        .pr_we_i(pr_buffer_we),
        .pr_data_i(pr_to_ibus[`PrToIfDataBusWidth]),
        
        .pr_data_o  (pr_data)   
        
        );
    

    IF IFI(
        
        .next_allowin_i(next_allowin_i),
        .now_valid_i(now_valid),
        
        .now_allowin_o(now_allowin_o),
        .line1_now_to_next_valid_o(line1_now_to_next_valid_o),
        .line2_now_to_next_valid_o(line2_now_to_next_valid_o),
        
        
        .excep_flush_i(excep_flush_i),
        .branch_flush_i(other_flush_i),
        
        
        .pre_to_ibus(pre_to_bus),
        .pre_uncache_i(pre_uncache_i),
        
        .if_now_clk_ram_req_o(if_now_clk_ram_req_o),
        .to_preif_obus(to_pre_obus),
        .to_next_obus(to_next_obus),
        .to_next_signle_data_obus(to_next_signle_data_obus),
        
        
       
        .puc_raddr_o(puc_raddr_o),
        .mmu_to_ibus(mmu_to_ibus),
        .pr_data_i (pr_to_if_data),
               
        .to_mmu_obus(to_mmu_obus)
       
        
        );
        

    assign branch_flush = other_flush_i&~now_allowin_o;
   
        assign pr_buffer_we = pr_to_ibus[`PrToIfDataBusLen] &~ now_allowin_o;
        
        assign pr_to_if_data =  pr_to_ibus[`PrToIfDataBusLen] ? pr_to_ibus[`PrToIfDataBusWidth] : pr_data;
       
endmodule
