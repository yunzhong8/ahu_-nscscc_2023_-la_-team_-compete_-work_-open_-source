//`include "DefineModuleBus.h"
`include "define.v"
module Reg_File(
               input wire                           rf_in_rstL,
               input wire                           rf_in_clk,
               //输入
               
               input wire  [`RegsReadIbusWidth] read_ibus,
               input wire  [`RegsWriteBusWidth] write_ibus,
               
               output  [`RegsToDiffBusWidth]   to_diff_obus,
               output wire [`RegsReadObusWidth] read_obus    
                   
    );

 
 
 /***************************************input variable define(输入变量定义)**************************************/
 //读端口1 
         wire                      rf_in_re1           ; //1号端口读使能信号 
         wire [`RegsAddrWidth]     rf_in_raddr1        ;// 1号端口读地址 
    //读端口2
         wire                      rf_in_re2           ;//2号端口读使能信号 
         wire [`RegsAddrWidth]     rf_in_raddr2        ;// 2号端口读地址 
    //写端口 
         wire                      rf_in_we1            ;//写使能信号
         wire [`RegsAddrWidth]     rf_in_waddr1         ; //写地址
         wire [`RegsDataWidth]     rf_in_wdata1         ;//写数据
         
 //读端口3 
         wire                      rf_in_re3           ; //1号端口读使能信号 
         wire [`RegsAddrWidth]     rf_in_raddr3        ;// 1号端口读地址 
    //读端口4
         wire                      rf_in_re4           ; //2号端口读使能信号 
         wire [`RegsAddrWidth]     rf_in_raddr4        ;// 2号端口读地址 
    //写端口 
         wire                    rf_in_we2            ;//写使能信号
         wire [`RegsAddrWidth]     rf_in_waddr2         ; //写地址
         wire [`RegsDataWidth]     rf_in_wdata2         ;//写数据
  
         
         
       
/***************************************output variable define(输出变量定义)**************************************/
//输出
           reg [`RegsDataWidth]         rf_out_rdata1       ;
           reg [`RegsDataWidth]         rf_out_rdata2       ;
           reg [`RegsDataWidth]         rf_out_rdata3       ;
           reg [`RegsDataWidth]         rf_out_rdata4       ;   
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
	reg[`RegsDataWidth]Regs[0:`RegsNum-1];
	integer i;

	

/****************************************input decode(输入解码)***************************************/
assign {rf_in_re4,rf_in_raddr4,rf_in_re3,rf_in_raddr3,rf_in_re2,rf_in_raddr2,rf_in_re1,rf_in_raddr1} = read_ibus;
assign {rf_in_we2,rf_in_waddr2,rf_in_wdata2,rf_in_we1,rf_in_waddr1,rf_in_wdata1} = write_ibus;
/****************************************output code(输出解码)***************************************/
assign read_obus = {rf_out_rdata4,rf_out_rdata3 ,rf_out_rdata2,rf_out_rdata1};
/*******************************complete logical function (逻辑功能实现)*******************************/

 always @(posedge rf_in_clk) begin
        if(rf_in_rstL==`RstEnable)begin
            for(i=0;i<32;i=i+1) Regs[i] <= 32'h0000_0000;
        end else begin
                if( ( rf_in_we1 == `WriteEnable )&& ( rf_in_waddr1 !=`RegsAddrLen'h0)&&( rf_in_we2 == `WriteEnable )&& ( rf_in_waddr2 !=`RegsAddrLen'h0) )begin
                       if(rf_in_waddr1!=rf_in_waddr2)begin
                           Regs[rf_in_waddr1] <= rf_in_wdata1;
                           Regs[rf_in_waddr2] <= rf_in_wdata2;
                       end else begin
                           Regs[rf_in_waddr2] <= rf_in_wdata2;
                       end
                end else if (( rf_in_we1 == `WriteEnable )&& ( rf_in_waddr1 !=`RegsAddrLen'h0))begin
                    Regs[rf_in_waddr1] <= rf_in_wdata1;
                end else if (( rf_in_we2 == `WriteEnable )&& ( rf_in_waddr2 !=`RegsAddrLen'h0))begin
                    Regs[rf_in_waddr2] <= rf_in_wdata2;
                end else begin 
                     for(i=0;i<32;i=i+1) Regs[i] <= Regs[i];
                end  
         end
    end
 
 //$$$$$$$$$$$$$$$（1号端口读操作模块）$$0$$$$$$$$$$$$$$$$// 
 always @(*)begin
        if(rf_in_rstL == `RstEnable)begin
            rf_out_rdata1<=`ZeroWord32B;
        end else if(rf_in_raddr1==`RegsAddrLen'h0) begin
            rf_out_rdata1<=`ZeroWord32B;       
        end else  if( (rf_in_raddr1==rf_in_waddr1)&&(rf_in_we1 == `WriteEnable)&&(rf_in_re1 ==`ReadEnable) )begin 
            rf_out_rdata1<=rf_in_wdata1;
        end else  if( (rf_in_raddr1==rf_in_waddr2)&&(rf_in_we2 == `WriteEnable)&&(rf_in_re1 ==`ReadEnable) )begin 
            rf_out_rdata1<=rf_in_wdata2;
        end else begin //读
            rf_out_rdata1<=Regs[rf_in_raddr1];
        end                 
 end
//$$$$$$$$$$$$$$$（2号端口读操作模块）$$0$$$$$$$$$$$$$$$$// 
 always @(*)begin
        if( rf_in_rstL == `RstEnable )begin//复位
             rf_out_rdata2<=`ZeroWord32B; 
       end else  if(rf_in_raddr2==`RegsAddrLen'h0)begin
             rf_out_rdata2<=`ZeroWord32B;
       end else  if( (rf_in_raddr2==rf_in_waddr1)&&(rf_in_we1 == `WriteEnable)&&(rf_in_re2 ==`ReadEnable) )begin
             rf_out_rdata2<=rf_in_wdata1;
       end else  if( (rf_in_raddr2==rf_in_waddr2)&&(rf_in_we2 == `WriteEnable)&&(rf_in_re2 ==`ReadEnable) )begin
             rf_out_rdata2<=rf_in_wdata2;
       end else begin //读
             rf_out_rdata2<=Regs[rf_in_raddr2];
       end
 end
 //$$$$$$$$$$$$$$$（3号端口读操作模块）$$0$$$$$$$$$$$$$$$$// 
 always @(*)begin
        if( rf_in_rstL == `RstEnable )begin//复位
             rf_out_rdata3<=`ZeroWord32B; 
       end else  if(rf_in_raddr3==`RegsAddrLen'h0)begin
             rf_out_rdata3<=`ZeroWord32B;
       end else  if( (rf_in_raddr3==rf_in_waddr1)&&(rf_in_we1 == `WriteEnable)&&(rf_in_re3 ==`ReadEnable) )begin
             rf_out_rdata3<=rf_in_wdata1;
       end else  if( (rf_in_raddr3==rf_in_waddr2)&&(rf_in_we2 == `WriteEnable)&&(rf_in_re3 ==`ReadEnable) )begin
             rf_out_rdata3<=rf_in_wdata2;
       end else begin //读
             rf_out_rdata3<=Regs[rf_in_raddr3];
       end
 end
 //$$$$$$$$$$$$$$$（4号端口读操作模块）$$0$$$$$$$$$$$$$$$$// 
 always @(*)begin
        if( rf_in_rstL == `RstEnable )begin//复位
             rf_out_rdata4 <=`ZeroWord32B; 
       end else  if(rf_in_raddr4 ==`RegsAddrLen'h0)begin
             rf_out_rdata4 <=`ZeroWord32B;
       end else  if( (rf_in_raddr4 == rf_in_waddr1)&&(rf_in_we1 == `WriteEnable)&&(rf_in_re4 ==`ReadEnable) )begin
             rf_out_rdata4 <= rf_in_wdata1;
       end else  if( (rf_in_raddr4 == rf_in_waddr2)&&(rf_in_we2 == `WriteEnable)&&(rf_in_re4 ==`ReadEnable) )begin
             rf_out_rdata4<=rf_in_wdata2;
       end else begin //读
             rf_out_rdata4<=Regs[rf_in_raddr4];
       end
 end
 //
 assign   to_diff_obus = {
        Regs[0]     ,
        Regs[1]     ,
        Regs[2]     ,
        Regs[3]     ,
        Regs[4]     ,
        Regs[5]     ,
        Regs[6]     ,
        Regs[7]     ,
        Regs[8]     ,
        Regs[9]     ,
        Regs[10]    ,
        Regs[11]    ,
        Regs[12]    ,
        Regs[13]    ,
        Regs[14]    ,
        Regs[15]    ,
        Regs[16]    ,
        Regs[17]    ,
        Regs[18]    ,
        Regs[19]    ,
        Regs[20]    ,
        Regs[21]    ,
        Regs[22]    ,
        Regs[23]    ,
        Regs[24]    ,
        Regs[25]    ,
        Regs[26]    ,
        Regs[27]    ,
        Regs[28]    ,
        Regs[29]    ,
        Regs[30]    ,
        Regs[31]    

 };
 
endmodule
 

