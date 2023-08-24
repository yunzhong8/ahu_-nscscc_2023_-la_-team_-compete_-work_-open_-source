/*
*作者：
*创建时间：
*email:
*github:
*输入：
*clk:除法器的时钟
*rst_n:复位信号，低电频表示复位
*y:被除数，位宽[31:0]
*x:除数,位宽[31:0]
*div:1表示除法，0表示取模
*div_signed:1表示有符号运算，0表示无符号运算
*输出：
*q：商，位宽[31:0],
*r: 余数，位宽[31:0]
*finished:除法完成信号，1表示完成，0表示还未完成
*模块功能：
*q=signed(y)/signed(x),q=unsigned(y)/unsigned(x),r=signed(y)%signed(x),r=unsigned(y)%unsigned(x)
*默认：一个数如果定义为有符号数，则该数是补码形式，在不使用$signed()情况下所有数都是无符号数，eg:$signed(4'hf)表示-1,4‘hf表示15
*/
/*************\

\*************/

`include "define.v"
module Div(
    input  wire  clk      ,
    input  wire  rst_n    ,

    input  wire  div_en_i,
    input  wire  div_signed_i   ,
    input  wire [`AluOperWidth]  divisor_i      ,
    input  wire [`AluOperWidth]  dividend_i     ,

    output wire [31:0]  quotient_o        ,
    output wire [31:0]  remainder_o       ,
    output reg   finished_o
);



/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/
wire [`AluOperWidth]unsign_divisor,unsign_dividend;
wire divisor_sign ,dividend_sign;
wire quotient_sign,remainder_sign;
reg [5:0]count;

reg [31:0]process_quotient ;
reg [31:0]process_remainder;



wire [63:0]expend_unsign_divisor; 



/*******************************complete logical function (逻辑功能实现)*******************************/
wire [`AluOperWidth]negative_divsor_source_code   = {1'b0,~divisor_i[30:0]+1};
wire [`AluOperWidth]negative_dividend_source_code = {1'b0,~dividend_i[30:0]+1} ;
assign unsign_divisor  = div_signed_i ? (divisor_i[31]  ? {1'b0,negative_divsor_source_code[30:0] }  : divisor_i[31:0]) : divisor_i[31:0];
assign unsign_dividend = div_signed_i ? (dividend_i[31] ? {1'b0,negative_dividend_source_code[30:0]} : dividend_i     ) : dividend_i;

assign divisor_sign = divisor_i[31];
assign dividend_sign = dividend_i[31] ;

assign quotient_sign  =  divisor_sign ^ dividend_sign;
assign remainder_sign = dividend_sign;

assign expend_unsign_divisor = unsign_divisor << count;


always @(posedge clk)begin
    if(rst_n == `RstEnable)begin
        count <= 6'd31;
    end else if ( div_en_i && count == 6'd63)begin
        count <= 6'd31;
    end else if (div_en_i)begin
        count <= count -6'd1;
    end else begin
        count <= count ;
    end
end

always @(posedge clk)begin
    if(rst_n == `RstEnable)begin
        process_quotient  <= 33'd0;
        process_remainder <= 32'd0;
        finished_o  <= 1'b0;
    end if (count == 6'd31 && div_en_i) begin
        if($unsigned(unsign_dividend) < $unsigned(expend_unsign_divisor))begin
            process_quotient[count] <= 1'b0;
            process_remainder       <= unsign_dividend;
            finished_o <= 1'b0;
        end else begin
            process_quotient[count] <= 1'b1;
            process_remainder       <= unsign_dividend - expend_unsign_divisor ;
            finished_o <= 1'b0;
        end
    end else if(count > 6'd0 && div_en_i && count < 6'd31) begin
        if(process_remainder < expend_unsign_divisor)begin        
            process_quotient[count] <= 1'b0;                               
            process_remainder       <= process_remainder;        
            finished_o <= 1'b0;                       
        end else begin                                               
            process_quotient[count] <= 1'b1;                                
            process_remainder       <= process_remainder - expend_unsign_divisor ;   
            finished_o <= 1'b0;   
        end                                                               
    end else if (count == 6'd0 && div_en_i)begin
        if(process_remainder < expend_unsign_divisor)begin                  
            process_quotient[count] <= 1'b0;                               
            process_remainder       <= process_remainder;    
            finished_o <= 1'b1;                           
        end else begin                                               
            process_quotient[count] <= 1'b1;                                
            process_remainder       <= process_remainder - expend_unsign_divisor ;    
            finished_o <= 1'b1;  
        end           
    end else begin
        finished_o <= 1'b0;
    end
end

wire [`AluOperWidth]negative_quotient_complement_o = {quotient_sign,~process_quotient [30:0]+1};
wire [`AluOperWidth]negative_remainder_complement_o = {remainder_sign,~process_remainder[30:0]+1};
assign quotient_o  = div_signed_i ? ( quotient_sign && (process_quotient!=32'd0)   ? {quotient_sign,negative_quotient_complement_o [30:0]} :process_quotient) :process_quotient ;
assign remainder_o = div_signed_i ? ( remainder_sign && (process_remainder!=32'd0) ? {remainder_sign,negative_remainder_complement_o[30:0]} :process_remainder)  :process_remainder;

endmodule
