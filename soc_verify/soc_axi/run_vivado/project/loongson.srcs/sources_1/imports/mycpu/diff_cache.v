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
module diff_cache
(
    input  wire  clk      ,
    input  wire  rst_n    ,
    
    output wire error_o,
    input  wire[`CacheToDiffBusWidth] dcache_diff_ibus
    
    
    
    
   
    
   
);


 parameter LOOKUP     = `CacheStateLen'b0000_0010;//2
 wire [`CacheStateWidth]r_cs;
  wire [`CacheStateWidth]r_ns;
 wire req_in_lookup ;
assign  req_in_lookup = r_cs ==LOOKUP ;
/***************************************input variable define(输入变量定义)**************************************/
  wire wbc_handling_load_req_uncache, wbc_handling_load_req_cache_unhit;
        wire wbc_handling_store_req_cache_unhit;
        wire wbc_handling_cacop_model_zero,wbc_handling_cacop_model_one,wbc_handling_cacop_model_two;
 
  wire [`DiffWriteBlockInstNumWidth]diff_write_block;
 assign  {
 
 wbc_handling_load_req_uncache     ,
 wbc_handling_load_req_cache_unhit ,
                                   
 wbc_handling_store_req_cache_unhit,
                                   
 wbc_handling_cacop_model_zero     ,
 wbc_handling_cacop_model_one      ,
 wbc_handling_cacop_model_two      
 
 
 }= diff_write_block;
 
 
 
 
 wire [`DiffRefillInstNumWidth]diff_refill;
  wire refill_handling_load_req_uncache, refill_handling_load_req_cache_unhit;
         wire refill_handling_store_req_cache_unhit;
         wire refill_handling_cacop_model_two;
 
 assign  {
 refill_handling_cacop_model_two      ,
 refill_handling_load_req_uncache     ,
 refill_handling_load_req_cache_unhit ,
 refill_handling_store_req_cache_unhit
 } = diff_refill;
 
 wire replace_handling_load_req_uncache, replace_handling_load_req_cache_unhit;
         wire replace_handling_store_req_cache_unhit;
         wire replace_handling_cacop_model_two;
 
 wire [`DiffReplaceInstNumWidth]diff_replace;
 assign  {
            replace_handling_cacop_model_two      ,
            replace_handling_load_req_uncache     ,
            replace_handling_load_req_cache_unhit ,
            replace_handling_store_req_cache_unhit
            
            } = diff_replace ;
            
 wire [`DiffWriteBackInstNumWidth]diff_write_back;
 wire wbe_handling_load_req_cache_unhit_dirty,wbe_handling_load_req_cache_unhit_undirty;
 wire wbe_handling_cacop_model_two_hit_dirty, wbe_handling_cacop_model_two_hit_undirty ;
 wire wbe_handling_store_req_uncache,wbe_handling_store_req_cache_unhit_dirty,wbe_handling_store_req_cache_unhit_undirty;
 
 assign {
 
 wbe_handling_load_req_cache_unhit_dirty     ,
 wbe_handling_load_req_cache_unhit_undirty   ,
 wbe_handling_cacop_model_two_hit_dirty      ,
 wbe_handling_cacop_model_two_hit_undirty    ,
 wbe_handling_store_req_uncache              ,
 wbe_handling_store_req_cache_unhit_dirty    ,
 wbe_handling_store_req_cache_unhit_undirty  
 } = diff_write_back;
  
 wire [`DiffMissInstNumWidth]diff_miss;
  wire miss_handling_load_req_cache_unhit;
  wire miss_handling_cacop_model_two_hit;
  wire miss_handling_store_req_uncache,miss_handling_store_req_cache_unhit;
 
 
 
 assign  {
          miss_handling_load_req_cache_unhit  ,
          miss_handling_cacop_model_two_hit   ,
          miss_handling_store_req_uncache     ,
          miss_handling_store_req_cache_unhit 
 
 } =diff_miss ;
  
wire [`DiffLookUpInstNumWidth]diff_look_up;
wire lookup_handling_cacop_model_two_cancle  ;
wire lookup_handling_load_req_cancle         ;
wire lookup_handling_store_req_cancle        ;

wire lookup_handling_cacop_model_two_no_hit  ;
wire lookup_handling_cacop_model_two_hit     ;

wire lookup_handling_load_req_uncache        ;
wire lookup_handling_load_req_cache_hit      ;
wire lookup_handling_load_req_cache_unhit    ;

wire lookup_handling_store_req_uncache       ;
wire lookup_handling_store_req_cache_hit     ;
wire lookup_handling_store_req_cache_unhit   ;

assign {
    lookup_handling_cacop_model_two_cancle   ,
    lookup_handling_load_req_cancle          ,
    lookup_handling_store_req_cancle         ,
                                             
    lookup_handling_cacop_model_two_no_hit   ,
    lookup_handling_cacop_model_two_hit      ,
                                       
    lookup_handling_load_req_uncache         ,
    lookup_handling_load_req_cache_hit       ,
    lookup_handling_load_req_cache_unhit     ,
                                             
    lookup_handling_store_req_uncache        ,
    lookup_handling_store_req_cache_hit      ,
    lookup_handling_store_req_cache_unhit    

}=diff_look_up ;

wire [31:0]dirty_addr;
wire [127:0]dirty_data;
 wire[31:0] diff_handling_addr ;
 wire write_handling_store_req_cache,handling_way;
 wire [31:0]store_wdata,store_access_addr;
 wire [31:0]exrt_axi_rdata_buffer3,exrt_axi_rdata_buffer2,exrt_axi_rdata_buffer1,exrt_axi_rdata_buffer0;
 wire [19:0]cache_repalce_way_tag,cache_repalce_way1_tag,cache_repalce_way0_tag;
assign  { 
    cache_repalce_way_tag,cache_repalce_way1_tag,cache_repalce_way0_tag,
    exrt_axi_rdata_buffer3,exrt_axi_rdata_buffer2,exrt_axi_rdata_buffer1,exrt_axi_rdata_buffer0,
   write_handling_store_req_cache,handling_way,store_wdata,store_access_addr,
   dirty_addr,dirty_data,
   r_ns,
   r_cs,
   diff_handling_addr,//当前访问地址32
   diff_write_block ,//6
   diff_refill      ,//4
   diff_replace     ,//4
   diff_write_back  ,//7
   diff_miss        ,//4
   diff_look_up     //11

} =dcache_diff_ibus;
 

/***************************************output variable define(输出变量定义)**************************************/
/***************************************parameter define(常量定义)**************************************/

/***************************************inner variable define(内部变量定义)**************************************/

/****************************************input decode(输入解码)***************************************/
    
        
        
/****************************************output code(输出解码)***************************************/
wire error;
assign error = 1'b0;
//assign error = cs_eq_writeback&writeback_waddr==32'h1c002150;
reg [7:0]count;
always @(posedge clk)begin
    if(rst_n == `RstEnable)begin
        count<=0;
    end 
    else if(error|count!=0)begin
        count<=count+1;
    end 
end 
assign error_o = count==8'hff;
//assign error_o = line1_diff_load_en_i&line1_diff_ls_vaddr_i==32'h1c00215c;
/*******************************complete logical function (逻辑功能实现)*******************************/
integer handle_whole;

initial
    begin
        //r方式，被读的文件，用于获取激励信号输入值
       // handle1= $fopen("D:/Documents/Hardware_verlog/Teacher_example/txt/51.txt","r");
        //w方式，被写入的文件，用于写入系统函数的输出值
       
            handle_whole = $fopen(`Test_TRACE_WRITE_FILE_WHOLE_CACHE ,"w");
            
       
end


always @(posedge clk)begin    
        if(`dcache_trace_record_open)begin
            if(r_ns!=r_cs)begin
                    if(req_in_lookup)begin  
                        
                        if (lookup_handling_cacop_model_two_cancle )begin
                        end else if   (lookup_handling_load_req_cancle        )begin
                             $fwrite(handle_whole,"lookup_handling_load_req_cancle\t \n\n\n");
                        end else if   (lookup_handling_store_req_cancle       )begin
                        $fwrite(handle_whole,"lookup_handling_store_req_cancle\t \n\n\n");
                        end else if   (lookup_handling_cacop_model_two_no_hit )begin
                        $fwrite(handle_whole,"lookup_handling_cacop_model_two_no_hit\t");
                        end else if   (lookup_handling_cacop_model_two_hit    )begin
                        $fwrite(handle_whole,"lookup_handling_cacop_model_two_hit\t");
                        
                        end else if   (lookup_handling_load_req_uncache       )begin
                        $fwrite(handle_whole,"lookup_handling_load_req_uncache\t");
                        end else if   (lookup_handling_load_req_cache_hit     )begin
                        $fwrite(handle_whole,"lookup_handling_load_req_cache_hit\t  \n\n\n");
                        end else if   (lookup_handling_load_req_cache_unhit   )begin
                        $fwrite(handle_whole,"lookup_handling_load_req_cache_unhit\t");
                       
                        end else if   (lookup_handling_store_req_uncache      )begin
                        $fwrite(handle_whole,"lookup_handling_store_req_uncache\t");
                        end else if   (lookup_handling_store_req_cache_hit    )begin
                        $fwrite(handle_whole,"lookup_handling_store_req_cache_hit\t \n\n\n");
                        end else if   (lookup_handling_store_req_cache_unhit  )begin
                        $fwrite(handle_whole,"lookup_handling_store_req_cache_unhit\t");
                        end
                        $fwrite(handle_whole,"地址 %h\n",diff_handling_addr);
                   end
                   
                   
                   if (wbe_handling_load_req_cache_unhit_dirty     )begin
                     $fwrite(handle_whole,"wbe_handling_load_req_cache_unhit_dirty\t");
                     $fwrite(handle_whole,"替换way：%h\t 替换tag：%h\t way1tag：%h\t way0tag：%h\t, ",handling_way,cache_repalce_way_tag,cache_repalce_way1_tag,cache_repalce_way0_tag,);
                     $fwrite(handle_whole,"写回脏地址：%h\t",dirty_addr);
                     $fwrite(handle_whole,"写回脏数据：%h\t %h\t %h\t %h\t \n ",dirty_data[127:96],dirty_data[95:64],dirty_data[63:32],dirty_data[31:0]);
                     
                   end else if (wbe_handling_load_req_cache_unhit_undirty   )begin
                     $fwrite(handle_whole,"wbe_handling_load_req_cache_unhit_undirty\t \n");
                     
                     
                   end else if (wbe_handling_cacop_model_two_hit_dirty      )begin
                     $fwrite(handle_whole,"wbe_handling_cacop_model_two_hit_dirty\t");
                     $fwrite(handle_whole,"替换way：%h\t 替换tag：%h\t way1tag：%h\t way0tag：%h\t, ",handling_way,cache_repalce_way_tag,cache_repalce_way1_tag,cache_repalce_way0_tag,);
                     $fwrite(handle_whole,"写回脏地址：%h\t",dirty_addr);
                     $fwrite(handle_whole,"写回脏数据：%h\t %h\t %h\t %h\t\n ",dirty_data[127:96],dirty_data[95:64],dirty_data[63:32],dirty_data[31:0]);
                     
                   end else if (wbe_handling_cacop_model_two_hit_undirty    )begin
                     $fwrite(handle_whole,"wbe_handling_cacop_model_two_hit_undirty\t ");
                     
                   end else if (wbe_handling_store_req_uncache              )begin
                     $fwrite(handle_whole,"wbe_handling_store_req_uncache\t \n");
                     
                     
                   end else if (wbe_handling_store_req_cache_unhit_dirty    )begin
                     $fwrite(handle_whole,"wbe_handling_store_req_cache_unhit_dirty\t");
                     $fwrite(handle_whole,"替换way：%h\t 替换tag：%h\t way1tag：%h\t way0tag：%h\t, ",handling_way,cache_repalce_way_tag,cache_repalce_way1_tag,cache_repalce_way0_tag,);
                     $fwrite(handle_whole,"写回脏地址：%h\t",dirty_addr);
                     $fwrite(handle_whole,"写回脏数据：%h\t %h\t %h\t %h\t \n",dirty_data[127:96],dirty_data[95:64],dirty_data[63:32],dirty_data[31:0]);
                     
                   end else if (wbe_handling_store_req_cache_unhit_undirty  )begin
                     $fwrite(handle_whole,"wbe_handling_store_req_cache_unhit_undirty\t \n");
                   end
                   
                   
                   if( write_handling_store_req_cache)begin
                    
                    $fwrite(handle_whole,"store写入cache 路：%h\t 地址：%h\t 数据：%h\t \n\n\n",handling_way,store_access_addr,store_wdata);
                   end 
                   
                   
                   
                    if          (wbc_handling_load_req_uncache     )begin
                        $fwrite(handle_whole,"load axi读回  %h\t \n\n\n",exrt_axi_rdata_buffer0);
                    end else if (wbc_handling_load_req_cache_unhit )begin   
                        $fwrite(handle_whole,"load axi读回 %h\t %h\t %h\t %h\t \n\n\n",exrt_axi_rdata_buffer3,exrt_axi_rdata_buffer2,exrt_axi_rdata_buffer1,exrt_axi_rdata_buffer0);                          
                    end else if (wbc_handling_store_req_cache_unhit)begin
                        $fwrite(handle_whole,"load axi读回 %h\t %h\t %h\t %h\t \n\n\n",exrt_axi_rdata_buffer3,exrt_axi_rdata_buffer2,exrt_axi_rdata_buffer1,exrt_axi_rdata_buffer0);
                    end
        end
    end
  
     
       
end

endmodule
























