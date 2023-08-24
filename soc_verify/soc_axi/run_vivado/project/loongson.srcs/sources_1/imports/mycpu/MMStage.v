
/*
*作者：zzq
*创建时间：2023-04-22
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：
*当前时钟周期是跳转信号的时候，如果当前流水正好要流向下一级，这设置now_to_valid=0，if 不是则设在preif_if中now_valid=0
*/
/*************\
\*************/
`include "define.v"
module MMStage(
    input  wire                       clk                           ,
    input  wire                       rst_n                         ,
    //握手                                                                      
    input  wire                       next_allowin_i                ,                        
    input  wire                       line1_pre_to_now_valid_i      ,    
    input  wire                       line2_pre_to_now_valid_i      ,
                                                                              
    output  wire                      line1_now_to_next_valid_o     ,          
    output  wire                      line2_now_to_next_valid_o     ,          
    output  wire                      now_allowin_o                 ,  
    output  wire                      now_valid_o,                      
    //冲刷                                                 
    input wire                        excep_flush_i                 ,                       
                                                         
    //数据域                     
                    
    input  wire [`ExToNextBusWidth]   pre_to_ibus                   ,
    input  wire [`MemToPreBusWidth]   next_to_ibus                  ,
    input  wire [`MmuToMemBusWidth]   mmu_to_ibus                   ,   
    
    output wire                       store_buffer_ce_o             ,
    output wire                       now_clk_pre_cache_req_o       ,
    output wire [`MemToMmuBusWidth]   to_mmu_obus                   ,
    output wire [`MmForwardBusWidth]  forward_obus                  ,                 
    output wire [`MmToNextBusWidth]   to_next_obus           
);

/***************************************input variable define(输入变量定义)**************************************/


/***************************************output variable define(输出变量定义)**************************************/
   
   wire [`LineMmForwardBusWidth]             line2_forward_obus,line1_forward_obus; 

/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
//握手
    wire              line2_now_valid,line1_now_valid;
    wire              line2_now_to_next_valid,line1_now_to_next_valid;
    wire              line2_now_allowin,line1_now_allowin;
    
//数据
    wire  [`LineExToNextBusWidth]    now_line2_data_bus,now_line1_data_bus;    
    wire  [`LineMmToNextBusWidth]    line2_now_to_next_obus,line1_now_to_next_obus; 
   
    wire              line2_now_to_pre_obus,line1_now_to_pre_obus;
    wire   [`ExToNextBusWidth]           now_data_bus;

/***************************************inner variable define(ILA)**************************************/
wire [`LineMmtOIlaBusWidth]line1_to_ila_bus,line2_to_ila_bus;

 `ifdef OPEN_ILA 
    `ifdef OPEN_ILA_CPU_SIMPLY 
         (*mark_debug = "true"*) wire [`PcWidth]    ila_pc1_i;//preif级输出的pc
         (*mark_debug = "true"*) wire [`InstWidth]  ila_inst_i;

         (*mark_debug = "true"*) wire               ila_now_valid_i;
         (*mark_debug = "true"*) wire               ila_now_to_next_valid_o;
         (*mark_debug = "true"*) wire               ila_now_allowin_o;
         (*mark_debug = "true"*) wire               ila_next_allowin_i;   
         
        
         assign {ila_inst_i,ila_pc1_i}          = line1_to_ila_bus;

         assign ila_now_valid_i                 = line1_now_valid;
                    
         assign ila_now_to_next_valid_o         = line1_now_to_next_valid;         
         assign ila_now_allowin_o               = now_allowin_o;
         assign ila_next_allowin_i              = next_allowin_i;
         
                                                
        `ifdef OPEN_ILA_CPU_WHOLE  
                
               
          `endif
      `endif
 `endif 
/****************************************input decode(输入解码)***************************************/
assign {banch_flush_i} = next_to_ibus;
/****************************************output code(输出解码)***************************************/
assign forward_obus  = {line2_forward_obus,line1_forward_obus};
assign to_next_obus = {line2_now_to_next_obus,line1_now_to_next_obus};
/*******************************complete logical function (逻辑功能实现)*******************************/
 
       
 //PC缓存
    MMSq MMSq_item(
           .clk                         ( clk                      ),          
           .rst_n                       ( rst_n                    ),
                                                                   
           .line1_pre_to_now_valid_i    ( line1_pre_to_now_valid_i ),
           .line2_pre_to_now_valid_i    ( line2_pre_to_now_valid_i ),
           .now_allowin_i               ( now_allowin_o              ),
                                                                   
           .line1_now_valid_o           ( line1_now_valid          ),
           .line2_now_valid_o           ( line2_now_valid          ),
                                                                    
           .excep_flush_i               ( excep_flush_i            ),
           .banch_flush_i               (1'b0),                                                        
           .pre_to_ibus                 ( pre_to_ibus              ),
                                                                   
           .to_now_obus                 ( now_data_bus             )
        
        );
     assign {now_line2_data_bus ,now_line1_data_bus } =now_data_bus;

   MMCb MMCb_item1(
                                           
         .next_allowin_i       ( next_allowin_i            ),
         .now_valid_i          ( line1_now_valid           ),
                               
         .now_allowin_o        ( line1_now_allowin         ),
         .now_to_next_valid_o  ( line1_now_to_next_valid   ),
                              
         .excep_flush_i        ( excep_flush_i             ),
                               
         .pre_to_ibus          ( now_line1_data_bus        ),
         .mmu_to_ibus          ( mmu_to_ibus               ),
         
          .to_ila_obus         (line1_to_ila_bus),
         .store_buffer_ce_o       (store_buffer_ce_o      ),
         .now_clk_pre_cache_req_o (now_clk_pre_cache_req_o),
         .forward_obus         ( line1_forward_obus        ),
         .to_mmu_obus          ( to_mmu_obus               ),                     
         .to_next_obus         ( line1_now_to_next_obus    ),
         .to_pre_obus          ( line1_now_to_pre_obus     )
   
   );
   
    MMCb MMCb_item2(                                                        
                                                                                 
          .next_allowin_i       ( next_allowin_i            ),              
          .now_valid_i          ( line2_now_valid           ),              
                                                                            
          .now_allowin_o        ( line2_now_allowin         ),              
          .now_to_next_valid_o  ( line2_now_to_next_valid   ),              
                                                                            
          .excep_flush_i        ( excep_flush_i             ),              
                                                                            
          .pre_to_ibus          ( now_line2_data_bus        ),  
          .mmu_to_ibus          ( 0                         ),            
                
          .forward_obus         ( line2_forward_obus        ),                                                                       
          .to_next_obus         ( line2_now_to_next_obus    ),              
          .to_pre_obus          ( line2_now_to_pre_obus     )               
                                                                            
    );                                                                      
   
   //握手
   assign now_valid_o  = line1_now_valid|line2_now_valid;
   assign now_allowin_o = line2_now_allowin&line1_now_allowin;
   assign line1_now_to_next_valid_o = line1_now_to_next_valid;
   assign line2_now_to_next_valid_o = line2_now_to_next_valid;
   
   
         
endmodule

