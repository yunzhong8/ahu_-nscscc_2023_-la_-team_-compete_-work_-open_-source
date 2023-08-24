/*
*作者：zzq
*创建时间：2023-04-21
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

module Lanuch(
   //时钟
    input  wire                         clk                           ,
    input  wire                         rst_n                         ,
    
    //握手
    input  wire                         next_allowin_i               ,
    input  wire                         line1_pre_to_now_valid_i     ,
    input  wire                         line2_pre_to_now_valid_i     ,
    
    output wire                         line1_now_to_next_valid_o    ,
    output wire                         line2_now_to_next_valid_o    ,
    output wire                         now_allowin_o                ,
    //冲刷
    input wire excep_flush_i,
    //error
    output wire error_o,
    
    //数据
    input  wire [`IdToNextBusWidth]       pre_to_ibus               ,
    input  wire [`RegsRigthReadBusWidth]  regs_rigth_read_ibus      ,       
    input  wire [63:0]                    cout_to_ibus              ,    
    
  
    output wire  [`RegsReadIbusWidth]     regs_raddr_obus           ,
    output wire  [`LaunchToNextBusWidth]  to_next_obus  
    
    
);

/***************************************input variable define(输入变量定义)**************************************/
wire [`LineRegsRigthReadBusWidth]line2_regs_rigth_read_ibus,line1_regs_rigth_read_ibus;


/***************************************output variable define(输出变量定义)**************************************/

wire [`LineLaunchToNextBusWidth] line2_to_next_obus,line1_to_next_obus;
wire [`LineRegsReadIbusWidth]line2_to_rfb_obus,line1_to_rfb_obus;

wire banch_flush_o;

/***************************************parameter define(常量定义)**************************************/
wire lanuch_error;
assign error_o = lanuch_error;
/***************************************inner variable define(内部变量定义)**************************************/

wire [`IdToNextBusWidth]pre_to_bus;
wire [`LineIdToNextBusWidth]line2_pre_to_bus,line1_pre_to_bus;



//跳转冲刷信号
wire branch_flush;
//发射信号
wire  double_valid_inst_lunch_flag;
wire  single_valid_inst_lunch_flag;
wire  zero_valid_inst_lunch_flag;

//IFID
wire line2_now_valid,line1_now_valid;


//ID
wire line2_inst_is_mem,line1_inst_is_mem;
wire line2_regs_re2_o,line2_regs_re1_o;
wire [`LineLaunchToPreBusWidth]line2_to_pre_obus,line1_to_pre_obus;

//refgs
wire [`RegsAddrWidth]line2_regs_raddr1,line2_regs_raddr2;
wire line2_regs_we,line1_regs_we;
wire [`RegsAddrWidth]line2_regs_waddr,line1_regs_waddr;
wire [5:0]line2_wregs_bus,line1_wregs_bus;
wire [`PcWidth] line1_pc;



//发射级两条指令相关性
wire line2_relate_line1;
wire line2_want_done_en_o,line1_want_done_en_o;

//握手
wire line2_now_allowin,line1_now_allowin;
wire line2_now_to_next_valid,line1_now_to_next_valid;

wire now_allowin;
/***************************************inner variable define(ILA)**************************************/
wire [`LineLaunchtOIlaBusWidth]line1_to_ila_bus,line2_to_ila_bus;

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
assign {line2_regs_rigth_read_ibus,line1_regs_rigth_read_ibus} = regs_rigth_read_ibus ;
assign line1_pc = line1_pre_to_bus[63:32];
/****************************************output code(输出解码)***************************************/

assign to_next_obus    = {line2_to_next_obus,line1_to_next_obus};
//访问rfb
assign regs_raddr_obus = {line2_to_rfb_obus,line1_to_rfb_obus};


/****************************************output code(内部解码)***************************************/
assign {line1_regs_we,line1_regs_waddr} = line1_wregs_bus;
assign {line2_regs_we,line2_regs_waddr} = line2_wregs_bus;
assign {line2_pre_to_bus,line1_pre_to_bus} = pre_to_bus;
assign {line2_regs_re2_o,line2_regs_raddr2,line2_regs_re1_o,line2_regs_raddr1} = line2_to_rfb_obus;


/*******************************complete logical function (逻辑功能实现)*******************************/

IF_ID IFIDI(
        .rst_n(rst_n),
        .clk(clk),
        
        
        //握手                                                     
        .line1_pre_to_now_valid_i(line1_pre_to_now_valid_i),     
        .line2_pre_to_now_valid_i(line2_pre_to_now_valid_i),     
        .now_allowin_i(now_allowin),   
        //error                        
        .error_o(lanuch_error),                                                        
        .line1_now_valid_o(line1_now_valid),                     
        .line2_now_valid_o(line2_now_valid),                     
         //冲刷                                                        
        .branch_flush_i     (branch_flush),
        .excep_flush_i      (excep_flush_i),  
        //发射状况   
        .double_valid_inst_lunch_flag_i( double_valid_inst_lunch_flag  ),  
        .single_valid_inst_lunch_flag_i( single_valid_inst_lunch_flag  ),  
        .zero_valid_inst_lunch_flag_i  ( zero_valid_inst_lunch_flag    ),    
        
               
                                      
        //数据域                                                
        .pre_to_ibus(pre_to_ibus), 
        .allowin_o(now_allowin_o),
        
        .to_id_obus(pre_to_bus)         
       
         
    );
                   

ID IDI1(
        .rst_n (rst_n),
        //握手
        .next_allowin_i(next_allowin_i),
        .now_valid_i(line1_now_valid),
        
        .now_allowin_o(line1_now_allowin),
        .now_to_next_valid_o(line1_now_to_next_valid),
        
        .excep_flush_i(excep_flush_i),
        
        //数据域
        .pre_to_ibus(line1_pre_to_bus),
        .regs_rigth_read_ibus(line1_regs_rigth_read_ibus),
        .cout_to_ibus(cout_to_ibus ),
        
        .to_ila_obus         (line1_to_ila_bus),
        .want_done_en_o      (line1_want_done_en_o),
        .wregs_obus          (line1_wregs_bus),
        .to_next_obus        (line1_to_next_obus),
        
        
        .to_rfb_obus         (line1_to_rfb_obus)
    );
   
    
    
    
  ID IDI2(
        .rst_n (rst_n),
        //握手
        .next_allowin_i(next_allowin_i),
        .now_valid_i(line2_now_valid),
        
        .now_allowin_o(line2_now_allowin),
        .now_to_next_valid_o(line2_now_to_next_valid),
  
        .excep_flush_i(excep_flush_i),
        
        //数据域
        .pre_to_ibus(line2_pre_to_bus),
        .regs_rigth_read_ibus(line2_regs_rigth_read_ibus),
        .cout_to_ibus(cout_to_ibus ),
        
        .want_done_en_o         (line2_want_done_en_o)   ,
        .wregs_obus             (line2_wregs_bus)        ,
        //.to_pre_obus            (line2_to_pre_obus)       ,
        .to_next_obus           (line2_to_next_obus)  ,
        
        
             
        .to_rfb_obus            (line2_to_rfb_obus)
    );

//两条指令相关性检查
assign line2_relate_line1 = ( (line1_regs_we == `WriteEnable) && (line1_regs_waddr!=0) && 
                               ( (line1_regs_waddr ==line2_regs_raddr1 && line2_regs_re1_o) || (line1_regs_waddr ==line2_regs_raddr2 && line2_regs_re2_o) ) ) ? 1'b1 : 1'b0;


//发射仲裁
                        
   assign zero_valid_inst_lunch_flag = ~double_valid_inst_lunch_flag &~single_valid_inst_lunch_flag;

   assign double_valid_inst_lunch_flag =   (line1_now_valid &line2_now_valid &now_allowin) ? (line2_want_done_en_o?  (line2_relate_line1   ? 1'b0 :1'b1) : 1'b0):1'b0;
   
   assign single_valid_inst_lunch_flag = (line1_now_valid &~line2_now_valid &now_allowin) ? 1'b1 :
                              (line1_now_valid &line2_now_valid &now_allowin) ?(line2_want_done_en_o?  (line2_relate_line1   ? 1'b1 :1'b0) : 1'b1):1'b0;

//冲刷信号
    assign  branch_flush  = 1'b0 ;
    assign  banch_flush_o = 1'b0 ;


//握手
assign now_allowin = line2_now_allowin && line1_now_allowin;


assign line1_now_to_next_valid_o = line1_now_to_next_valid && now_allowin;
assign line2_now_to_next_valid_o = double_valid_inst_lunch_flag ? line2_now_to_next_valid :1'b0;



endmodule
