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
module ID_EX(
    input  wire  clk      ,
    input  wire  rst_n    ,
    
                                                            
    input wire line1_pre_to_now_valid_i,                      
    input wire line2_pre_to_now_valid_i,                      
                                                                                      
    input wire now_allowin_i,                                    
                                                                                                 
                                                                                                 
    output reg line1_now_valid_o,                                                   
    output reg line2_now_valid_o,                                                                
    //冲刷信号                                                                                                                                                
    input wire excep_flush_i,                                                                    
    //数据域                                                                                        
    input  wire  [`LaunchToNextBusWidth] pre_to_ibus,                                                  
    
    output wire [`LaunchToNextBusWidth] to_now_obus         
);

/***************************************input variable define(输入变量定义)**************************************/

/***************************************output variable define(输出变量定义)**************************************/

/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
reg [`LaunchToNextBusWidth]now_data_reg;
/****************************************input decode(输入解码)***************************************/


/****************************************output code(输出解码)***************************************/

/*******************************complete logical function (逻辑功能实现)*******************************/
//数据信号
 always@(posedge clk)begin
    if(rst_n == `RstEnable)begin
        now_data_reg <= 0;
    end else if((line1_pre_to_now_valid_i || line2_pre_to_now_valid_i)&& now_allowin_i) begin
        now_data_reg <= pre_to_ibus;
    end else begin
        now_data_reg <= now_data_reg;
    end
end
    
    assign to_now_obus = now_data_reg;
 //流水线1握手
 always@(posedge clk)begin
        if(rst_n == `RstEnable  ||excep_flush_i)begin
            line1_now_valid_o <= 1'b0;
        end else if(now_allowin_i)begin
            line1_now_valid_o <= line1_pre_to_now_valid_i;
        end else begin
            line1_now_valid_o <= line1_now_valid_o;
        end
 end
//流水线2握手
 always@(posedge clk)begin
        if(rst_n == `RstEnable  ||excep_flush_i)begin
            line2_now_valid_o <= 1'b0;
        end else if(now_allowin_i)begin
            line2_now_valid_o <= line2_pre_to_now_valid_i;
        end else begin
            line2_now_valid_o <= line2_now_valid_o;
        end
  end
    
    
    
    
    
endmodule
