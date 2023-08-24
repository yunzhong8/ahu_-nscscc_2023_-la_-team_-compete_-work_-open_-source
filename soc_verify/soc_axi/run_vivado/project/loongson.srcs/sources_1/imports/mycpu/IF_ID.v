/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：

*/
/*************\

\*************/
//`include "DefineModuleBus.h"
`include "define.v"
module IF_ID(
    input  wire  clk      ,
    input  wire  rst_n    ,

    input wire line1_pre_to_now_valid_i,
    input wire line2_pre_to_now_valid_i,
    //id阶段的状态机
    input wire now_allowin_i,
    //
    output wire error_o,
    
    output wire allowin_o,
    output wire line1_now_valid_o,
    output wire line2_now_valid_o,
    //冲刷信号
    input wire branch_flush_i,//冲刷流水信号
    input wire excep_flush_i,
    //发射暂停信号
    input wire double_valid_inst_lunch_flag_i ,
    input wire single_valid_inst_lunch_flag_i ,
    input wire zero_valid_inst_lunch_flag_i   ,
    
    
    
    
    
    //数据域
    input  wire  [`IdToNextBusWidth] pre_to_ibus,
    
    output wire  [`IdToNextBusWidth]to_id_obus         
);

/***************************************input variable define(输入变量定义)**************************************/
/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/






/***************************************inner variable define(内部变量定义)**************************************/
reg [`LineIdToNextBusWidth] inst_data_queue[`LAUNCH_QUEUE_WIDTEH];
reg inst_valid_queue[`LAUNCH_QUEUE_WIDTEH];
reg [`LAUNCH_QUEUE_POINTER_WIDTEH]queue_head;
reg [`LAUNCH_QUEUE_POINTER_WIDTEH]queue_tail;

reg  [`LAUNCH_QUEUE_LEN_WIDTH]queue_len;
wire [`LAUNCH_QUEUE_LEN_WIDTH]next_queue_len;
wire [`LAUNCH_QUEUE_LEN_WIDTH]next_sub_queue_len;
wire [`LAUNCH_QUEUE_LEN_WIDTH]next_add_sub_queue_len;
wire [`LAUNCH_QUEUE_LEN_WIDTH]queue_len_add_tow,queue_len_add_one,queue_len_sub_tow,queue_len_sub_one;

wire double_write;
wire signle_write;
wire zero_write;
assign double_write = line1_pre_to_now_valid_i&line2_pre_to_now_valid_i;
assign signle_write = (line1_pre_to_now_valid_i&~line2_pre_to_now_valid_i)|(~line1_pre_to_now_valid_i&line2_pre_to_now_valid_i);
assign zero_write = ~line1_pre_to_now_valid_i&~line2_pre_to_now_valid_i;

/***************************************inner variable define(错误状态)**************************************/

wire error;

              
assign error = queue_len>`LAUNCH_QUEUE_LEN;

assign error_o =error;
/****************************************input decode(输入解码)***************************************/
/****************************************output code(输出解码)***************************************/
/*******************************complete logical function (逻辑功能实现)*******************************/
//队头

always@(posedge clk)begin
    if(rst_n == `RstEnable||excep_flush_i|| branch_flush_i)begin
        queue_head<=`LAUNCH_QUEUE_POINTER_LEN'd0;
    end else if(line2_pre_to_now_valid_i&line1_pre_to_now_valid_i&allowin_o)begin
        queue_head <= queue_head +`LAUNCH_QUEUE_POINTER_LEN'd2;
    end else if(line1_pre_to_now_valid_i&allowin_o)begin 
        queue_head <= queue_head +`LAUNCH_QUEUE_POINTER_LEN'd1;
    end else begin
        queue_head <= queue_head;
    end
end

//队尾

always@(posedge clk)begin
    if(rst_n == `RstEnable||excep_flush_i|| branch_flush_i)begin
        queue_tail<=`LAUNCH_QUEUE_POINTER_LEN'd0;   
    end else if(single_valid_inst_lunch_flag_i)begin 
        queue_tail <= queue_tail +`LAUNCH_QUEUE_POINTER_LEN'd1;
    end else if(double_valid_inst_lunch_flag_i)begin
        queue_tail <= queue_tail +`LAUNCH_QUEUE_POINTER_LEN'd2;
    end else begin
        queue_tail <= queue_tail;
    end
end
//队列

wire [`LAUNCH_QUEUE_POINTER_WIDTEH]wirte_addr1= queue_head   ;
wire [`LAUNCH_QUEUE_POINTER_WIDTEH]wirte_addr2= queue_head+1 ;
wire [`LAUNCH_QUEUE_POINTER_WIDTEH]clear_addr1 = queue_tail  ;
wire [`LAUNCH_QUEUE_POINTER_WIDTEH]clear_addr2 = queue_tail+1;

wire [`LAUNCH_QUEUE_POINTER_WIDTEH]launch_addr1;
wire [`LAUNCH_QUEUE_POINTER_WIDTEH]launch_addr2;
generate 
    genvar i ;
    for(i=0;i<`LAUNCH_QUEUE_LEN;i=i+1) begin : data_loop
        always@(posedge clk)begin
            if(rst_n == `RstEnable||excep_flush_i|| branch_flush_i)begin
                inst_data_queue[i]<=`LineIdToNextBusLen'd0;
            end else if(i==wirte_addr1 && line1_pre_to_now_valid_i && allowin_o)begin 
               inst_data_queue[i]  <=pre_to_ibus[`LineIdToNextBusWidth];
            end else if(i==wirte_addr2 &&line2_pre_to_now_valid_i && allowin_o)begin 
               inst_data_queue[i]<=pre_to_ibus[`IdToNextBusLen-1 :`LineIdToNextBusLen];
            end else begin
                inst_data_queue[i] <= inst_data_queue[i];
            end
        end
        
        always@(posedge clk)begin
            if(rst_n == `RstEnable ||excep_flush_i|| branch_flush_i)begin
                inst_valid_queue[i]<= 1'd0;
            end else if(i==wirte_addr1 && line1_pre_to_now_valid_i && allowin_o)begin  
               inst_valid_queue[i]  <= line1_pre_to_now_valid_i;
            end else if(line2_pre_to_now_valid_i && allowin_o&&i==wirte_addr2)begin 
               inst_valid_queue[i]  <= line2_pre_to_now_valid_i;
               //清空尾指令输出过的数据
            end else if((single_valid_inst_lunch_flag_i|double_valid_inst_lunch_flag_i) && i==clear_addr1)begin
                inst_valid_queue[i]  <= 1'b0;
             end else if(double_valid_inst_lunch_flag_i && i==clear_addr2)begin
                inst_valid_queue[i]  <= 1'b0;
            end else begin
                inst_valid_queue[i] <= inst_valid_queue[i];
            end
        end 
  end 
endgenerate 
assign launch_addr1 = queue_tail;
assign launch_addr2 = queue_tail + `LAUNCH_QUEUE_POINTER_LEN'd1;
assign to_id_obus        = {inst_data_queue[ launch_addr2],inst_data_queue[launch_addr1]};
assign line1_now_valid_o = inst_valid_queue[launch_addr1];
assign line2_now_valid_o = `DOUBLE_LAUNCH ? inst_valid_queue[launch_addr2] : 1'b0;//(单双发射)


assign queue_len_add_tow=queue_len+`LAUNCH_QUEUE_POINTER_LEN'd2;
assign queue_len_add_one=queue_len+`LAUNCH_QUEUE_POINTER_LEN'd1;
assign queue_len_sub_tow=queue_len-`LAUNCH_QUEUE_POINTER_LEN'd2;
assign queue_len_sub_one=queue_len-`LAUNCH_QUEUE_POINTER_LEN'd1;


assign next_add_sub_queue_len = double_write ? (double_valid_inst_lunch_flag_i   ? queue_len :
                                         single_valid_inst_lunch_flag_i  ? queue_len_add_one:queue_len_add_tow):
                        signle_write ? (double_valid_inst_lunch_flag_i   ? queue_len_sub_one :
                                         single_valid_inst_lunch_flag_i   ? queue_len:queue_len_add_one):    
                                       (double_valid_inst_lunch_flag_i   ? queue_len_sub_tow :
                                         single_valid_inst_lunch_flag_i  ? queue_len_sub_one:queue_len);   

assign next_sub_queue_len =   double_valid_inst_lunch_flag_i ?    queue_len_sub_tow  :
                               single_valid_inst_lunch_flag_i ?  queue_len_sub_one :queue_len;
                               
                             
assign next_queue_len = allowin_o ?  next_add_sub_queue_len :next_sub_queue_len;
always@(posedge clk)begin
    if(rst_n == `RstEnable||excep_flush_i|| branch_flush_i)begin
        queue_len<=`LAUNCH_QUEUE_LEN_LEN'd0;
   end else begin
         queue_len<=next_queue_len;
   end      
end

assign allowin_o =  queue_len >`LAUNCH_QUEUE_ALLOWIN_CRITICAL_VALUE ? 1'b0 : 1'b1;

endmodule
