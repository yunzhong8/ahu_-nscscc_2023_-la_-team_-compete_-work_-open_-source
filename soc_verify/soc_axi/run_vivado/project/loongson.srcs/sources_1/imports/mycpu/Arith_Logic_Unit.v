/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：oper1/oper2<====>x/y,x被除数，除数数
*
*/
/*************\
bug:
\*************/
`include "define.v"
module Arith_Logic_Unit(
    input  wire clk,
    input  wire rst_n,
    input  wire [`AluOperWidth] x       ,   // 源操作数x, rj，oper1
    input  wire [`AluOperWidth] y       ,   // 源操作数y, rk,oper2
    input  wire [`AluOpWidth] aluop   ,   // alu op
    input  wire [31:0]quotient_i,      
    input  wire [31:0]remainder_i,     
    input  wire div_complete_i,        
    
    output wire complete_o,//alu 运算完成
    output wire       div_en_o            ,
    output wire       div_sign_o          ,
    output wire [31:0]divisor_o           ,
    output wire [31:0]dividend_o          ,
    
    
    
    output wire mul_en_o,
    output wire [`MulPartOneDataWidth] mul_part_data_obus,
    output wire [`AluOperWidth] alu_rl_o,            // 运算结果 result
    output wire [`AluOperWidth]alu_rh_o 
    

);

/***************************************input variable define(输入变量定义)**************************************/

/***************************************output variable define(输出变量定义)**************************************/

 wire [63:0]  mul_part_data_s00;
 wire [63:0]  mul_part_data_c00;
 wire [63:0]  mul_part_data_s01;
 wire [63:0]  mul_part_data_c01;
 wire [63:0]  mul_part_data_s02;
 wire [63:0]  mul_part_data_c02;
 wire [63:0]  mul_part_data_s03;
 wire [63:0]  mul_part_data_c03;









/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
reg [`AluOperWidth] rl;
reg [`AluOperWidth] rh;
wire [63:0]x_sign,y_sign,x_zero,y_zero;

wire mul_sign;
wire [63:0]mul_result = 0;
wire mul_en = (aluop == `MulAluOp) || (aluop == `MuluAluOp);
/****************************************input decode(输入解码)***************************************/

/****************************************output code(输出解码)***************************************/
assign {alu_rh_o,alu_rl_o} = {rh,rl};
assign mul_part_data_obus = {
                              mul_part_data_s00,
                              mul_part_data_c00,
                              mul_part_data_s01,
                              mul_part_data_c01,
                              mul_part_data_s02,
                              mul_part_data_c02,
                              mul_part_data_s03,
                              mul_part_data_c03

                           };
 assign mul_en_o = mul_en;
/*******************************complete logical function (逻辑功能实现)*******************************/
    assign x_sign ={{32{x[31]}},x};
    assign y_sign ={ {32{y[31]}} , y };
    
    assign x_zero ={32'h0,x};
    assign y_zero ={32'h0,y};
    
    always @(*)begin                
        case(aluop)
            `SllAluOp: {rh,rl} = (x << y[4:0]);                     
            `SrlAluOp: {rh,rl} = (x >> y[4:0]);                     
            `SraAluOp: {rh,rl} = ($signed(x) >>> y[4:0]);           
       
           
            `AddAluOp: {rh,rl} = x + y;                            
            `SubAluOp: {rh,rl} = x - y;                            

            `AndAluOp: {rh,rl} =  (x & y);                         
            `OrAluOp : {rh,rl} =  (x | y);                         
            `XorAluOp: {rh,rl}=  (x ^ y);                          
            `NorAluOp: {rh,rl} = ~(x | y);                          

            `SltAluOp : {rh,rl} = ($signed(x) < $signed(y))? 1 : 0; 
            `SltuAluOp: {rh,rl} = (x < y)? 1 : 0;                   

            `LuiAluOp: {rh,rl} = {y[15:0], 16'h0000};               
            `MulAluOp: {rh,rl} = mul_result;  
            `MuluAluOp:{rh,rl} = mul_result;
            
            `DivAluOp:  {rh,rl}  = {quotient_i,remainder_i};
            `ModAluOp:  {rh,rl}  = {quotient_i,remainder_i};
            `DivuAluOp: {rh,rl}  = {quotient_i,remainder_i};
            `ModuAluOp: {rh,rl}  = {quotient_i,remainder_i};
          
            default: {rh,rl} = 0;
        endcase
    end
    
   
    
   
    assign complete_o =  div_en_o ? div_complete_i  : 1'b1;
    
    assign div_en_o    = (aluop == `DivAluOp) || (aluop == `ModAluOp) || (aluop == `DivuAluOp) || (aluop == `ModuAluOp) ? 1'b1 : 1'b0;                                                     
    assign div_sign_o  = (aluop == `DivAluOp) || (aluop == `ModAluOp) ? 1'b1 : 1'b0;                                                                                                             
    //被除数
    assign dividend_o  = x;  
    //除数
    assign divisor_o   = y;                                                                                                                                                                  
                                                                                                                                                                    
   
    assign mul_sign = (aluop == `MulAluOp) ? 1'b1 : 1'b0;
    
  

    wallace_mul_pipeline1 wallace_mul_pipeline1_item(
     .sign( mul_sign),
     .x   ( x),
     .y   ( y),
     .s00 (mul_part_data_s00),
     .c00 (mul_part_data_c00),
     .s01 (mul_part_data_s01),
     .c01 (mul_part_data_c01),
     .s02 (mul_part_data_s02),
     .c02 (mul_part_data_c02),
     .s03 (mul_part_data_s03),
     .c03 (mul_part_data_c03)
);
     
    
    
    
     
endmodule


