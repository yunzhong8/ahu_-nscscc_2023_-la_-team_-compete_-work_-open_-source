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
module EX_MEM(
    input  wire  clk      ,
    input  wire  rst_n    ,
    
      
    input wire line1_pre_to_now_valid_i,
    input wire line2_pre_to_now_valid_i,
   

    input wire now_allowin_i,
    output reg line1_now_valid_o,
    output reg line2_now_valid_o,
    
    input wire excep_flush_i,
    
    input  wire  [`MmToNextBusWidth]pre_to_ibus  ,
    output reg   [`MmToNextBusWidth]to_now_obus  ,  
    
     
   
    
    input  wire        cache_buffer_we_i,
    input  wire [32:0] cache_buffer_wdata_i,
    output wire [32:0] cache_buffer_rdata_o
      
        
);

/***************************************input variable define(输入变量定义)**************************************/

/***************************************output variable define(输出变量定义)**************************************/

/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
reg [32:0] cache_buffer;
/****************************************input decode(输入解码)***************************************/


/****************************************output code(输出解码)***************************************/

/*******************************complete logical function (逻辑功能实现)*******************************/
always @(posedge clk)begin
    if(rst_n == `RstEnable)begin
        to_now_obus <= `ExToNextBusLen'd0;
    end else if((line1_pre_to_now_valid_i||line2_pre_to_now_valid_i) && now_allowin_i) begin
        to_now_obus <= pre_to_ibus;
    end else begin
        to_now_obus <= to_now_obus;
    end
end

always@(posedge clk)begin
        if(rst_n == `RstEnable ||excep_flush_i)begin
            line1_now_valid_o <= 1'b0;
        end else if(now_allowin_i)begin
           line1_now_valid_o <= line1_pre_to_now_valid_i;
        end else begin
             line1_now_valid_o <= line1_now_valid_o;
        end
 end
 
always@(posedge clk)begin
        if(rst_n == `RstEnable ||excep_flush_i)begin
            line2_now_valid_o <= 1'b0;
        end else if(now_allowin_i)begin
           line2_now_valid_o <= line2_pre_to_now_valid_i;
        end else begin
             line2_now_valid_o <= line2_now_valid_o;
        end
    end
   
 
 //inst_ram缓存
  always@(posedge clk)begin
        if(rst_n == `RstEnable )begin
            cache_buffer <= 0;
        end else if (cache_buffer_we_i) begin
            cache_buffer <= cache_buffer_wdata_i;
        end else begin
            cache_buffer <= cache_buffer;
        end
  end
  assign cache_buffer_rdata_o = cache_buffer;
  
 
 
 

 
 
 
endmodule
