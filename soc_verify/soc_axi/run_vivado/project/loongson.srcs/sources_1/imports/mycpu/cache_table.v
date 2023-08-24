`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/19 18:25:18
// Design Name: 
// Module Name: cache_table
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
//实现的是2路组相联
`include "define.v"
module cache_table(
input                           clk           ,

input  wire                     req_i         ,//读写请求
input  wire [`CacheIndexWidth]  r_index_i     ,//读地址
output wire [299:0]             r_data_o      ,//读出数据   //(20+1+1+128)*2=300 

//写
input wire                      way_i         ,//部分写和全写的wayid
input wire  [`CacheIndexWidth]  w_index_i     ,//部分写和全写的地址
input wire  [1:0]               w_type_i      ,//10为全写，01为部分写，00表示不写
input wire  [`CacheOffsetWidth] offset_i      ,//部分写的块内偏移地址（全写模式不考虑该值）                                             
input wire  [3:0]               wstrb_i       ,//部分写的字节使能（全写模式不考虑该值）
input wire  [149:0]             w_data_i       //部分写和全的写数据(发生部分写，则使用[31:1]位,[0]}

    );
    
    
  /***************************************inner variable define(内部变量定义)**************************************/    
  wire        way0_req,way1_req      ;
  wire [149:0]way0_r_data,way1_r_data;
 
 /***************************************inner variable define(输出解码)**************************************/ 
  assign r_data_o =  {way1_r_data,way0_r_data};    
 /***************************************inner variable define(逻辑实现)**************************************/
 

 assign way0_req =  (w_type_i == 2'd00) ? req_i :  (req_i & ~way_i) ; 
 assign way1_req =  (w_type_i == 2'd00) ? req_i :  (req_i &  way_i) ;
    
  cache_way cache_way_item0(                                                                              
     .clk          ( clk        )   ,                                                                                     
     .req_i        ( way0_req   )   ,                                                           
     .r_index_i    ( r_index_i  )   ,                                                  
     .r_data_o     ( way0_r_data)   ,                          
                                                                                                     
     //部分写                                                                                           
     .w_index_i    ( w_index_i )    ,                         
     .w_type_i     ( w_type_i  )    ,                                       
     .offset_i     ( offset_i  )    ,                                       
     .wstrb_i      ( wstrb_i   )    ,                    
     .w_data_i     ( w_data_i  )                              
                                                                                               
    );
         
  cache_way cache_way_item1(                                                 
     .clk          ( clk        )   ,                                             
     .req_i        ( way1_req   )   ,                                             
     .r_index_i    ( r_index_i  )   ,                                             
     .r_data_o     ( way1_r_data)   ,                                                                                        
                                                                             
     //部分写                                                                   
     .w_index_i    ( w_index_i )   ,                   
     .w_type_i     ( w_type_i  )   ,                   
     .offset_i     ( offset_i  )   ,                   
     .wstrb_i      ( wstrb_i   )   ,                   
     .w_data_i     ( w_data_i  )                       
                                                                              
    );                                                                                                                                              
    
endmodule
