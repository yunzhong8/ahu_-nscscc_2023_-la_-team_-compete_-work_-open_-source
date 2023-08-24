`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/07 18:43:25
// Design Name: 
// Module Name: Predactor_Pht
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
// 
//////////////////////////////////////////////////////////////////////////////////

`include "define.v"
module Predactor_Pht(
    input wire rst_n,
    input wire clk,
    
   
    input wire [`PhtWbusWidth]    w_ibus,
    
   
    input wire re_i,
    input wire [`ScountAddrWidth]raddr_i,
   
    output wire [`ScountStateWidth]rdata_o

  );
 /***************************************input variable define(输入变量定义)**************************************/   
 wire we_i;

 wire [`ScountAddrWidth]waddr_i;

 wire [`ScountStateWidth]wdata_i;
 wire [`ScountStateWidth]rdata;
 wire re;
 
 wire   rw_conflict ;
 assign rw_conflict = re_i&we_i&(waddr_i==raddr_i);
 assign re = rw_conflict ? 1'b0 : re_i;
 
 reg temp_we_i_reg;
 reg [`ScountStateWidth]temp_wdata_i_reg;
 
 //无需使用的接口
// wire [1:0]douta;
 
 /****************************************input decode(输入解码)***************************************/
 assign {we_i,waddr_i,wdata_i} =  w_ibus;
 
 /*******************************complete logical function (逻辑功能实现)*******************************/   
 assign rdata_o =temp_we_i_reg? temp_wdata_i_reg:rdata;


//伪双端口ram
pht_ram pht_ram_item (
  //写
  .clka(clk),    // input wire clka
  .ena(we_i),      // input wire ena
  .wea(we_i),      // input wire [0 : 0] wea
  .addra(waddr_i),  // input wire [9 : 0] addra
  .dina(wdata_i),    // input wire [1 : 0] dina
  //读
  .clkb(clk),    // input wire clkb
  .enb(re),      // input wire enb
  .addrb(raddr_i),  // input wire [9 : 0] addrb
  .doutb(rdata)  // output wire [1 : 0] doutb
);






always@(posedge clk)begin
    if(rst_n==`RstEnable)begin
        {temp_we_i_reg,temp_wdata_i_reg}<=0;
    end else if(rw_conflict)begin
        {temp_we_i_reg,temp_wdata_i_reg}<={we_i,wdata_i};
    end else begin
        {temp_we_i_reg,temp_wdata_i_reg}<=0;
    end 
end    
 
endmodule
