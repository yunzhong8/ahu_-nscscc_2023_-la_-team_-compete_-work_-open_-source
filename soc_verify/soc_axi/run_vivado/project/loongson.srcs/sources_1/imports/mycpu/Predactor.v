`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/07 20:07:06
// Design Name: 
// Module Name: Predactor_Btb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// hit,和branch_pc要往下传递，方便id阶段返回修正btb表
//////////////////////////////////////////////////////////////////////////////////
//`include "DefineLoogLenWidth.h"
`include "define.v"
module Predactor(
input  wire                    rst_n        ,
input  wire                    clk          ,

input  wire  [`PcWidth]        pc_i         ,

input  wire                    if_allowin_i ,

output wire [`PrToIfBusWidth]  to_if_obus   ,

input wire  [`PtoWbusWidth]    id_to_ibus

    );
    
 /***************************************input variable define(输入变量定义)**************************************/

wire [`PhtWbusWidth]  pht_wbus_i ;
wire [`BtbWbusWidth]  btb_wbus_i ;
/***************************************output variable define(输出变量定义)**************************************/
 
 reg predict_valid_o ;
 
 wire branch_o ;

 wire [1:0]pht_rdata_o ;
 

 wire btb_hit_o;

 wire [`PcWidth]btb_branch_pc_o;





/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
wire [`PcWidth] btb_branch_pc;

/****************************************input decode(输入解码)***************************************/
assign {pht_wbus_i,btb_wbus_i} = id_to_ibus;
/****************************************output decode(输出解码)***************************************/
assign to_if_obus = {predict_valid_o,branch_o,pht_rdata_o,btb_hit_o,btb_branch_pc_o};

/*******************************complete logical function (逻辑功能实现)*******************************/

Predactor_Pht Predactor_Pht_item(
     .rst_n (rst_n)         ,
     .clk   (clk)           ,

     .w_ibus(pht_wbus_i)    ,
     
     .re_i    (if_allowin_i),
     .raddr_i (pc_i[12:3])  ,
     
     .rdata_o (pht_rdata_o)


    );





Predactor_Btb Predactor_Btb_item(
        .rst_n           (rst_n)         ,
        .clk             (clk)           ,
        .re_i            (if_allowin_i),
        .pc_i            (pc_i)          ,
        
        .w_ibus          (btb_wbus_i)    ,
        .hit_o           (btb_hit_o)     ,
        .btb_branch_pc_o (btb_branch_pc)
    );
    
   
    
   assign btb_branch_pc_o = btb_branch_pc;  
    
    assign branch_o = pht_rdata_o[1];
    
always @(posedge clk)begin
    if(rst_n==`RstEnable)begin
        predict_valid_o <= 1'b0;
    end else if(if_allowin_i)begin
        predict_valid_o <= 1'b1;
    end else begin
        predict_valid_o <= 1'b0;
    end
end    
    

    

endmodule

