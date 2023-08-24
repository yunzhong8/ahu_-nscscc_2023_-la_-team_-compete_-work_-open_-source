/*
*作者：zzq
*创建时间：2023-03-31
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
module PreIF(
    input wire                        rst_n               ,
    input wire                        next_allowin_i      ,
    output                            now_to_next_valid_o ,
    
   
    input wire                        excep_flush_i       ,
    //CPU错误
    input wire cpu_error_i,

    input  wire  [`IfToPreBusWidth]   if_to_ibus          ,
    input  wire [`IftToPreifBusWidth]  ift_to_ibus          ,
    //跳转
    input  wire [`IdToPreifBusWidth]  id_to_ibus          ,
    input  wire interrupt_en_i,
    
    //例外返回
    input  wire [`CsrToPreifWidth]    csr_to_ibus         ,
    input  wire [`PcBufferBusWidth]   pcbuffer_to_ibus    ,
    input  wire                       inst_ram_addr_ok_i  ,
   
    output wire                       inst_sram_req_o     ,
    output wire [`PcWidth]            inst_sram_raddr_o   ,
    output wire [`PcBufferBusWidth]   to_pcbuffer_obus    ,   
    output wire [`PreifToNextBusWidth]to_next_obus       
    
);

/***************************************input variable define(输入变量定义)**************************************/
    wire branch_flag_i;
    wire [`PcWidth]branch_pc_i;
    
    wire [`PcWidth]excep_entry_pc_i;  
    wire [`PcWidth]ertn_pc_i       ;  
    wire [`PcWidth]tlb_inst_flush_entry_pc_i;
    wire tlb_inst_flush_en_i;
    wire excep_en_i; 
    wire ertn_en_i       ; 
    
    wire pc_buffer_we_i;
    wire [`PcWidth]pc_buffer_pc_i;
    wire order_we_i;
    wire [`PcWidth]order_pc_i;
    
    wire ift_we_i;
    wire [`PcWidth]ift_pc_i;
    
    //
    wire stall_i;
    wire [`PcWidth]stall_pc_i;
    
/***************************************output variable define(输出变量定义)**************************************/
    wire [`PcWidth]pc1_o;
    wire [`PcWidth]pc2_o;
    //缓存
    wire pc_buffer_we_o;
    wire [`PcWidth]pc_buffer_wdata_o;
    //例外
    wire line1_excpet_en_o ;
    wire [`ExceptionTypeWidth]line1_excep_type_o;
   
    
    wire line2_excpet_en_o ;
    wire [`ExceptionTypeWidth]line2_excep_type_o;
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
wire now_ready_go ;

/***************************************inner variable define(ILA)**************************************/
`ifdef OPEN_ILA 
    `ifdef OPEN_ILA_CPU_SIMPLY 
         (*mark_debug = "true"*) wire [`PcWidth]    ila_pc1_o;//preif级输出的pc
         (*mark_debug = "true"*) wire               ila_now_ready_go;
         (*mark_debug = "true"*) wire               ila_inst_sram_req_o;//向外部ram发请求
         (*mark_debug = "true"*) wire               ila_inst_ram_addr_ok_i;//外部ram返回ok表示地址已经接收
         
         assign ila_pc1_o              = pc1_o;
         assign ila_now_ready_go       = now_ready_go;
         assign ila_inst_sram_req_o    = inst_sram_req_o;
         assign ila_inst_ram_addr_ok_i = inst_ram_addr_ok_i;
         
        `ifdef OPEN_ILA_CPU_WHOLE  
                (*mark_debug = "true"*) wire               ila_order_we_i;          
                (*mark_debug = "true"*) wire [`PcWidth]    ila_order_pc_i;
 
                (*mark_debug = "true"*) wire               ila_ift_we_i;           
                (*mark_debug = "true"*) wire [`PcWidth]    ila_ift_pc_i; 
 
                (*mark_debug = "true"*) wire               ila_branch_flag_i;        
                (*mark_debug = "true"*) wire [`PcWidth]    ila_branch_pc_i;
 
                (*mark_debug = "true"*) wire [`PcWidth]    ila_tlb_inst_flush_entry_pc_i;       
                (*mark_debug = "true"*) wire               ila_tlb_inst_flush_en_i;   
                
                assign ila_order_we_i                = order_we_i                     ;
                assign ila_order_pc_i                = order_pc_i                 ;       
                                                          
                assign ila_ift_we_i                  =  ift_we_i                  ;
                assign ila_ift_pc_i                  =  ift_pc_i                  ;
                                           
                assign ila_branch_flag_i             = branch_flag_i              ;     
                assign ila_branch_pc_i               = branch_pc_i                ;  
                                      
                assign ila_tlb_inst_flush_entry_pc_i = tlb_inst_flush_entry_pc_i  ;
                assign ila_tlb_inst_flush_en_i       = tlb_inst_flush_en_i        ;    
          `endif
      `endif
 `endif                      
  
/****************************************input decode(输入解码)***************************************/
assign {branch_flag_i,branch_pc_i} = id_to_ibus;
assign {stall_i,stall_pc_i,tlb_inst_flush_en_i,tlb_inst_flush_entry_pc_i,excep_en_i,ertn_en_i,excep_entry_pc_i,ertn_pc_i} = csr_to_ibus;
assign {order_we_i,order_pc_i} = if_to_ibus;
assign {ift_we_i,ift_pc_i} = ift_to_ibus;
assign {pc_buffer_we_i,pc_buffer_pc_i} = pcbuffer_to_ibus;
/****************************************output code(输出解码)***************************************/
assign to_next_obus = {inst_sram_req_o,line2_excpet_en_o,line2_excep_type_o,pc2_o,
                                       line1_excpet_en_o,line1_excep_type_o,pc1_o};

assign inst_sram_req_o  = rst_n && next_allowin_i && (!excep_flush_i) && !line1_excpet_en_o &&~stall_i;
assign to_pcbuffer_obus = {pc_buffer_we_o,pc_buffer_wdata_o};
/*******************************complete logical function (逻辑功能实现)*******************************/

 assign pc1_o = 
               stall_i        ? stall_pc_i:
               excep_en_i     ? excep_entry_pc_i :          
               ertn_en_i      ? ertn_pc_i        :
               tlb_inst_flush_en_i ? tlb_inst_flush_entry_pc_i:
               branch_flag_i  ? branch_pc_i : 
               ift_we_i       ?ift_pc_i:            
               order_we_i     ?  order_pc_i+32'd4  : 
               pc_buffer_we_i ? pc_buffer_pc_i  : order_pc_i+32'd4;       
               
               
               

assign pc2_o = pc1_o +32'd4;

assign line1_excpet_en_o  = interrupt_en_i;
assign line1_excep_type_o[`IntEcode]                     = interrupt_en_i ? 1'b1 : 1'b0;//0
assign line1_excep_type_o[`IfPpiLocation:`PilLocation]     = 0;

assign inst_sram_raddr_o = pc1_o;


assign line2_excpet_en_o = 1'b0;
assign line2_excep_type_o = `ExceptionTypeLen 'd 0;


assign pc_buffer_we_o =(!inst_sram_req_o) || (inst_sram_req_o && (!inst_ram_addr_ok_i));
assign pc_buffer_wdata_o = pc1_o;

//握手信号

assign now_ready_go        = ~cpu_error_i&((inst_sram_req_o & inst_ram_addr_ok_i&~stall_i) || (line1_excpet_en_o)); 
assign now_to_next_valid_o = now_ready_go;
            
endmodule
