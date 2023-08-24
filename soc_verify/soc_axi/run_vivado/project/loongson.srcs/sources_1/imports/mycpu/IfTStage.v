
/*
*作者：zzq
*创建时间：2023-04-22
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：
*实现mmu的翻译和获取到cache访问的指令
*/
/*************\
bug:
\*************/
`include "define.v"
module IfTStage(
    input  wire                       clk                           ,
    input  wire                       rst_n                         ,
    //握手                                                                      
    input  wire                       next_allowin_i                ,                        
    input  wire                       line1_pre_to_now_valid_i      ,    

                                                                              
    output  wire                      line1_now_to_next_valid_o     ,          
    output  wire                      line2_now_to_next_valid_o     ,          
    output  wire                      now_allowin_o                 ,                        
    //冲刷                                                 
    input wire                        excep_flush_i                 , 
    
    output wire                       uncache_pre_error_flush_o     ,
    //错误`
        output wire                         error_o,   
                                                            
    //数据域                     
    input  wire                       inst_sram_data_ok_i           ,     
    input  wire [63:0]                inst_sram_rdata_i             ,  
    input  wire [`CacheDisposeInstNumWidth] cache_dispose_inst_num_i,
                          
    input  wire [`IfToNextBusWidth]       pre_to_ibus                   ,
    input  wire [`IfToNextSignleBusWidth] pre_to_next_signle_ibus       ,
    input  wire                           now_clk_pre_inst_ram_req_i    ,
    
    
    output wire  [`PucWbusWidth]        to_puc_obus,                  
    output wire [`PcBranchBusWidth]   to_preif_obus,                 
    output wire [`IfToICacheBusWidth] to_icache_obus                ,   
    output wire [`IftToNextBusWidth]   to_next_obus           
);

/***************************************input variable define(输入变量定义)**************************************/

wire [19:0]p_tag_i;
wire uncache_i;
wire inst_ram_req_i;
wire cache_refill_valid_i;

/***************************************output variable define(输出变量定义)**************************************/
wire [`PcWidth]branch_flush_pc_o;
wire branch_flush_o;

wire                        puc_we_o   ;
wire [`PucAddrWidth]        puc_waddr_o;
wire                        puc_wdata_o;




wire [19:0]p_tag_o;
wire uncache_o;
wire cache_refill_valid_o;

/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
//握手
    wire              now_allowin;
    wire              line2_now_to_next_valid,line1_now_to_next_valid;
    wire              line1_now_allowin;
    wire              line1_now_valid;
//数据  
    
    wire [`DoubleInstWidth]       line1_now_inst;
    wire [`LineIdToPreBusWidth]   line1_now_to_pre_obus;
    wire [`IfToNextBusWidth]      now_data_bus;
    wire                          now_uncache;
    wire [`PcBranchBusWidth]      line1_now_to_preif_obus;
    wire [`IfToNextSignleBusWidth]to_now_signle_data_bus;
//跳转信号
    wire              line2_branch_flush,line1_branch_flush;
    wire [`PcWidth]   line2_branch_pc,line1_branch_pc;
// 其他级输入信号
    wire [64:0] inst_buffer_rdata;    
//
wire  inst_buffer_we;
wire  [64:0]inst_buffer_wdata;


wire [1:0]wait_ce_ok_num;

wire now_inst_rdata_ce;

wire inst_sram_data_ok;
                                  
wire inst_buffer_data_ok;              
wire [63:0]inst_buffer_rinst; 


 wire ce_cs_eq_zero;
 

//pcu更新
wire puc_we;




/****************************************input decode(逻辑错误定义)***************************************/
wire error1,error2;
wire cdo_error;

wire   now_wait_data_ok;
assign now_wait_data_ok= line1_now_valid&inst_ram_req_i&~inst_buffer_data_ok;

wire [1:0] pipline_inst_num;
assign pipline_inst_num = now_wait_data_ok&now_clk_pre_inst_ram_req_i ?2'd2:
                          now_wait_data_ok|now_clk_pre_inst_ram_req_i?2'b1:2'b0;

wire [`CacheDisposeInstNumWidth]now_wait_data_ok_inst_num;
assign now_wait_data_ok_inst_num = wait_ce_ok_num + pipline_inst_num;


               
            
assign error1 = inst_buffer_data_ok&inst_sram_data_ok_i;
             
assign error2 =now_wait_data_ok_inst_num!=cache_dispose_inst_num_i;

 assign  error_o = error1|error2|cdo_error;
  /***************************************inner variable define(ILA)**************************************/
`ifdef OPEN_ILA 
    `ifdef OPEN_ILA_CPU_SIMPLY 
     
         (*mark_debug = "true"*) wire               ila_inst_sram_data_ok_i;
         (*mark_debug = "true"*) wire               ila_now_allowin_o;
         (*mark_debug = "true"*) wire               ila_inst_buffer_data_ok;
         (*mark_debug = "true"*) wire               ila_now_clk_pre_inst_ram_req_i;
         (*mark_debug = "true"*) wire               ila_line1_now_allowin;
         (*mark_debug = "true"*) wire               ila_ce_cs_eq_zero;
         
         assign ila_now_allowin_o               = now_allowin_o;
         assign ila_line1_now_allowin           = line1_now_allowin; 
         
         assign ila_inst_buffer_data_ok         = inst_buffer_data_ok;

         assign ila_inst_sram_data_ok_i        = inst_sram_data_ok_i;
         
         assign ila_ce_cs_eq_zero               = ce_cs_eq_zero;
                                                
        `ifdef OPEN_ILA_CPU_WHOLE  
                
               
         `endif
      `endif
 `endif  

/****************************************input decode(输入解码)***************************************/
/****************************************output code(输出解码)***************************************/
assign now_allowin_o  = now_allowin;
assign to_preif_obus   = {branch_flush_o,branch_flush_pc_o}; 
assign to_icache_obus = {cache_refill_valid_o,uncache_o,p_tag_o};
assign uncache_pre_error_flush_o=branch_flush_o;
assign to_puc_obus = {puc_we_o,puc_waddr_o,puc_wdata_o}; 
/*******************************complete logical function (逻辑功能实现)*******************************/
 // data_ok清理
 assign  now_uncache = uncache_i;
 assign flush        = excep_flush_i|branch_flush_o;
         
        Cdo Cdo_item(
           .clk                      ( clk    )                       ,
           .rst_n                    ( rst_n  )                       ,
                                                                      
           .flush_i                  ( flush )                        ,
           .branch_flush_i           ( 0 )                            ,
           .now_clk_pre_cache_req_i  ( now_clk_pre_inst_ram_req_i )   ,             
           .cache_rdata_ok_i         ( inst_sram_data_ok_i )          ,      
           .cache_buffer_rdata_ok_i  ( inst_buffer_data_ok)           ,    
           .now_wait_data_ok_i       ( now_wait_data_ok)              , 
           
           .error_o                  (cdo_error),
           .wait_ce_ok_num_o         (wait_ce_ok_num),                                                          
           .ce_cs_eq_zero_o          ( ce_cs_eq_zero)                 ,        
           .inst_rdata_ce_o          ( now_inst_rdata_ce)             
   
);
       
       
       
       
       
       
       
                                 
                                      
     assign inst_buffer_we     = ce_cs_eq_zero&(~flush)&inst_buffer_data_ok&(~next_allowin_i) ? 1'b0:1'b1;
     assign inst_buffer_wdata  = ce_cs_eq_zero&(~flush)&inst_sram_data_ok_i&(~next_allowin_i)?{inst_sram_data_ok_i,inst_sram_rdata_i}:{1'b0,64'd0};
  
        

 //PC缓存
    IfTSq IfTSq_item(
           //时钟信号
           .clk                         ( clk                      ),          
           .rst_n                       ( rst_n                    ),
           //握手信号                                                        
           .line1_pre_to_now_valid_i    ( line1_pre_to_now_valid_i ),
           
           .now_allowin_i               ( now_allowin              ),
                                                                   
           .line1_now_valid_o           ( line1_now_valid          ),
          
            //冲刷信号                                                         
           .excep_flush_i               ( excep_flush_i            ),
           .branch_flush_i               ( branch_flush_o            ),
           
           //上下级数据域
           .pre_to_signle_data_ibus     ( pre_to_next_signle_ibus  ),                                                        
           .pre_to_ibus                 ( pre_to_ibus              ),
                                                                   
           .to_now_signle_data_obus     ( to_now_signle_data_bus   ),
           .to_now_obus                 ( now_data_bus             ),
           //其他级数据域
                //cache读出数据缓存
           .inst_rdata_buffer_we_i      ( inst_buffer_we           ),
           .inst_rdata_buffer_i         ( inst_buffer_wdata        ),
         
           .inst_rdata_buffer_o         ( inst_buffer_rdata        )
               
        
        );
        
     assign {inst_ram_req_i,cache_refill_valid_i,uncache_i,p_tag_i} = to_now_signle_data_bus;
     
     assign inst_buffer_rinst    = inst_buffer_rdata[63:0];
     assign inst_buffer_data_ok  = inst_buffer_rdata[64];

   IfTCb IfTCb_item1(
         .rst_n                ( rst_n                     ),              
                               
         .next_allowin_i       ( next_allowin_i            ),
         .now_valid_i          ( line1_now_valid           ),
                               
         .now_allowin_o        ( line1_now_allowin         ),
         .now_to_next_valid_o  ( line1_now_to_next_valid   ),
         .line2_now_to_next_valid_o (line2_now_to_next_valid),
                              
         .excep_flush_i        ( excep_flush_i             ),
                               
         .pre_to_ibus          ( now_data_bus        ),
         .inst_data_i          ( line1_now_inst            ),
         .inst_sram_data_ok_i  ( inst_sram_data_ok         ),
                              
         .puc_we_o               (puc_we),
         .puc_waddr_o            (puc_waddr_o),
         .puc_wdata_o            (puc_wdata_o),
                         
         .to_next_obus         ( to_next_obus              ),
         .to_preif_obus        ( line1_now_to_preif_obus   ),
         .to_pre_obus          ( line1_now_to_pre_obus     )
   
   );
    assign {line1_branch_flush,line1_branch_pc} =line1_now_to_preif_obus;             
    assign {line2_branch_flush,line2_branch_pc} = 0;
     
       assign {branch_flush_o,branch_flush_pc_o} = ~now_allowin ? {1'b0,32'd0} :
                                line1_branch_flush ? {1'b1,line1_branch_pc} :
                                line2_branch_flush ? {1'b1,line2_branch_pc} : {1'b0,32'd0}; 
       assign puc_we_o = now_allowin&puc_we;
       
        
        assign inst_sram_data_ok = ((~now_inst_rdata_ce) & inst_sram_data_ok_i) | inst_buffer_data_ok ;
        
        assign line1_now_inst = inst_buffer_data_ok ? inst_buffer_rinst : inst_sram_rdata_i ;
        
         
         
         
         
         assign  p_tag_o = p_tag_i;
         assign  uncache_o = `CLOSE_ICACHE ? 1'b1:uncache_i;
         assign  cache_refill_valid_o =cache_refill_valid_i;
        
        
        //握手
            assign now_allowin               = ~ce_cs_eq_zero&now_clk_pre_inst_ram_req_i?1'b0: line1_now_allowin;
            assign line1_now_to_next_valid_o = line1_now_to_next_valid;
            assign line2_now_to_next_valid_o = line2_now_to_next_valid;
       
endmodule

