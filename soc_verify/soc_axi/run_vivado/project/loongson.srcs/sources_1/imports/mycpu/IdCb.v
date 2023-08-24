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
module IdCb(
    input  wire                            rst_n                ,
    
    input wire                             next_allowin_i       ,
    input wire                             now_valid_i          ,
    
    output wire                            now_allowin_o        ,
    output wire                            now_to_next_valid_o  ,
    
    
    input wire                             excep_flush_i        ,
    
    input wire  [`LineIftToNextBusWidth]    pre_to_ibus          ,
    
    output wire [`LineIdtOIlaBusWidth]         to_ila_obus          ,
    output wire [`LineIdToNextBusWidth]    to_next_obus         ,
    output wire [`LineIdToPreBusWidth]     to_pre_obus          ,
    output wire [`IdToPreifBusWidth]       to_preif_obus
    
);

/***************************************input variable define(输入变量定义)**************************************/
    wire [`PcWidth] pc_i;
    wire [`InstWidth]inst_i;
    
    
    //例外
    wire excep_en_i;
    wire [`ExceptionTypeWidth]excep_type_i;
   
    
    wire branch_i;
    wire btb_hit_i;
    wire [1:0]pht_state_i;
    wire [`PcWidth]pre_pc_i;
    
    

/***************************************ioutput variable define(输出变量定义)**************************************/
   

    // 跳转   
    wire [`PcWidth]        branch_addr_o;
    //控制信号
    wire [`AluOpWidth]spExeAluOp;
    wire [`SignWidth]                sp_sign_o;
   
   
    //例外信号
    wire excep_en_o;
    wire [`ExceptionTypeWidth] excep_type_o;
    
    //预测的下指（因为btb的值不一定是预测下指）
    wire [`PcWidth]branch_inst_pre_next_pc_o;

/***************************************parameter define(常量定义)**************************************/
  wire[`IdToDiffBusWidth] to_diff_obus;
/***************************************inner variable define(内部变量定义)**************************************/
// 握手信号
    wire now_ready_go;
 
 wire now_ctl_valid;  
 wire now_ctl_base_valid;  
 
 
//指令分解 模块变量定义
     wire   [21:0]    op               ;
    
     wire   [4:0]     rj               ;
     wire   [4:0]     rk               ;
     wire   [4:0]     rd               ;


 //指令控制信号产生模块定义
      wire [`IdToSpBusWidth] id_to_sp_ibus;
     
 
//jmp信号
    wire branch_flush_flag;
//顺序下指
    wire [`PcWidth]order_next_pc;    
    
    
    wire excep_en;
    wire is_branch_inst;
 
 
/****************************************input decode(输入解码)***************************************/
   
    assign {
            branch_i,btb_hit_i,pht_state_i,pre_pc_i,
            excep_en_i,excep_type_i,
            pc_i,inst_i} = pre_to_ibus;
    
    
/****************************************output code(输出解码)***************************************/
    assign to_pre_obus  = branch_flush_flag_o;
    assign to_next_obus = {    
        to_diff_obus,     
        branch_i,btb_hit_i,pht_state_i,branch_inst_pre_next_pc_o,//分支预测 
        excep_en_o,excep_type_o,
        spExeAluOp,sp_sign_o,      
        pc_i,inst_i};
    
    assign to_preif_obus = {branch_flush_flag_o,branch_addr_o};

     
    assign id_to_sp_ibus     = {rk,rj,rd,inst_i};
    
    assign to_ila_obus = {inst_i,pc_i};
    
/*******************************complete logical function (逻辑功能实现)*******************************/

  //$$$$$$$$$$$$$$$（ 指令分解模块 模块调用）$$$$$$$$$$$$$$$$$$//
	 
     assign op = inst_i[31:10] ;

     assign rk = inst_i[14:10] ;
     assign rj = inst_i[9:5]   ;
     assign rd = inst_i[4:0]   ;
   //$$$$$$$$$$$$$$$（ 指令控制信号产生 模块调用）$$$$$$$$$$$$$$$$$$// 
     
             SignProduce sp(
             .id_to_ibus(id_to_sp_ibus),
             .to_diff_obus( to_diff_obus),
             .inst_aluop_o(spExeAluOp),
             .inst_sign_o(sp_sign_o)
             );    
     assign order_next_pc = pc_i+32'd4;
      
    //分支预测，静态分支预测
       assign is_branch_inst      = inst_i[30];                                           
       assign branch_flush_flag   =  is_branch_inst & branch_i & btb_hit_i & (pre_pc_i !=order_next_pc );
                                                                           
       assign branch_flush_flag_o =  branch_flush_flag & now_ctl_valid ;                 
       assign branch_addr_o       = branch_flush_flag ? pre_pc_i: 32'd0;  
       
   
       assign branch_inst_pre_next_pc_o =  is_branch_inst & branch_i & btb_hit_i ?   pre_pc_i : order_next_pc; 
     
     //例外
       assign excep_en     = excep_en_i;
       assign excep_en_o   = excep_en &now_ctl_base_valid;
       assign excep_type_o = excep_type_i;

     assign now_ctl_valid      = now_ctl_base_valid &(~excep_en);
     assign now_ctl_base_valid = now_valid_i & (~excep_flush_i);
    
     
     // 握手
      assign now_ready_go        = 1'b1; 
      assign now_allowin_o       = !now_valid_i 
                                   || (now_ready_go && next_allowin_i);
      assign now_to_next_valid_o = now_valid_i && now_ready_go;
 
    

endmodule

