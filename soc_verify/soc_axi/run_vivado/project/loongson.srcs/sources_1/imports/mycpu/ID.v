/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：
*控制信号:
*jmp_flag_o:是否发生跳转
*llbit_we_o:是否写llbit寄存器
regs_we_o
mem_we_o
mem_req_o
regs_re1_o
regs_re2_o
tlb_re_o
tlb_se_o
tlb_ie_o
tlb_we_o
tlb_fe_o
csr_we_o


*/
/*************\

\*************/

`include "define.v"
module ID(
    input  wire  rst_n    ,
    
    input wire  next_allowin_i,
    input wire  now_valid_i, 
    
   
    output wire now_allowin_o,
    output wire now_to_next_valid_o,
    
    
    input wire excep_flush_i,
    
   

    input wire  [`LineIdToNextBusWidth]        pre_to_ibus,
    input wire  [`LineRegsRigthReadBusWidth] regs_rigth_read_ibus        ,
    input wire  [`CoutToIdBusWidth]          cout_to_ibus,
    
    output wire                              want_done_en_o,
    
    output wire [5:0]                        wregs_obus,
    
    output wire [`LineLaunchtOIlaBusWidth]         to_ila_obus          ,
    output wire [`LineLaunchToNextBusWidth]        to_next_obus,
   
   
    output wire [`LineRegsReadIbusWidth]       to_rfb_obus
);

/***************************************input variable define(输入变量定义)**************************************/
    //数据部分
    wire [`PcWidth] pc_i;
    wire [`InstWidth]inst_i;
    wire [`SignWidth]                sp_sign_i;
    
    //例外
    wire excep_en_i;
    wire [`ExceptionTypeWidth]excep_type_i;
    
    wire  [63:0] counter_i;
    //部件ready信号
    wire regs_read_ready_i;
    
    wire branch_i;
    wire btb_hit_i;
    wire [1:0]pht_state_i;
    wire [`PcWidth]pre_pc_i;
    
    

/***************************************ioutput variable define(输出变量定义)**************************************/
    wire regs_re1_o;
    wire regs_re2_o;
    wire [`RegsAddrWidth]    regs_raddr1_o;
    wire [`RegsAddrWidth]    regs_raddr2_o;
    wire [`AluOpWidth]       alu_op_o             ;
    wire [`AluOperWidth]     alu_oper1_o          ;
    reg [`AluOperWidth]      alu_oper2_o          ;
    wire [`spExeRegsWdataSrcWidth]                exe_regs_wdata_src_o;
    //存储器输出
    wire                   mem_req_o;
    wire                   mem_we_o;
    wire  [`spMemRegsWdataSrcWidth]               mem_regs_wdata_src_o;
    wire  [`spMemMemDataSrcWidth]                 mem_mem_data_src_o;
    wire  [`MemDataWidth]           mem_wdata_o;
    //寄存器输出
    wire                       regs_we_o     ;
    wire  [`RegsAddrWidth]     regs_waddr_o  ;
    wire  [`RegsDataWidth]     regs_wdata_o  ;
    wire  [`RegsDataWidth]     regs_rdata1_o ;
    wire  [`RegsDataWidth]     regs_rdata2_o ;
    //csr
    
    wire is_kernel_inst_o;
    wire csr_wdata_src_o;
    wire csr_raddr_src_o;
    wire csr_we_o;
    wire [`CsrAddrWidth]csr_waddr_o;
    wire [`RegsDataWidth]csr_wdata_o;
    wire wb_regs_wdata_src_o;

    // 跳转   
    wire [`PcWidth]        jmp_base_addr;
    wire [`PcWidth]        jmp_offs_addr;
    
    //llbit
    wire llbit_we_o;
    wire llbit_wdata_o;
    //例外信号
    wire excep_en_o;
    wire [`ExceptionTypeWidth] excep_type_o;
    wire refetch_flush_o;
    wire idle_en_o;
    wire cacop_en_o;
    wire [4:0]cacop_code_o;
    //tlb
    wire tlb_re_o         ;
    wire tlb_se_o         ;
    wire tlb_ie_o         ;
    wire tlb_we_o         ;
    wire tlb_fe_o         ;
    wire [4:0]tlb_op_o    ;
    
    
   
    

/***************************************parameter define(常量定义)**************************************/
wire [`IdToDiffBusWidth]id_to_diff_ibus;
wire [5:0]id_load_diff_i ;//6
wire [3:0]id_store_diff_i;//4

wire diff_rdcn_en_o;
wire [63:0]diff_time_value_o;
wire [7:0]diff_load_type_o;
wire [7:0]diff_store_tyoe_o;

wire [`LaunchToDiffBusWidth]la_to_diff_obus;

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
    
     wire   [4:0]     imm5;
     wire   [11:0]    imm12            ;
     wire   [13:0]    imm14            ;
     wire    [15:0]   imm16;
     wire   [19:0]    imm20;
     
     wire   [25:0]    imm26            ;

     wire   [31:0]    sign_ext_imm12   ;
     wire    [31:0]   sign_ext_imm16   ;
     wire   [31:0]    sign_ext_imm20  ;
     wire   [31:0]    sign_ext_imm26   ;
     
     wire   [31:0]    zero_ext_imm5;
     wire   [31:0]    zero_ext_imm12   ;
     wire    [31:0]   zero_ext_imm16   ;
     wire   [31:0]    zero_ext_imm20  ;
     wire   [31:0]    zero_ext_imm26   ;



 //指令控制信号产生模块定义
      wire [`IdToSpBusWidth] id_to_sp_ibus;
     //Id阶段
     wire                             spIdRegsRead1Src;
     wire [`spIdRegsRead2SrcWidth]    spIdRegsRead2Src;
    
     wire [`spIdAluOpaSrcWidth]       spIdAluOpaSrc;
     wire [`spIdAluOpbSrcWidth]       spIdAluOpbSrc;
     
     wire [`spIdRegsWaddrSrcWidth]    spIdRegsWaddrSrc;
     wire [`spIdRegsWdataSrcWidth]    spIdRegsWdataSrc;
     
     //llbit
     
     wire spIdLlbitwdataSrc;
     wire spIdCsrWdataSrc;
     wire spIdCsrRaddrSrc;
    
     

     //EXE
     wire [`spExeRegsWdataSrcWidth]   spExeRegsWdataSrc;
     wire [`AluOpWidth]               spExeAluOp;
     wire                             spTlbSe;
     
     //MEM
     wire [`spMemReqWidth]            spMemReq;
     wire [`spMemMemWeWidth]          spMemMemWe;
     wire [`spMemRegsWdataSrcWidth]   spMemRegsWdataSrc;
     wire [`spMemMemDataSrcWidth]     spMemMemDataSrc;  
     
     //WB
     wire [`EnWidth]  spWbRegsWe ;
     wire             spIdLlbitWe;
     wire             spWbRegWdataSrc;
     
     wire             spTlbRe;
     wire             spTlbWe;
     wire             spTlbIe;
     wire             spTlbFe;
     
      //CSR
     wire             spWbCsrWe;
     //分支
  
     wire [`spIdBtypeWidth]              spIdBtype;
     wire [`spIdJmpWidth]                spIdJmp;
     wire [`spIdJmpBaseAddrSrcWidth]     spIdJmpBaseAddrSrc;
     wire [`spIdJmpOffsAddrSrcWidth]     spIdJmpOffsAddrSrc;
    //Excep
     wire [`spExcepTypeWidth]spexcep ;
     wire                    spkernelinst;
     wire spflush;
     wire spidle;
     wire spcache;
    
    
//解决数据相关后寄存器组读出数据
    wire [`RegsDataWidth]regs_rdata1;
    wire [`RegsDataWidth]regs_rdata2;
//内部例外
    wire sys_excep_en;
    wire brk_excep_en;
    wire ertn_en;
    wire ine_excep_en;
    
    wire excep_en;
    wire is_branch_inst;
 //除法
    wire div_en;   
/********************************决赛代码************************************************/
 //决赛代码
   wire spIdrlwinm;
   wire [4:0] imm5a = inst_i[24:20];
   wire [4:0] imm5b = inst_i[19:15];
   wire [4:0] imm5c = inst_i[14:10];
   wire begin_g_end  = (imm5b > imm5c);

   wire [4:0] imm_begin = begin_g_end ? imm5c : imm5b;
   wire [4:0] imm_end   = begin_g_end ? imm5b : imm5c;
  
   wire [31:0] mask_begin = 32'hffff_fffe << imm_begin;
   wire [31:0] mask_end   = 32'hffff_ffff >> (~imm_end);
  
   wire [31:0] mask = begin_g_end ? ~(mask_begin & mask_end) : (mask_begin & mask_end);
  
   wire [63:0] rj_zext = {32'b0, regs_rdata1};
  
   wire [63:0] sll_result = rj_zext << imm5a;
  
   wire [31:0] rotl_result      = sll_result[31:0] | sll_result[63:32];
   wire [31:0]end_compete_oper1 = rotl_result;
   wire [31:0]end_compete_oper2 = mask;
 
/****************************************input decode(输入解码)***************************************/
   
    assign counter_i = cout_to_ibus;
    assign {
            id_to_diff_ibus,
            branch_i,btb_hit_i,pht_state_i,pre_pc_i,
            excep_en_i,excep_type_i,
            spExeAluOp,sp_sign_i,
            pc_i,inst_i} = pre_to_ibus;
    assign {regs_read_ready_i,regs_rdata2,regs_rdata1} = regs_rigth_read_ibus;
    

/****************************************output code(输出解码)***************************************/
    assign to_rfb_obus = {regs_re2_o,regs_raddr2_o,regs_re1_o,regs_raddr1_o};
    assign to_if_obus = 1'b0;
    assign to_next_obus = {        
        la_to_diff_obus,
        idle_en_o,cacop_en_o,cacop_code_o,
        spIdBtype,spIdJmp,is_branch_inst,jmp_base_addr,jmp_offs_addr,
        branch_i,btb_hit_i,pht_state_i,pre_pc_i,
        refetch_flush_o,
        tlb_fe_o,tlb_se_o,tlb_re_o,tlb_we_o,tlb_ie_o,
        tlb_op_o,
        is_kernel_inst_o,
        csr_wdata_src_o,regs_rdata1_o,regs_rdata2_o,
        excep_en_o,excep_type_o,//例外
        llbit_we_o,llbit_wdata_o,//llbit写
        csr_raddr_src_o,csr_we_o,csr_waddr_o,csr_wdata_o,//csr写使能
        exe_regs_wdata_src_o,alu_op_o,alu_oper1_o,alu_oper2_o,
        mem_regs_wdata_src_o,mem_mem_data_src_o,mem_req_o,mem_we_o,mem_wdata_o,
        wb_regs_wdata_src_o,regs_we_o,regs_waddr_o,regs_wdata_o,
        pc_i,inst_i};
    
    assign wregs_obus    = {regs_we_o ,regs_waddr_o};
     
    assign id_to_sp_ibus     = {rk,rj,rd,inst_i};
    
    assign to_ila_obus = {inst_i,pc_i};
/*******************************complete logical function (逻辑功能实现)*******************************/

  //$$$$$$$$$$$$$$$（ 指令分解模块 模块调用）$$$$$$$$$$$$$$$$$$// 
	
	 
     assign op = inst_i[31:10] ;

     assign rk = inst_i[14:10] ;
     assign rj = inst_i[9:5]   ;
     assign rd = inst_i[4:0]   ;

     assign imm5 = rk;
     assign imm12 = inst_i[21:10] ;  //21-10=11+1=12
     assign imm16 = inst_i[25:10];
     assign imm14 = inst_i[23:10];
     assign imm20 = inst_i[24:5];
     assign imm26 = {inst_i[9:0],inst_i[25:10]};

     assign sign_ext_imm12 = {{20{imm12[11]}},imm12};
     assign sign_ext_imm16 = {{16{imm16[15]}},imm16};
     assign sign_ext_imm20 = {{12{imm20[19]}},imm20};
     assign sign_ext_imm26 = {{6{imm26[25]}},imm26};
     
     assign zero_ext_imm5 =  {27'd0,imm5};
     assign zero_ext_imm12 = {20'h0_0000,imm12};
     assign zero_ext_imm16 = {16'h0000,imm16};
     assign zero_ext_imm20 = {12'h000,imm20};
     assign zero_ext_imm26 = {6'd0,imm26};
    	

   //$$$$$$$$$$$$$$$（ 指令控制信号拆分）$$$$$$$$$$$$$$$$$$// 
     
       //ID阶段信号spIdRegsWdataSrc为最高位，高位 次高位 次低位 低位 2+1 +5+4+4= 16
             assign {
                     spIdrlwinm,
                     spIdCsrRaddrSrc,spIdCsrWdataSrc,//2
                     spIdLlbitwdataSrc,//1
                     spIdRegsWdataSrc,spIdRegsWaddrSrc,//3+2=5
                     spIdAluOpbSrc,spIdAluOpaSrc,//3+1=4
                     spIdRegsRead2Src,spIdRegsRead1Src} = sp_sign_i[`ID_SIGN_LOCATION];//2+1=3
      //跳转信号
             assign {spIdJmpOffsAddrSrc,spIdJmpBaseAddrSrc,
                     spIdJmp,spIdBtype
                     }= sp_sign_i[`B_SIGN_LOCATION];
      //获取EXE阶段信号
           assign {spTlbSe,spExeRegsWdataSrc} = sp_sign_i[`EXE_SIGN_LOCATION];
       //MEM
        assign {spMemReq,spMemMemDataSrc,spMemRegsWdataSrc,spMemMemWe}=sp_sign_i[`MEM_SIGN_LOCATION];
        
      //WB
        assign {spTlbFe,spTlbIe,spTlbWe,spTlbRe,
                spWbRegWdataSrc,spIdLlbitWe,spWbCsrWe,spWbRegsWe}=sp_sign_i[`WB_SIGN_LOCATION];
      //例外信号
        assign {spcache,spidle,spflush,spkernelinst,spexcep}=sp_sign_i[`EXCEP_SIGN_LOCATION];
    
 //*******************************************计算输出***********************************************//
//ID阶段使用
  
    assign regs_rdata1_o  = regs_rdata1;
    assign regs_rdata2_o  = regs_rdata2;
      //寄存器读地址1
      assign {regs_re1_o,regs_raddr1_o } = !now_valid_i ? {1'b0,5'd0} :
                                           (spIdRegsRead1Src == 1'b1) ? {1'b1,rj} :{1'b0,5'd0};
           
      //寄存器读地址2
      assign {regs_re2_o,regs_raddr2_o} = !now_valid_i ? {1'b0,5'd0} :
                                          (spIdRegsRead2Src == 2'b01) ? {1'b1,rk} :
                                          (spIdRegsRead2Src == 2'b10) ? {1'b1,rd} :{1'b0,5'd0};
                                        
                                 
       
  
       assign csr_raddr_src_o = spIdCsrRaddrSrc;
       assign csr_waddr_o =  imm14;
       assign csr_wdata_o =  32'b0;
       assign csr_wdata_src_o = spIdCsrWdataSrc;
       
   //################计算寄ALU(EXE)输出################//
          //ALU运算类型
             assign alu_op_o = spExeAluOp;
         //ALu_oper1运算器运算数1
             assign alu_oper1_o = spIdrlwinm ? end_compete_oper1:(spIdAluOpaSrc ? pc_i : regs_rdata1);
            
        //ALu_oper2运算器运算数2
             always@(*)begin
                 if(rst_n == `RstEnable)begin
                     alu_oper2_o = `AluOperLen'd0;
                 end else begin
                     case(spIdAluOpbSrc)//3
                         `spIdAluOpbSrcLen'd0: alu_oper2_o = regs_rdata2;
                         `spIdAluOpbSrcLen'd1: alu_oper2_o = zero_ext_imm12;
                         `spIdAluOpbSrcLen'd2: alu_oper2_o = sign_ext_imm12;
                         `spIdAluOpbSrcLen'd3: alu_oper2_o = {imm20,12'd0};
                         `spIdAluOpbSrcLen'd4: alu_oper2_o = zero_ext_imm5;
                         `spIdAluOpbSrcLen'd5: alu_oper2_o = { {16{imm14[13]}},imm14,2'b00};
                         `spIdAluOpbSrcLen'd7: alu_oper2_o = end_compete_oper2;//110
                         default: alu_oper2_o = `AluOperLen'd0; 
                     endcase
                 end
             end
                assign exe_regs_wdata_src_o = spExeRegsWdataSrc;
             
                assign div_en = (alu_op_o == `DivAluOp) || (alu_op_o == `ModAluOp) || (alu_op_o == `DivuAluOp) || (alu_op_o == `ModuAluOp) ? now_ctl_valid : 1'b0;                                                     
    //mem阶段
            
            assign mem_req_o            = spMemReq & now_ctl_valid    ; 
            
            
            assign mem_we_o             =  spMemMemWe & now_ctl_valid ;
            assign mem_regs_wdata_src_o = spMemRegsWdataSrc ; 
            assign mem_mem_data_src_o   = spMemMemDataSrc   ;
            assign mem_wdata_o          = regs_rdata2       ; 
            
  //  ################计算WB(regs_write)输出################//         
        assign regs_we_o = spWbRegsWe & now_ctl_valid;
    //寄存器组写入地址         
       assign  regs_waddr_o =  (spIdRegsWaddrSrc== 2'd1)   ? rj :
                               (spIdRegsWaddrSrc == 2'd2)  ? `RegsAddrLen'd1 : rd;
                               
         
     //寄存器写回数据
        assign regs_wdata_o = (spIdRegsWdataSrc == 3'd0) ? {imm20,12'b0} :
                              (spIdRegsWdataSrc == 3'd1) ? pc_i+32'd4     :
                              (spIdRegsWdataSrc == 3'd2) ? {counter_i[31:0]} :
                              (spIdRegsWdataSrc == 3'd3) ? {counter_i[63:32]} :`RegsDataLen'd0;
                            
        
        //tlb
        assign tlb_re_o = spTlbRe & now_ctl_valid;
        assign tlb_se_o = spTlbSe & now_ctl_valid;
        assign tlb_ie_o = spTlbIe & now_ctl_valid;
        assign tlb_we_o = spTlbWe & now_ctl_valid;
        assign tlb_fe_o = spTlbFe & now_ctl_valid;
        assign tlb_op_o = rd;
        
        
        //CSR
        assign is_kernel_inst_o = spkernelinst;//当前在指令是不是内核指令
        assign csr_we_o         = spWbCsrWe & now_ctl_valid;
        assign wb_regs_wdata_src_o = spWbRegWdataSrc;
        
        
  

    //################跳转计算################//         
      assign jmp_base_addr = spIdJmpBaseAddrSrc ? regs_rdata1: pc_i;
      assign jmp_offs_addr = spIdJmpOffsAddrSrc ? { {4{imm26[25]}},imm26,2'h0 } : { {14{imm16[15]}},imm16,2'h0 };
     
     //################原子访存
     assign llbit_we_o = spIdLlbitWe & now_ctl_valid;
     assign llbit_wdata_o = spIdLlbitwdataSrc ? 1'b1 : 1'b0;
     
     //例外(本级内容的例外信息)
     assign sys_excep_en = (spexcep ==`spExcepTypeLen'd2)? 1'b1:1'b0;//sys指令例外
     assign brk_excep_en = (spexcep ==`spExcepTypeLen'd1)? 1'b1:1'b0;//break例外
     assign ine_excep_en = (spexcep ==`spExcepTypeLen'd5)||(spTlbIe&& rd>`TlbInvOpMax)? 1'b1:1'b0;//指令非法例外
     assign ertn_en = (spexcep ==`spExcepTypeLen'd3)? 1'b1:1'b0;//返回指令例外
    
     //例外
     assign excep_type_o[`SysLocation-1:0] = excep_type_i[`SysLocation-1:0];
     //ID阶段中断
     assign excep_type_o[`SysLocation] = sys_excep_en & now_ctl_base_valid;
     assign excep_type_o[`BrkLocation] = brk_excep_en & now_ctl_base_valid;
     assign excep_type_o[`IneLocation] = ine_excep_en & now_ctl_base_valid;
     assign excep_type_o[`ErtnLocation-1:`IneLocation+1] = excep_type_i[`ErtnLocation-1:`IneLocation+1];
     //返回指令
     assign excep_type_o[`ErtnLocation]= ertn_en & now_ctl_base_valid;
     assign excep_type_o[`IfPpiLocation:`IfTlbrLocation] = excep_type_i[`IfPpiLocation:`IfTlbrLocation];
     
     assign excep_en   = (excep_en_i | sys_excep_en | brk_excep_en | ine_excep_en|ertn_en);  
     assign excep_en_o =  excep_en & now_ctl_base_valid;
    
     //重取
     assign refetch_flush_o = spflush & now_ctl_base_valid;
     //idle指令
     assign idle_en_o = spidle&now_ctl_valid; 
     assign cacop_en_o= spcache&now_ctl_valid;
     assign cacop_code_o = rd;
     //分支预测    
     assign is_branch_inst = inst_i[30];
      
      

     
     //指令有效信号
 
     assign now_ctl_valid      = now_ctl_base_valid &(~excep_en);
     assign now_ctl_base_valid = now_valid_i & (~excep_flush_i);
     
 
    assign want_done_en_o    = (!(spMemReq || div_en||spTlbRe||spTlbSe||spTlbIe||spTlbWe||spTlbFe) && now_valid_i ) ||  ~now_valid_i    ; 
     
     // 握手
      assign now_ready_go   = regs_read_ready_i; 
      assign now_allowin_o  = !now_valid_i 
                           || (now_ready_go && next_allowin_i);
      assign now_to_next_valid_o = now_valid_i && now_ready_go;
 
   
   //diff
   assign diff_rdcn_en_o = (spIdRegsWdataSrc == 3'd2|spIdRegsWdataSrc == 3'd3|spIdRegsWdataSrc == 3'd3) &now_ctl_valid;
   assign diff_time_value_o = counter_i;

   
   assign {id_store_diff_i,id_load_diff_i}=id_to_diff_ibus;
   
   assign diff_load_type_o = {2'd0,id_load_diff_i};
   assign diff_store_tyoe_o = {4'd0,id_store_diff_i};
   assign la_to_diff_obus={diff_rdcn_en_o,diff_time_value_o,diff_load_type_o,diff_store_tyoe_o};
   
  
     

endmodule

