`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/19 18:27:27
// Design Name: 
// Module Name: cache_way
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
module cache_way(
input                           clk           ,
input  wire                     req_i         ,
input  wire [`CacheIndexWidth]  r_index_i     ,
output wire [149:0]             r_data_o      , //d_0,v,tag,data//1   1  20  128


//部分写
input wire  [`CacheIndexWidth]  w_index_i     ,//写地址
input wire  [1:0]               w_type_i      ,//10为全写，01为部分写，
input wire  [`CacheOffsetWidth] offset_i      ,//部分写的块内偏移地址                                             
input wire  [3:0]               wstrb_i       ,//部分写的字节使能
input wire  [149:0]             w_data_i       //发生部分写，则使用[31:0]位
                                                
    );
  /***************************************input variable define(输入变量定义)**************************************/
   //标记字段
   wire [20:0]tagv_wdata_i ;
   wire d_i;//脏数据位
   wire [127:0]data_i;//写入数据 
   wire [31:0]         dina0_i  ,dina1_i  , dina2_i  , dina3_i   ;
  /***************************************output variable define(输出变量定义)**************************************/ 
   wire [20:0]tagv_rdata_o ;
   reg d_o;
   wire [127:0]data_o;
  /***************************************inner variable define(内部变量定义)**************************************/ 
  reg d_reg[255:0];  
                                                                                                                                                                                                             

  
  wire [`CacheIndexWidth] data_addra0 , data_addra1 , data_addra2 , data_addra3 ;                 
  wire                    data_ena0   , data_ena1   , data_ena2   , data_ena3   ;
  wire [3:0]              data_wea0   , data_wea1   , data_wea2   , data_wea3   ;
  wire [31:0]             data_dina0  , data_dina1  , data_dina2  , data_dina3  ;   
  wire [31:0]             data_douta0 , data_douta1 , data_douta2 , data_douta3 ;                                                                                                
                                                                                
  wire [`CacheIndexWidth] tagv_addra;
  
 
  
  /***************************************inner variable define(输入解码)**************************************/   
  assign {tagv_wdata_i,data_i,d_i} = w_data_i ;
  assign {dina3_i,dina2_i,dina1_i,dina0_i} = data_i;
  
  /***************************************inner variable define(输出解码)**************************************/ 
  assign data_o = {data_douta3,data_douta2,data_douta1,data_douta0};

  assign r_data_o = {d_o,tagv_rdata_o,data_o};
  
 /***************************************inner variable define(逻辑实现)**************************************/  
   integer i;
    initial begin
        for(i=0;i<256;i=i+1) d_reg[i] = 0;   
    end
  
  always @(posedge clk)begin
    if(req_i && (w_type_i!=2'b00))begin
        d_reg[w_index_i]<= d_i;
    end
    
  end
  
  always@ (posedge clk )begin
    if(req_i&(w_type_i==2'd0))begin
        d_o<= d_reg[r_index_i];
     end else begin
        d_o <= d_o;
     end 
  end 
  
  
//tagv只有在全写模式才会进行写
  assign tagv_wea =   req_i && w_type_i[1] ;
  assign tagv_addra = (w_type_i==2'd0) ? r_index_i :w_index_i;   
    
 tagv_ram tagv_ram_item (
  .clka             ( clk         ),    
  .ena              ( req_i       ),      
  .wea              ( tagv_wea    ),      
  .addra            ( tagv_addra  ),  
  .dina             ( tagv_wdata_i),   
  .douta            ( tagv_rdata_o)  
);
    
  
                                                                                                                                                                                            
   assign {data_ena0,data_addra0,data_dina0,data_wea0} = w_type_i[1] ? {req_i,w_index_i,dina0_i,4'b1111} :(w_type_i[0] ? {req_i&&offset_i[3:2]==2'd0,w_index_i,dina0_i,wstrb_i}:{req_i,r_index_i,dina0_i,4'b0000});        
   assign {data_ena1,data_addra1,data_dina1,data_wea1} = w_type_i[1] ? {req_i,w_index_i,dina1_i,4'b1111} :(w_type_i[0] ? {req_i&&offset_i[3:2]==2'd1,w_index_i,dina0_i,wstrb_i}:{req_i,r_index_i,dina1_i,4'b0000});        
   assign {data_ena2,data_addra2,data_dina2,data_wea2} = w_type_i[1] ? {req_i,w_index_i,dina2_i,4'b1111} :(w_type_i[0] ? {req_i&&offset_i[3:2]==2'd2,w_index_i,dina0_i,wstrb_i}:{req_i,r_index_i,dina2_i,4'b0000});        
   assign {data_ena3,data_addra3,data_dina3,data_wea3} = w_type_i[1] ? {req_i,w_index_i,dina3_i,4'b1111} :(w_type_i[0] ? {req_i&&offset_i[3:2]==2'd3,w_index_i,dina0_i,wstrb_i}:{req_i,r_index_i,dina3_i,4'b0000});        
                    
                                                                                                                                                                                                                              
    
//数据域    
  data_bank bank0 (  
    .clka         ( clk         )  ,   
    .ena          ( data_ena0   )  ,   
    .wea          ( data_wea0   )  ,   
    .addra        ( data_addra0 )  ,   
    .dina         ( data_dina0  )  ,   
    .douta        ( data_douta0 )      
  );
 
  data_bank bank1 (                    
    .clka         ( clk         )  ,   
    .ena          ( data_ena1   )  ,   
    .wea          ( data_wea1   )  ,   
    .addra        ( data_addra1 )  ,   
    .dina         ( data_dina1  )  ,   
    .douta        ( data_douta1 )      
  );          
 
  data_bank bank2 (                                                                
    .clka         ( clk         )  ,   
    .ena          ( data_ena2   )  ,   
    .wea          ( data_wea2   )  ,   
    .addra        ( data_addra2 )  ,   
    .dina         ( data_dina2  )  ,   
    .douta        ( data_douta2 )      
  );                                   
 
 
  data_bank bank3 (                    
    .clka         ( clk         )  ,   
    .ena          ( data_ena3   )  ,   
    .wea          ( data_wea3   )  ,   
    .addra        ( data_addra3 )  ,   
    .dina         ( data_dina3  )  ,   
    .douta        ( data_douta3 )      
  );                                   
 
                     
                                                                                    
endmodule          