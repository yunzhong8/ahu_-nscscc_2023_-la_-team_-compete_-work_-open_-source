/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：本级要求返回的数据是寄存器中立马读出的，不能经过任何组合逻辑，这样时延就不会叠加
根据输入的指令立马解码出控制信号
*控制信号:


*/
/*************\

\*************/

`include "define.v"
module IfTCb(
    input  wire                            rst_n                ,
    
    input wire                             next_allowin_i       ,
    input wire                             now_valid_i          ,
    
    output wire                            now_allowin_o        ,
    output wire                            now_to_next_valid_o  ,
    output wire                            line2_now_to_next_valid_o,
    
    
    input wire                             excep_flush_i        ,
    
    input wire  [`IfToNextBusWidth]        pre_to_ibus          ,
    input wire  [63:0]                     inst_data_i          ,
    input wire                             inst_sram_data_ok_i  ,
   
    output wire                        puc_we_o   ,                   
    output wire [`PucAddrWidth]        puc_waddr_o, 
    output wire                        puc_wdata_o,                
    
    
    
    output wire  [`PucWbusWidth]            to_puc_obus,      
    output wire [`IftToNextBusWidth]        to_next_obus         ,
    output wire [`LineIftToPreBusWidth]     to_pre_obus          ,
    output wire [`IftToPreifBusWidth]       to_preif_obus
    
);

/***************************************input variable define(输入变量定义)**************************************/
   
    wire [`PcWidth]pc1_i;
    wire [`PcWidth]pc2_i;
    wire [`InstWidth]inst1_i;
    wire [`InstWidth]inst2_i;
    wire inst_ram_req_i;
    wire pre_uncache_i;//预测的uncache
    wire uncache_i;
    
    
    
    //分支预测器
 wire branch_i ;
 wire btb_hit_i;
 wire [`PcWidth]btb_branch_pc_i;
 wire [`ScountStateWidth]pht_state_i;
    
    //例外信号
    wire [`ExceptionTypeWidth]line1_excep_type_i;
    wire line1_excep_en_i;
    wire [`ExceptionTypeWidth]line2_excep_type_i;
    wire line2_excep_en_i;
    
    
    
    

/***************************************ioutput variable define(输出变量定义)**************************************/
   
    wire [`LineIftToNextBusWidth] line2_to_next_bus,line1_to_next_bus;
    // 跳转   
    wire [`PcWidth]        branch_addr_o;

   
    //例外信号
    wire [`ExceptionTypeWidth]line1_excep_type_o;
    wire line1_excep_en_o;
    wire [`ExceptionTypeWidth]line2_excep_type_o;
    wire line2_excep_en_o;
    

/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
// 握手信号
    wire now_ready_go;
  
 wire now_ctl_valid;  
 wire now_ctl_base_valid;  
 wire line2_en;
 
 wire uncache;

    wire branch_flush_flag;   
    
  wire line1_pc_is_odd=pc1_i[2];
  /***************************************inner variable define(ILA)**************************************/
`ifdef OPEN_ILA 
    `ifdef OPEN_ILA_CPU_SIMPLY 
         (*mark_debug = "true"*) wire [`PcWidth]    ila_pc1_i;
         (*mark_debug = "true"*) wire               ila_now_ready_go;
         (*mark_debug = "true"*) wire               ila_now_valid_i;
         (*mark_debug = "true"*) wire               ila_now_to_next_valid_o;
         (*mark_debug = "true"*) wire               ila_now_allowin_o;
         (*mark_debug = "true"*) wire               ila_next_allowin_i;  
         
          
         (*mark_debug = "true"*) wire               ila_inst_ram_req_i;
         (*mark_debug = "true"*) wire               ila_inst_sram_data_ok_i;
         
         assign ila_pc1_i                       = pc1_i;
         assign ila_now_ready_go                = now_ready_go;
         assign ila_now_valid_i                 = now_valid_i;
                    
         assign ila_now_to_next_valid_o         = now_to_next_valid_o;
         
         assign ila_now_allowin_o               = now_allowin_o;
         assign ila_next_allowin_i              = next_allowin_i;
         
         assign ila_inst_ram_req_i              = inst_ram_req_i;
         assign  ila_inst_sram_data_ok_i        = inst_sram_data_ok_i;
         
                                                
        `ifdef OPEN_ILA_CPU_WHOLE  
                
               
         `endif
      `endif
 `endif 
/****************************************input decode(输入解码)***************************************/
   
    assign {pre_uncache_i,uncache_i,inst_ram_req_i,
            branch_i,btb_hit_i,pht_state_i,btb_branch_pc_i,
            line2_excep_en_i,line2_excep_type_i,pc2_i,
            line1_excep_en_i,line1_excep_type_i,pc1_i
    
    } = pre_to_ibus;
            
         
            
            
    
    assign inst1_i = ({32{line1_pc_is_odd}}&inst_data_i[63:32])|({32{~line1_pc_is_odd}}&inst_data_i[31:0]);
    assign inst2_i = inst_data_i[63:32];
/****************************************output code(输出解码)***************************************/
    assign to_pre_obus  = branch_flush_flag_o;
    assign line1_to_next_bus = {
        branch_i,btb_hit_i,pht_state_i,btb_branch_pc_i,
        line1_excep_en_o,line1_excep_type_o,pc1_i,inst1_i
        };
   assign line2_to_next_bus = {
        branch_i,btb_hit_i,pht_state_i,btb_branch_pc_i,
        line2_excep_en_o,line2_excep_type_o,pc2_i,inst2_i
        };
    assign to_next_obus = { line2_to_next_bus,line1_to_next_bus};
    
    assign to_preif_obus = {branch_flush_flag_o,branch_addr_o};

   assign to_puc_obus = {puc_we_o,puc_waddr_o,puc_wdata_o}; 
   
   assign uncache= `CLOSE_ICACHE ? 1'b1:uncache_i;
    
/*******************************complete logical function (逻辑功能实现)*******************************/
    
       //uncache预测错误                                          
       assign branch_flush_flag   = line1_pc_is_odd?1'b0:pre_uncache_i^uncache;
                                                                           
       assign branch_flush_flag_o = branch_flush_flag & now_ctl_valid&now_allowin_o ; 
       //
                  
       assign branch_addr_o       = uncache&~pre_uncache_i ? pc2_i: pc2_i+32'd4;  
     
       //update pcu
       assign puc_we_o    = pre_uncache_i^uncache& now_ctl_valid;
       assign puc_waddr_o = pc1_i[16:12];
       assign puc_wdata_o = uncache;
     //例外
    
       
       assign line1_excep_en_o  = line1_excep_en_i && now_valid_i;
       assign line1_excep_type_o= line1_excep_type_i;
        
       assign line2_excep_en_o  =  line2_excep_en_i && now_valid_i;
       assign line2_excep_type_o=  line2_excep_type_i;
      //
      assign line2_en =  uncache?1'b0:( line1_pc_is_odd?1'b0:1'b1);
     //指令有效信号

     assign now_ctl_valid      = now_ctl_base_valid &(~line1_excep_en_i);
     assign now_ctl_base_valid = now_valid_i & (~excep_flush_i);
    
     
     // 握手
      assign now_ready_go        = inst_ram_req_i ? (inst_sram_data_ok_i ? 1'b1:1'b0):1'b1; 
      assign now_allowin_o       = !now_valid_i 
                                   || (now_ready_go && next_allowin_i);
      assign now_to_next_valid_o       = now_valid_i && now_ready_go;
      assign line2_now_to_next_valid_o = line2_en&now_valid_i && now_ready_go;
 
    

endmodule

