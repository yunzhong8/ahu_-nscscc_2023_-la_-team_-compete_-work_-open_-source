/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：实现7一个队列,这是一个只支持一个写，一个读队列

*/
/*************\
bug:
\*************/
`include "define.v"
module Queue
#(parameter DataLen= 31)
(
    input  wire  clk      ,
    input  wire  rst_n    ,
    
    //队列写使能
    input wire  we_i,
    //队列写数据
    input wire  [DataLen:0]wdata_i,
    //队列读出数据被使用完了
    input wire  used_i,
    //队列满信号
    output wire full_o,
    
    //队列读数据
    output wire [DataLen:0]rdata_o,
    output wire [DataLen:0]rdata2_o,
    output wire rdata_valid_o 
   
);

/***************************************input variable define(输入变量定义)**************************************/
/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
//队列空间设置为8
reg [DataLen:0] data_queue[7:0];
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
    for(i=0;i<8;i=i+1) begin : data_loop
        always@(posedge clk)begin
            if(rst_n == `RstEnable)begin
                data_queue[i]<= 0;
            end else if(i==queue_head & we_i)begin 
                data_queue[i]  <=wdata_i;
            end else if(used_i & i==queue_tail)begin
                 data_queue[i]  <=0;
            end else begin
                data_queue[i] <= data_queue[i];
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
wire [2:0]rdata2_addr = queue_tail + 3'd1;
assign rdata_valid_o = valid_queue[queue_tail];
assign  rdata_o      = data_queue[queue_tail];
assign  rdata2_o    = data_queue[rdata2_addr];

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
