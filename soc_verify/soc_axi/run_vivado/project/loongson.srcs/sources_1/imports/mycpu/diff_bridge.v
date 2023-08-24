/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：实现7一个队列,这是一个只支持一个写，一个读队列
问题：队列的的关键元素是什么，我需要根据这个这元素设置输入输出
*队尾移动
lunch允许输入
    
lunch:发射了两条指令,则移动两个
lunch:发射了两条空指令,则不移动
lunch:发射了一条指令,则移动一个
队头移动
当前阶段允许输入
输入两条有效指令则队头移动2
输入一条有效指令则队头移动1
输入0条有效指令,则不移动
*/
/*************\
bug:
\*************/
//`include "DefineModuleBus.h"
`include "define.v"
module diff_bridge
(
    input  wire  clk      ,
    input  wire  rst_n    ,
    
    output wire error_o,
    input  wire[`BridgeToDiffBusWidth] to_diff_ibus
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
);


 
/***************************************input variable define(输入变量定义)**************************************/
           wire  [3 :0] ila_axi_arid_o        ;
           wire  [31:0] ila_axi_araddr_o      ;
           wire  [7 :0] ila_axi_arlen_o       ;//由cache提供,部分读则值0,全读则值3(128bit4个32)
           wire  [2 :0] ila_axi_arsize_o      ;
  
           wire         ila_axi_arvalid_o     ;
           wire         ila_axi_arready_i     ;
          //r
           wire  [3 :0] ila_axi_rid_i     ;
           wire  [31:0] ila_axi_rdata_i   ;
           wire         ila_axi_rlast_i   ;//读返回的最后一个数据据使能信号
           wire         ila_axi_rvalid_i  ;
           wire         ila_axi_rready_o  ;
          //aw
           wire  [3 :0] ila_axi_awid_o    ;//不涉及
           wire  [31:0] ila_axi_awaddr_o  ;
           wire  [7 :0] ila_axi_awlen_o   ;//不涉及
           wire         ila_axi_awvalid_o ;
           wire         ila_axi_awready_i ;
          //w
          wire  [31:0]  ila_axi_wdata_o  ;
          wire  [3 :0]  ila_axi_wstrb_o  ;
          wire          ila_axi_wlast_o  ;//不涉及
          wire          ila_axi_wvalid_o ;
          wire          ila_axi_wready_i ;
          //b
          
           wire         ila_axi_bvalid_i;
           wire         ila_axi_bready_o;

/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/

/****************************************input decode(输入解码)***************************************/
 assign {  
   
 ila_axi_arid_o   ,ila_axi_araddr_o ,ila_axi_arlen_o  ,//4+31+8//43  
                
                
 ila_axi_arvalid_o,ila_axi_arready_i,//2  
                
 ila_axi_rid_i    ,ila_axi_rdata_i  ,ila_axi_rlast_i  ,ila_axi_rvalid_i ,ila_axi_rready_o ,//4+32+1+1+1//39  
                
 ila_axi_arsize_o  ,ila_axi_wstrb_o   ,ila_axi_awaddr_o ,ila_axi_awlen_o  ,ila_axi_awvalid_o,ila_axi_awready_i,//3+4+32+8+1+1=49  
                
 ila_axi_wdata_o  ,ila_axi_wlast_o  ,ila_axi_wvalid_o ,ila_axi_wready_i ,//+32+1+1+1=35  
                
 ila_axi_bvalid_i ,ila_axi_bready_o //1+1=2  
                
   
                
   
 } = to_diff_ibus;//2+35+49+39+2+43=  
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
    
        
        
/****************************************output code(输出解码)***************************************/

/*******************************complete logical function (逻辑功能实现)*******************************/
integer handle_whole;

initial
    begin
        //r方式，被读的文件，用于获取激励信号输入值
       // handle1= $fopen("D:/Documents/Hardware_verlog/Teacher_example/txt/51.txt","r");
        //w方式，被写入的文件，用于写入系统函数的输出值
       
            handle_whole = $fopen(`Test_TRACE_WRITE_FILE_WHOLE_BRIDGE ,"w");
            
       
end


always @(posedge clk)begin    
        if(`bridge_trace_record_open)begin
               if(ila_axi_arvalid_o&ila_axi_arready_i&ila_axi_arid_o==4'd1)begin  
                    $fwrite(handle_whole," 读地址：%h\t %h\t %h\t\n",ila_axi_arid_o,ila_axi_araddr_o,ila_axi_arlen_o);
               end
               
               if   (ila_axi_rready_o&ila_axi_rvalid_i&ila_axi_arid_o==4'd1&~ila_axi_rlast_i       )begin
                    $fwrite(handle_whole,"读返回数据：%h\t %h\t \n",ila_axi_rid_i    ,ila_axi_rdata_i  );
               end else if(ila_axi_rlast_i &ila_axi_rvalid_i&ila_axi_rready_o&ila_axi_arid_o==4'd1)begin
                    $fwrite(handle_whole,"读返回数据：%h\t %h\t \n \n \n ",ila_axi_rid_i    ,ila_axi_rdata_i  ); 
               end 
                
                
                              
                // `ifdef USE_SIMPLE_BRIDGE
                 //`else
                if   (ila_axi_awvalid_o&ila_axi_awready_i)begin
                $fwrite(handle_whole,"写回地址%h\t %h\t %h\t %h\t\n",ila_axi_arsize_o  ,ila_axi_wstrb_o   ,ila_axi_awaddr_o ,ila_axi_awlen_o );
                end
                
                
                 if   (ila_axi_wvalid_o &ila_axi_wready_i &~ila_axi_wlast_o    )begin
                    $fwrite(handle_whole,"写回数据%h\t", ila_axi_wdata_o  );
                 end else if (ila_axi_wvalid_o &ila_axi_wready_i &ila_axi_wlast_o)begin
                    $fwrite(handle_whole,"%h\t\n", ila_axi_wdata_o  );
                 end 
                
                if   (ila_axi_bvalid_i &ila_axi_bready_o       )begin
                    $fwrite(handle_whole,"写完成\n\n\n");
                end
//               `endif
                
        end
         
       
end

endmodule
























