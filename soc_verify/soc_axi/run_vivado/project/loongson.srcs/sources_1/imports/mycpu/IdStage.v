
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
bug:
\*************/
`include "define.v"
module IdStage(
    input  wire                       clk                           ,
    input  wire                       rst_n                         ,
    //握手                                                                      
    input  wire                       next_allowin_i                ,                        
    input  wire                       line1_pre_to_now_valid_i      ,    
    input  wire                       line2_pre_to_now_valid_i      ,
                                                                              
    output  wire                      line1_now_to_next_valid_o     ,          
    output  wire                      line2_now_to_next_valid_o     ,          
    output  wire                      now_allowin_o                 ,                        
    //冲刷                                                 
    input wire                        excep_flush_i                 , 
    output wire                       branch_flush_o,
    //错误`
    output wire                         error_o,   
                                                            
    //数据域                                          
    input  wire [`IftToNextBusWidth]       pre_to_ibus                   ,
   
                  
    output wire [`PcBranchBusWidth]   to_preif_obus,                 
    
    output wire [`IdToNextBusWidth]   to_next_obus           
);

/***************************************input variable define(输入变量定义)**************************************/



/***************************************output variable define(输出变量定义)**************************************/
wire [`PcWidth]branch_flush_pc_o;

/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
//握手
    wire              now_allowin;
    wire              line2_now_to_next_valid,line1_now_to_next_valid;
    wire              line2_now_allowin,line1_now_allowin;
    wire              line2_now_valid,line1_now_valid;
//数据
    wire [`LineIftToNextBusWidth]  now_line2_data_bus,now_line1_data_bus;    
    wire [`LineIdToNextBusWidth]  line2_now_to_next_obus,line1_now_to_next_obus; 
    wire [`LineIdToPreBusWidth]   line2_now_to_pre_obus,line1_now_to_pre_obus;
    wire [`IftToNextBusWidth]     now_data_bus;
    wire [`PcBranchBusWidth]      line2_now_to_preif_obus,line1_now_to_preif_obus;
//跳转信号
    wire              line2_branch_flush,line1_branch_flush;
    wire [`PcWidth]   line2_branch_pc,line1_branch_pc;



/****************************************input decode(逻辑错误定义)***************************************/
 assign  error_o = 0;
 
 
/***************************************inner variable define(ILA)**************************************/
    wire [`LineIdtOIlaBusWidth]line1_to_ila_bus,line2_to_ila_bus;
 `ifdef OPEN_ILA 
    `ifdef OPEN_ILA_CPU_SIMPLY 
         (*mark_debug = "true"*) wire [`PcWidth]    ila_pc1_i;
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

/****************************************output code(输出解码)***************************************/
assign now_allowin_o  = now_allowin;
assign to_preif_obus  = {branch_flush_o,branch_flush_pc_o};
assign to_next_obus   = {line2_now_to_next_obus,line1_now_to_next_obus};
/*******************************complete logical function (逻辑功能实现)*******************************/

  

    IdSq IdSq_item(
           //时钟信号
           .clk                         ( clk                      ),          
           .rst_n                       ( rst_n                    ),
           //握手信号                                                        
           .line1_pre_to_now_valid_i    ( line1_pre_to_now_valid_i ),
           .line2_pre_to_now_valid_i    ( line2_pre_to_now_valid_i ),
           .now_allowin_i               ( now_allowin              ),
                                                                   
           .line1_now_valid_o           ( line1_now_valid          ),
           .line2_now_valid_o           ( line2_now_valid          ),
            //冲刷信号                                                         
           .excep_flush_i               ( excep_flush_i            ),
           .branch_flush_i              ( branch_flush_o           ),
           
           //上下级数据域                                 
           .pre_to_ibus                 ( pre_to_ibus              ),                                                    
           .to_now_obus                 ( now_data_bus             )
          
        
        );
        
     assign {now_line2_data_bus,now_line1_data_bus} = now_data_bus ;
    

   IdCb IdCb_item1(
         .rst_n                ( rst_n                     ),              
                               
         .next_allowin_i       ( next_allowin_i            ),
         .now_valid_i          ( line1_now_valid           ),
                               
         .now_allowin_o        ( line1_now_allowin         ),
         .now_to_next_valid_o  ( line1_now_to_next_valid   ),
                              
         .excep_flush_i        ( excep_flush_i             ),
                               
         .pre_to_ibus          ( now_line1_data_bus        ),
        
         
         .to_ila_obus          ( line1_to_ila_bus          ),                    
         .to_next_obus         ( line1_now_to_next_obus    ),
         .to_preif_obus        ( line1_now_to_preif_obus   ),
         .to_pre_obus          ( line1_now_to_pre_obus     )
   
   );
    assign {line1_branch_flush,line1_branch_pc} =line1_now_to_preif_obus;
    
    IdCb IdCb_item2(                                                        
          .rst_n                ( rst_n                        ),              
                                                                               
          .next_allowin_i       ( next_allowin_i               ),              
          .now_valid_i          ( line2_now_valid              ),              
                                                                            
          .now_allowin_o        ( line2_now_allowin            ),              
          .now_to_next_valid_o  ( line2_now_to_next_valid      ),              
                                                                               
          .excep_flush_i        ( excep_flush_i                ),              
                                                                               
          .pre_to_ibus          ( now_line2_data_bus           ),              
          
            
                                                                               
          .to_next_obus         ( line2_now_to_next_obus       ),  
          .to_preif_obus        ( line2_now_to_preif_obus      ),            
          .to_pre_obus          ( line2_now_to_pre_obus        )               
                                                                            
    );                                                                      
     assign {line2_branch_flush,line2_branch_pc} = line2_now_to_preif_obus;
      
       assign {branch_flush_o,branch_flush_pc_o} = ~now_allowin ? {1'b0,32'd0} :
                                line1_branch_flush ? {1'b1,line1_branch_pc} :
                                line2_branch_flush ? {1'b1,line2_branch_pc} : {1'b0,32'd0}; 
       
       
         
        
        
        //握手
            assign now_allowin               = line2_now_allowin & line1_now_allowin;
            assign line1_now_to_next_valid_o = line1_now_to_next_valid;
            assign line2_now_to_next_valid_o = line2_now_to_next_valid &(~line1_branch_flush);
        
       
endmodule

