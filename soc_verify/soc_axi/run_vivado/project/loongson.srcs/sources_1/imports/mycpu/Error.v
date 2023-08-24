/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：

/*************\
bug:
\*************/
`include "define.v"
module Error
(
    input  wire  clk      ,
    input  wire  rst_n    ,
    
    //接受错误使能
    input wire inst_cache_error_i,
    input wire data_cache_error_i,
    input wire if_error_i,
    input wire ift_error_i,
    input wire id_error_i,
    input wire launch_error_i,
    input wire ex_error_i,
    input wire mm_error_i,
    input wire mem_error_i,
    input wire wb_error_i ,
    input wire diff_error_i ,
    
    //发错错误
    output wire cpu_inner_error_o
   
);

/***************************************input variable define(输入变量定义)**************************************/
  wire error_i;
  assign error_i= inst_cache_error_i|data_cache_error_i|if_error_i|ift_error_i|id_error_i|launch_error_i|ex_error_i|mm_error_i|mem_error_i|wb_error_i|diff_error_i;

/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
reg error_reg;
/****************************************input decode(输入解码)***************************************/

/****************************************output code(输出解码)***************************************/
assign cpu_inner_error_o = error_reg&`ERROR_OPEN;
/*******************************complete logical function (逻辑功能实现)*******************************/
always @(posedge clk )begin
    if(rst_n == `RstEnable)begin
        error_reg <=1'b0;
    end  else if (error_i)begin
         error_reg <=1'b1;
    end else begin
         error_reg <=error_reg;
    end 
end 


endmodule
























