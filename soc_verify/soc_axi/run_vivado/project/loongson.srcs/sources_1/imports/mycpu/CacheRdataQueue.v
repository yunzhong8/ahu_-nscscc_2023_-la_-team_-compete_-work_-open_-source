/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：实现7一个队列,这是一个只支持一个写，一个读队列

/*************\
bug:
\*************/
`include "define.v"
module CacheRdataQueue
#(parameter DataLen= 31)
(
    input  wire  clk      ,
    input  wire  rst_n    ,
    

    input wire  we_i,

    input wire  [299:0]wdata_i,
    
    input wire update_en_i,//更新使能
    input wire update_way_i,//更新的way
    input wire [149:0]updata_data_i,

    input wire  used_i,

    output wire full_o,

    output wire [299:0]rdata_o,
    output wire rdata_valid_o 
   
);

/***************************************input variable define(输入变量定义)**************************************/
/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/

reg [DataLen:0] data0_queue[7:0];
reg [DataLen:0] data1_queue[7:0];
reg valid_queue[7:0];
reg [2:0]queue_head;
reg [2:0]queue_tail;
reg [3:0]queue_len;

/****************************************input decode(输入解码)***************************************/
/****************************************output code(输出解码)***************************************/
/*******************************complete logical function (逻辑功能实现)*******************************/

always@(posedge clk)begin
    if(rst_n == `RstEnable)begin
        queue_head<=4'd0;
    end else if(we_i)begin 
        queue_head <= queue_head +4'd1;
    end else begin
        queue_head <= queue_head;
    end
end


always@(posedge clk)begin
    if(rst_n == `RstEnable)begin
        queue_tail<=4'd0;   
    end else if(used_i)begin 
        queue_tail <= queue_tail +4'd1;
    end else begin
        queue_tail <= queue_tail;
    end
end

generate 
    genvar i ;
    //更新第0路
    for(i=0;i<8;i=i+1) begin : data_loop
        always@(posedge clk)begin
            if(rst_n == `RstEnable)begin
                data0_queue[i]<= 0;
            end else if(i==queue_head & we_i)begin 
                data0_queue[i]  <=wdata_i[149:0];
            end else if(used_i & i==queue_tail)begin
                 data0_queue[i]  <=0;
            end else if(~update_way_i & update_en_i& & i==queue_tail)begin
                 data0_queue[i] <= updata_data_i;
            end else begin
                data0_queue[i] <= data0_queue[i];
            end
        end
        
        //更新第一路
         always@(posedge clk)begin
            if(rst_n == `RstEnable)begin
                data1_queue[i]<= 0;
            end else if(i==queue_head & we_i)begin 
                data1_queue[i]  <=wdata_i[299:150];
            end else if(used_i & i==queue_tail)begin
                 data1_queue[i]  <=0;
            end else if( update_en_i& update_way_i & i==queue_tail)begin
                 data1_queue[i] <= updata_data_i;
            end else begin
                data1_queue[i] <= data1_queue[i];
            end
        end
        
        always@(posedge clk)begin
            if(rst_n == `RstEnable )begin
                valid_queue[i]<= 1'd0;
            end else if(i==queue_head &we_i)begin  
                valid_queue[i]  <= 1'b1;
             
            end else if(used_i & i==queue_tail)begin
                valid_queue[i]  <= 1'b0;
            end else begin
                valid_queue[i] <= valid_queue[i];
            end
        end 
  end 
endgenerate 
assign rdata_valid_o = valid_queue[queue_tail];
assign rdata_o       = {data1_queue[queue_tail],data0_queue[queue_tail]};

always@(posedge clk )begin
    if(rst_n == `RstEnable)begin
        queue_len <= 4'd0;
    end else if(we_i&~used_i)begin
        queue_len<=queue_len + 4'd1;
    end else if(~we_i&used_i)begin
        queue_len<=queue_len - 4'd1;
    end else if(we_i&used_i) begin
        queue_len<=queue_len;
    end 
end 

assign full_o = (queue_tail+1 == queue_head) ? 1'b0:1'b1;

endmodule
