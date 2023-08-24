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
bug:
\*************/
`include "define.v"
module IfTSq(
    input  wire                           clk                       ,
    input  wire                           rst_n                     ,
    //握手
    input wire                            line1_pre_to_now_valid_i  ,
   
    input wire                            now_allowin_i             ,
    
    output reg                            line1_now_valid_o         ,
   
    //冲刷信号
    input wire                            excep_flush_i             ,
    input wire                            branch_flush_i             ,
    
    //数据域
    input  wire [`IfToNextSignleBusWidth] pre_to_signle_data_ibus   ,
    input  wire [`IfToNextBusWidth]       pre_to_ibus               ,
    //指令缓存
    input  wire                           inst_rdata_buffer_we_i    ,
    input  wire [64:0]                    inst_rdata_buffer_i       ,
    
    
    
    output reg  [64:0]                    inst_rdata_buffer_o       ,

    output reg  [`IfToNextSignleBusWidth] to_now_signle_data_obus   ,
    output reg  [`IfToNextBusWidth]       to_now_obus
);

/***************************************input variable define(输入变量定义)**************************************/
                           

/***************************************output variable define(输出变量定义)**************************************/



/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/

/****************************************input decode(输入解码)***************************************/


/****************************************output code(输出解码)***************************************/

/*******************************complete logical function (逻辑功能实现)*******************************/
 //数据信号
 //双数据
   always@(posedge clk)begin
        if(rst_n == `RstEnable)begin
            to_now_obus <= 0;
        end else if(line1_pre_to_now_valid_i && now_allowin_i) begin
            to_now_obus <= pre_to_ibus;
        end else begin//暂停流水
            to_now_obus <= to_now_obus;
        end
   end
  //单数据 
    always@(posedge clk)begin
    if(rst_n == `RstEnable)begin
        to_now_signle_data_obus <= `IfToNextSignleBusLen'b0;
    end else if(line1_pre_to_now_valid_i && now_allowin_i) begin
        to_now_signle_data_obus <= pre_to_signle_data_ibus;
    end else begin//暂停流水
        to_now_signle_data_obus <= to_now_signle_data_obus;
        end
end
   
   
    
 //流水线1握手
 always@(posedge clk)begin
        if(rst_n == `RstEnable  ||excep_flush_i||branch_flush_i)begin
            line1_now_valid_o <= 1'b0;
        end else if(now_allowin_i)begin
            line1_now_valid_o <= line1_pre_to_now_valid_i;
        end else begin
            line1_now_valid_o <= line1_now_valid_o;
        end
 end

 
 
 
  //inst_ram缓存
  always@(posedge clk)begin
        if(rst_n == `RstEnable )begin
            inst_rdata_buffer_o <= 64'd0;
        end else if (inst_rdata_buffer_we_i) begin
            inst_rdata_buffer_o <= inst_rdata_buffer_i;
        end else begin
            inst_rdata_buffer_o <= inst_rdata_buffer_o;
        end
  end
  

endmodule
