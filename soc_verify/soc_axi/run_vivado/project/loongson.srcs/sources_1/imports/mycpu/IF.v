/*
*作者：zzq
*创建时间：2023-04-06
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
module IF(
    input  wire next_allowin_i             ,
    input  wire now_valid_i                ,
 
    output wire now_allowin_o             ,
    output wire line1_now_to_next_valid_o ,
    output wire line2_now_to_next_valid_o ,
    //冲刷信号
    input  wire excep_flush_i             ,
    input  wire branch_flush_i            ,
   
    
 
    input  wire [`PreifToNextBusWidth]     pre_to_ibus             ,

   
    input  wire [`MmuToIfBusWidth]         mmu_to_ibus             ,
    //预测器输入
    input  wire [`PrToIfDataBusWidth]      pr_data_i               ,
    input  wire                            pre_uncache_i,
    
    output wire [`PucAddrWidth]                      puc_raddr_o,
    output wire                            if_now_clk_ram_req_o         ,
    output wire [`IfToMmuBusWidth]         to_mmu_obus             ,
    output wire [`IfToPreBusWidth]         to_preif_obus           ,
    output wire [`IfToNextSignleBusWidth]  to_next_signle_data_obus,
    output wire [`IfToNextBusWidth]        to_next_obus
         
);

/***************************************input variable define(输入变量定义)**************************************/
wire [`PcWidth]pc1_i;
wire [`PcWidth]pc2_i;

wire [`ExceptionTypeWidth]line1_excep_type_i;
wire line1_excep_en_i;
wire [`ExceptionTypeWidth]line2_excep_type_i;
wire line2_excep_en_i;

wire inst2_en;

wire inst_ram_req_i;

 wire line1_tlb_excpet_en_i;
 wire line1_tlb_adef_except_en_i;
 wire line1_tlb_adef_excep_i   ;
 wire line1_tlb_fetchr_excep_i ;   
 wire line1_tlb_pif_excep_i    ;   
 wire line1_tlb_ppi_excep_i    ;
 
 wire branch_i ;
 wire btb_hit_i;
 wire [`PcWidth]btb_branch_pc_i;
 wire [`ScountStateWidth]pht_state_i;
 

 
 //实物理地址
 wire [`PcWidth]p_line1_pc_i;//实物理地址
 wire uncache_i;
/***************************************output variable define(输出变量定义)**************************************/
wire [`ExceptionTypeWidth]line1_excep_type_o;
wire line1_excep_en_o;
wire [`ExceptionTypeWidth]line2_excep_type_o;
wire line2_excep_en_o;


 wire pre_uncache_o;
 
//顺序执行的pc
wire [`PcWidth]to_preif_pc_o;
wire to_preif_pc_we_o;
//cache
wire [`PpnWidth]p_tag_o;
wire uncache_o;

wire cache_refill_valid_o;
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
wire line2_excep_en,line1_excep_en;
wire line2_pc_addr_error;
//例外
wire line1_pc_adef;
//握手
wire now_ready_go;
/***************************************inner variable define(ILA)**************************************/
`ifdef OPEN_ILA 
    `ifdef OPEN_ILA_CPU_SIMPLY 
         (*mark_debug = "true"*) wire [`PcWidth]    ila_pc1_i;//preif级输出的pc
         (*mark_debug = "true"*) wire               ila_now_valid_i;
         (*mark_debug = "true"*) wire               ila_line1_now_to_next_valid_o;
         (*mark_debug = "true"*) wire               ila_now_allowin_o;
         (*mark_debug = "true"*) wire               ila_next_allowin_i;
         (*mark_debug = "true"*) wire               ila_now_ready_go;
         
         
         assign ila_pc1_i                       = pc1_i;
         assign ila_now_ready_go                = now_ready_go;
         assign ila_now_valid_i                 = now_valid_i;
                    
         assign ila_line1_now_to_next_valid_o   = line1_now_to_next_valid_o;
         
         assign ila_now_allowin_o               = now_allowin_o;
         assign ila_next_allowin_i              = next_allowin_i;
      
                                                
        `ifdef OPEN_ILA_CPU_WHOLE  
                
               
          `endif
      `endif
 `endif   

/****************************************input decode(输入解码)***************************************/
assign  {inst_ram_req_i,line2_excep_en_i,line2_excep_type_i,pc2_i,
                        line1_excep_en_i,line1_excep_type_i,pc1_i} = pre_to_ibus;


assign {uncache_i,
        line1_tlb_excpet_en_i,line1_tlb_adef_except_en_i,line1_tlb_fetchr_excep_i,line1_tlb_pif_excep_i,line1_tlb_ppi_excep_i,
        p_line1_pc_i} = mmu_to_ibus ;
        
assign    {branch_i,pht_state_i,btb_hit_i,btb_branch_pc_i} = pr_data_i;

/****************************************output code(输出解码)***************************************/


assign to_preif_obus = {to_preif_pc_we_o,to_preif_pc_o } ;


assign inst_ram_req_o = inst_ram_req_i&now_valid_i;

assign to_next_obus = {pre_uncache_o,uncache_o,inst_ram_req_o,
                       branch_i,btb_hit_i,pht_state_i,btb_branch_pc_i,
                       line2_excep_en_o,line2_excep_type_o,pc2_i,
                       line1_excep_en_o,line1_excep_type_o,pc1_i};

assign to_mmu_obus = pc1_i;

assign to_next_signle_data_obus = {inst_ram_req_o,cache_refill_valid_o,uncache_o,p_tag_o};
assign if_now_clk_ram_req_o = inst_ram_req_o;
assign  puc_raddr_o = pc1_i[16:12];
/*******************************complete logical function (逻辑功能实现)*******************************/

assign {inst2_en,to_preif_pc_o} = pre_uncache_i?{1'b0,pc1_i}:( pc1_i[2]?{1'b0,pc1_i}:{1'b1,pc2_i});


assign to_preif_pc_we_o = now_valid_i & now_allowin_o & (~excep_flush_i) &(~branch_flush_i);


assign line2_pc_addr_error = pc2_i[1:0]!= 2'b00 ? 1'b1:1'b0;


assign line1_pc_adef = pc1_i[1:0]!=2'b00 ? 1'b1:1'b0;

assign line1_excep_type_o[`IntEcode]                     = line1_excep_type_i[`IntEcode];
assign line1_excep_type_o[`PisLocation:`PilLocation]     = line1_excep_type_i[`PisLocation:`PilLocation];// 2：1
assign line1_excep_type_o[`PifLocation]                  = line1_tlb_pif_excep_i ;//3
assign line1_excep_type_o[`PpiLocation:`PmeLocation]     = line1_excep_type_i[`PpiLocation:`PmeLocation];// 5：4
assign line1_excep_type_o[`AdefLocation]                 = line1_pc_adef|line1_tlb_adef_except_en_i;//6
assign line1_excep_type_o[`ErtnLocation:`AdemLocation]   = line1_excep_type_i[`ErtnLocation:`AdemLocation];//16-7
assign line1_excep_type_o[`IfTlbrLocation]               = line1_tlb_fetchr_excep_i;//17
assign line1_excep_type_o[`TifLocation]                  = 1'b0;//18
assign line1_excep_type_o[`IfPpiLocation]                = line1_tlb_ppi_excep_i;//19
assign line1_excep_en = line1_excep_en_i||line1_pc_adef|line1_tlb_excpet_en_i;
assign line1_excep_en_o = line1_excep_en && now_valid_i;//interrupt_en_i必须有初始化值，pc_addr_error必须有初始值

//line2地址错误，则line1必定地址错误，所以本级只需要看line1的例外信号
assign line2_excep_type_o[`PpiLocation:`IntEcode]       = line2_excep_type_i[`PpiLocation:`IntEcode];//5：0
assign line2_excep_type_o[`AdefLocation]                = line2_pc_addr_error;//6
assign line2_excep_type_o[`IfPpiLocation:`AdemLocation] = line2_excep_type_i[`IfPpiLocation:`AdemLocation];//19-7
assign line2_excep_en   = line2_excep_en_i||line2_pc_addr_error;
assign line2_excep_en_o = line1_excep_en && now_valid_i;//interrupt_en_i必须有初始化值，pc_addr_error必须有初始值


//cache
assign p_tag_o = p_line1_pc_i[31:12];

assign uncache_o = uncache_i & line1_now_ctl_valid;
assign cache_refill_valid_o = line1_now_ctl_valid;

assign pre_uncache_o = pre_uncache_i& line1_now_ctl_valid;


     assign line1_now_ctl_valid      = line1_now_ctl_base_valid &(~line1_excep_en);
     assign line1_now_ctl_base_valid = now_valid_i & (~excep_flush_i) &(~branch_flush_i);
     
     assign line2_now_ctl_valid      = line2_now_ctl_base_valid &(~line1_excep_en);
     assign line2_now_ctl_base_valid = now_valid_i & (~excep_flush_i);



      assign now_allowin_o   = (!now_valid_i) 
                              || (now_ready_go && next_allowin_i);
                           
      assign line1_now_to_next_valid_o = now_valid_i && now_ready_go;
      
      assign line2_now_to_next_valid_o = now_valid_i&& inst2_en && now_ready_go;



endmodule
