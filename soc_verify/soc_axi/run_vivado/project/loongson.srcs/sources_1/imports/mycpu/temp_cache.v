`timescale 1ns / 1ps
/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：实现的是一个2路组相联的cache,
*每一路的大小4KB
*使用的是随机替换的路策略
*读命中:需要两个时钟周期读出数据
*读未命中:需要至少5个时钟周期,最多:9个时钟周期
*写命中:2个时钟周期,(3实际使用了3个时钟周期),只是第3个时钟周期如果不是访存指令是不会阻塞CPU流水线的
*写未命中:2个时钟周期(实际使用最多时钟周期),只是在2~9过程中如果不出现访存指令是不会阻塞CPU流水
*规定:写外部aix的时候,部分写的时候,写的数据在w_data[31:0]位
*/
/*************\

\*************/

`include "define.v"
module temp_cache(
 input  wire                         clk                ,
 input  wire                         resetn             ,
 input  wire                         valid_i            ,
 input  wire                         op_i               ,
 input  wire [`CacheOffsetWidth]     offset_i           ,
 input  wire [`CacheIndexWidth]      index_i            ,
 input  wire [`CacheTagWidth]        tag_i              ,
 
 //cache维护指令
 input wire                          cacop_req_i,           
 input wire [ 1:0]                   cacop_op_mode_i         ,  
 input wire [ 7:0]                   cacop_op_addr_index_i   , 
 input wire [19:0]                   cacop_op_addr_tag_i     , 
 input wire [ 3:0]                   cacop_op_addr_offset_i  ,
 
 
 input  wire                         uncache_i          ,
 input  wire                         store_buffer_to_cache_or_ram_we_i  ,
 input  wire                         clear_store_buffer_en_i            ,
 input  wire                         handling_access_cancle_i           ,
 input  wire                         cpu_mmu_finish_i                   ,

 input  wire [`CacheWstrbWidth]      store_wstrb_i              ,
 input  wire [31:0]                  store_wdata_i              ,
                                                    
 output wire                         addr_ok_o                  ,
 output wire                         data_ok_o                  ,
                                                        
 output wire                         axi_rd_req_o             ,
 output wire [2:0]                   axi_rd_type_o            ,
 output wire [31:0]                  axi_rd_addr_o            ,
 input  wire                         axi_rd_rdy_i             ,
 
 input  wire                         axi_ret_valid_i          ,
 input  wire                         axi_ret_last_i           ,
 input  wire [31:0]                  axi_ret_data_i           ,
                                                       
 output wire                         axi_wr_req_o             ,
 output wire [2:0]                   axi_wr_type_o            ,
 output wire [31:0]                  axi_wr_addr_o            ,
 output wire [3:0]                   axi_wr_wstrb_o           ,
 output wire  [`CacheBurstDataWidth] axi_wr_data_o            ,
 input  wire                         axi_wr_rdy_i             ,
 
 //cache报错信息
 output wire     [`CacheDisposeInstNumWidth] wait_dispose_inst_num_o             ,
 output wire                       error_o,
 
 output wire                        cache_free_o             ,
 output wire      [`CacheStateWidth]             cs_o                     ,          
 output wire                        uncache_en_buffer_o      ,          
 output wire     [31:0]             search_addr_buffer_o     ,          
 output wire     [31:0]             exrt_axi_rdata_buffer0_o ,          
 output wire     [31:0]             exrt_axi_rdata_buffer1_o ,          
 output wire     [31:0]             exrt_axi_rdata_buffer2_o ,          
 output wire     [31:0]             exrt_axi_rdata_buffer3_o ,          
 output wire                        way0_cache_hit_o         ,          
 output wire                        way1_cache_hit_o         ,          
 output wire     [299:0]            search_buffer_o           ,          
 
 
 //差分测试端口
output wire [`CacheToDiffBusWidth]diff_to_obus
                     
    );
    /***************************************input variable define(输入变量定义)**************************************/
  /***************************************output variable define(输出变量定义)**************************************/
   
  /***************************************parameter define(常量定义)**************************************/  
  parameter RIDLE      = `CacheStateLen'b0000_0000;//0
  parameter READ       = `CacheStateLen'b0000_0001;//1
  parameter LOOKUP     = `CacheStateLen'b0000_0010;//2
  parameter WRITE      = `CacheStateLen'b0000_0100;//3
  parameter MISS       = `CacheStateLen'b0000_1000;//4
  parameter WRITEBACK  = `CacheStateLen'b0001_0000;//5
  parameter REPLACE    = `CacheStateLen'b0010_0000;//6
  parameter REFILL     = `CacheStateLen'b0100_0000;//7
 
  parameter WRITEBLOCK = `CacheStateLen'b1000_0000;//7;
  
  reg [`CacheStateWidth] r_cs;
  wire[`CacheStateWidth] r_ns;
  
  
   
  /***************************************inner variable define(内部变量定义)**************************************/ 
  //CPU输入缓存变量信息
     wire       cpu_request_part1_queue_we;
     wire       cpu_request_part1_queue_ce;
     wire [15:0] cpu_request_part1_queue_wdata;
     wire [11:0]cpu_request_index_offest;
     
     wire cpu_request_part2_queue_ce;
     wire cpu_request_part2_queue_we;
     wire [21:0]cpu_request_part2_queue_wdata;
     wire [19:0]cpu_req_tag;
     
     
     //store指令缓存数据
      wire store_buffer_queue_we;
      wire store_buffer_queue_ce;
      wire [35:0]store_buffer_queue_wdata;
      wire store_buffer_queue_valid;
      
  //cache查找结果输出缓存
      wire cache_table_read_queue_we;
      wire cache_table_read_queue_ce;
      wire cache_table_update_en;
      wire cache_table_update_way;
      wire [149:0]cache_table_update_data;
      wire [299:0]cache_table_read_queue_wdata;
      wire [299:0]cache_table_read_queue_rdata;
      wire cache_table_read_queue_valid;

      wire [149:0]handling_cache_table_way1_rdata,handling_cache_table_way0_rdata;
      
      wire [149:0]handling_cache_table_way1_write_black_data,handling_cache_table_way0_write_black_data;
      wire handling_req_cache_rdata_dirty;
  //AXI输入缓存
     wire        axi_write_count_ce;
     wire        axi_write_count_we      ; 
     reg  [1:0]  axi_write_count         ;
     reg  [31:0] exrt_axi_rdata_buffer0,exrt_axi_rdata_buffer1,exrt_axi_rdata_buffer2,exrt_axi_rdata_buffer3;
     

     wire cache_re    ; 
     wire cache_we    ;
     wire cache_coe   ;
     wire no_cache_req;
  
    
  
  //cache正在处理的访问请求的属性信息
     wire [11:0]now_req_cache_index_offest;
     wire [19:0]now_req_cache_tag;
     wire   now_req_hit_repalce_way;
    
    wire       handling_cacop_en;
    wire [1:0]handling_cacop_op_mode;
    
    //cache等待处理的请求信息
    wire waiting_cacop_en;
    wire [1:0]waiting_cacop_op_mode;
    wire waiting_store_access;
    wire [11:0]waiting_req_index_offest;
    
    wire       handling_store_access;
    wire [31:0]handling_access_addr;
    wire       handling_valid;
    wire       hit_or_replace_way;
    
    wire handling_uncache;
    
   
    wire [31:0]handling_store_wdata;
    wire [3:0] handling_store_wstrb;
    
    wire       handling_req_finish;
   
   
    wire cache_hit;
    wire way0_cache_hit;
    wire way1_cache_hit;
   
   
    wire  cache_repalce_way0_valid,cache_repalce_way0_dirty;
    wire  cache_repalce_way1_valid, cache_repalce_way1_dirty;
    wire  cache_rdata_way0_dirty,cache_rdata_way1_dirty;
    wire [19:0]cache_repalce_way_tag,cache_repalce_way0_tag, cache_repalce_way1_tag;
    
  
    wire having_stage_two_req;
    wire no_stage_two_req;
    wire having_store_stage_two_req;
    wire having_unstore_stage_two_req;
    wire stage_two_can_to_three;
    wire stage_two_cant_to_three;

     
       wire cache_table_en;
     
       wire [7:0]   cache_table_rindex;
       wire [299:0] cache_table_rdata   ;
       
       wire [1:0]   cache_table_wtype; 
       
       wire              cache_table_wway;
       wire     [7:0]    cache_table_windex  ;
       wire [3:0]        cache_table_woffset;
       wire [3:0]        cache_table_wstr;
       
       
       wire [19:0]  cache_table_wtag      ;
       wire         cache_table_wv                    ;
       wire         cache_table_wd                    ; 
       wire [31:0]  cache_table_wdata0                ;
       wire [127:0] cache_table_wdata                 ;
       wire [149:0] cache_table_wdatabus            ;
      
     
      
      
    
  
    
 /***************************************inner variable define(内部变量定义)**************************************/
    wire rcs_eq_ridle     ;    
    wire rcs_eq_read      ;    
    wire rcs_eq_lookup    ;    
    wire rcs_eq_miss      ;    
    wire rcs_eq_write     ;    
    wire rcs_eq_writeback ;    
    wire rcs_eq_replace   ;    
    wire rcs_eq_refill    ;    
    wire rcs_eq_writeblock;
    
    wire  [`CacheStateWidth]cs_eq_ridle_ns  ,
               cs_eq_read_ns      ,
               cs_eq_lookup_ns    ,
               cs_eq_miss_ns      ,
               cs_eq_write_ns     ,
               cs_eq_writeback_ns ,
               cs_eq_replace_ns   ,
               cs_eq_refill_ns    ,
               cs_eq_writeblock_ns ;
    
     
    
    
        wire ridle_handling_store_uncache,ridle_handling_store_cache;
         wire ridle_can_respone_cacop_mode_zero,ridle_can_respone_cacop_mode_one,ridle_can_respone_cacop_mode_two;
         wire ridle_can_respone_ls;
         wire ridle_respone_ls;
         wire ridle_respone_load,ridle_respone_store;
   
    
    //read
    
     wire read_can_respone_ls;
     wire read_respone_ls;
     wire read_respone_load,read_respone_store;
   
     wire read_handling_load,read_handling_store,read_handling_cacop_model_two;
    
   
        wire lookup_handling_load_req_cancle,lookup_handling_store_req_cancle,lookup_handling_cacop_model_two_cancle;
        wire lookup_handling_load_req_uncache,lookup_handling_load_req_cache_hit,lookup_handling_load_req_cache_unhit;
        wire lookup_handling_cacop_model_two_no_hit,lookup_handling_cacop_model_two_hit;
        wire lookup_handling_store_req_uncache,lookup_handling_store_req_cache_hit,lookup_handling_store_req_cache_unhit;
    
    
        wire lookup_no_write_cache_req_finish;
        wire lookup_can_respone_ls;
        wire lookup_respone_ls;
        wire lookup_no_stage_two_can_respone_ls ,lookup_stage_two_unstore_can_to_lookup_respone_ls;
        wire lookup_respone_load,lookup_respone_store;
     
        wire lookup_req_finish;
    
   
    //miis阶段处理的指令类型
        wire miss_handling_load_req_cache_unhit;
        wire miss_handling_cacop_model_two_hit;
        wire miss_handling_cacop_model_one;
        wire miss_handling_store_req_uncache,miss_handling_store_req_cache_unhit;
       
       wire miss_send_data_ok;
        
    
    //writeback处理指令类型
        wire wbe_handling_load_req_cache_unhit_dirty,wbe_handling_load_req_cache_unhit_undirty;
        wire wbe_handling_cacop_model_one;
        wire wbe_handling_cacop_model_one_dirty,wbe_handling_cacop_model_one_undirty;
        wire wbe_handling_cacop_model_two_hit_dirty, wbe_handling_cacop_model_two_hit_undirty ;
        wire wbe_handling_store_req_uncache,wbe_handling_store_req_cache_unhit_dirty,wbe_handling_store_req_cache_unhit_undirty;
        
       
        wire wbe_can_respone_ls;   
        wire wbe_respone_ls; 
        wire wbe_no_stage_two_can_respone_ls ,wbe_stage_two_unstore_can_to_lookup_respone_ls;
        wire wbe_respone_load,wbe_respone_store;
        
        wire wbe_req_finish;
        wire wbe_no_write_cache_req_finish;
    
    
    //replace
        wire replace_handling_load_req_uncache, replace_handling_load_req_cache_unhit;
        wire replace_handling_store_req_cache_unhit;
        wire replace_handling_cacop_model_two;
        
    //refill
        wire refill_handling_load_req_uncache, refill_handling_load_req_cache_unhit;
        wire refill_handling_store_req_cache_unhit;
        wire refill_handling_cacop_model_two;
    
    //write_back_cache
   
        wire wbc_handling_load_req_uncache, wbc_handling_load_req_cache_unhit;
        wire wbc_handling_store_req_cache_unhit;
        wire wbc_handling_cacop_model_zero,wbc_handling_cacop_model_one,wbc_handling_cacop_model_two;
        
      
        wire wbc_can_respone_ls;
        wire wbc_respone_ls;
        wire wbc_no_stage_two_can_respone_ls ,wbc_stage_two_unstore_can_to_lookup_respone_ls;
              
        wire wbc_respone_load,wbc_respone_store;
        
        wire wbc_no_write_cache_req_finish;
        wire wbc_cache_req_finish;
        wire wbc_req_finish;
        
        wire wbc_send_data_ok;
    
    
    //write
        wire write_handling_store_req_cache;
        
     //总和  
    wire cache_respone_ls,cache_respone_store,load_req_finish,store_req_part_finish,store_req_finish;
   
    wire [`CacheTagWidth]         cache_rdata_way0_tag, cache_rdata_way1_tag;
    wire cache_rdata_way0_valid,cache_rdata_way1_valid;
   
 
     /***************************************inner variable define(错误状态)**************************************/

   wire error1,error2,error3,error4;
   wire stage_one_en ;
   wire stage_two_en;
   wire stage_three_en;
   reg[`CacheDisposeInstNumWidth] inst_num;
   always @(posedge clk)begin
        if(resetn == 1'b0)begin
            inst_num<=`CacheDisposeInstNumLen'b0;
        end else if(addr_ok_o&~data_ok_o)begin
            inst_num <= inst_num+`CacheDisposeInstNumLen'b1;
        end else if(addr_ok_o&data_ok_o)begin
            inst_num <= inst_num;
        end else if(~addr_ok_o&data_ok_o)begin
            inst_num <= inst_num-`CacheDisposeInstNumLen'b1;
        end else begin
            inst_num <= inst_num;
        end
   end
   

 
             
    assign error1 = rcs_eq_ridle & inst_num!=0 ;


    assign error2 =  inst_num>2; 
//
    assign error3 = (cache_rdata_way0_tag == cache_rdata_way1_tag)&cache_rdata_way0_valid&cache_rdata_way1_valid;
    assign error4 = (cache_repalce_way0_tag==cache_repalce_way1_tag)& cache_repalce_way1_valid& cache_repalce_way0_valid;
   
 assign error_o = error1|error2|error3|error4;  
 /***************************************inner variable define(逻辑实现)**************************************/   
 
    assign cache_re     = ~cacop_req_i&valid_i&~op_i;
    assign cache_we     = ~cacop_req_i&valid_i&op_i;
    assign cache_coe    = cacop_req_i;
    assign no_cache_req = ~cacop_req_i& ~valid_i; 
    

    assign  no_stage_two_req    = ~(rcs_eq_lookup&cache_table_read_queue_we)&~(~rcs_eq_lookup&cache_table_read_queue_valid);
    assign having_stage_two_req = (rcs_eq_lookup&cache_table_read_queue_we)|(~rcs_eq_lookup&cache_table_read_queue_valid);
    assign handling_access_addr = handling_valid? (rcs_eq_lookup ? {tag_i,now_req_cache_index_offest} :{now_req_cache_tag,now_req_cache_index_offest}):32'd0;
    
    assign  handling_way        = wbe_handling_cacop_model_one|wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one ? handling_access_addr[0] : now_req_hit_repalce_way;
 
 
    assign having_store_stage_two_req    = having_stage_two_req&store_buffer_queue_valid;
    assign having_unstore_stage_two_req  = having_stage_two_req&~store_buffer_queue_valid;
    assign stage_two_can_to_three        = having_stage_two_req&cpu_mmu_finish_i;
    assign stage_two_cant_to_three       = having_stage_two_req&~cpu_mmu_finish_i;
    
    
    assign cache_rdata_way0_tag   = handling_cache_table_way0_rdata[`Way0TagLocation];
    assign cache_rdata_way1_tag   = handling_cache_table_way1_rdata[`Way0TagLocation];
    assign cache_rdata_way0_valid = handling_cache_table_way0_rdata[`Way0VLocation];
    assign cache_rdata_way1_valid = handling_cache_table_way1_rdata[`Way0VLocation];
    
    
    
    assign way0_cache_hit =   cpu_req_tag == cache_rdata_way0_tag && cache_rdata_way0_valid;
    assign way1_cache_hit =   cpu_req_tag == cache_rdata_way1_tag && cache_rdata_way1_valid;
    assign cache_hit      = way0_cache_hit|way1_cache_hit;
    
   
    
  
    
   
  
  
 
  /***************************************inner variable define(状态执行的指令)**************************************/   
   assign rcs_eq_ridle      = r_cs==RIDLE      ;
   assign rcs_eq_read       = r_cs==READ       ; 
   assign rcs_eq_lookup     = r_cs==LOOKUP     ;
   assign rcs_eq_miss       = r_cs==MISS       ;
   assign rcs_eq_write      = r_cs==WRITE      ;
   assign rcs_eq_writeback  = r_cs==WRITEBACK  ;
   assign rcs_eq_replace    = r_cs==REPLACE    ;
   assign rcs_eq_refill     = r_cs==REFILL     ;
   assign rcs_eq_writeblock = r_cs==WRITEBLOCK ;
   
   //ridle
    assign ridle_handling_store_cache   = rcs_eq_ridle & store_buffer_to_cache_or_ram_we_i & ~handling_uncache;
    assign ridle_handling_store_uncache = rcs_eq_ridle & store_buffer_to_cache_or_ram_we_i & handling_uncache ;
    
    
    assign ridle_can_respone_ls              = rcs_eq_ridle & ~store_buffer_to_cache_or_ram_we_i ;
    assign ridle_respone_load                = ridle_can_respone_ls & cache_re;
    assign ridle_respone_store               = ridle_can_respone_ls & cache_we;
    assign ridle_can_respone_cacop_mode_zero = ridle_can_respone_ls & cache_coe&(cacop_op_mode_i==2'd0);
    assign ridle_can_respone_cacop_mode_one  = ridle_can_respone_ls & cache_coe&(cacop_op_mode_i==2'd1);
    assign ridle_can_respone_cacop_mode_two  = ridle_can_respone_ls & cache_coe&(cacop_op_mode_i==2'd2);
    assign ridle_respone_ls                  = ridle_respone_load|ridle_respone_store;
    
    //next状态
    assign cs_eq_ridle_ns = ridle_can_respone_cacop_mode_two|ridle_respone_load|ridle_respone_store ? READ:
                            ridle_handling_store_cache ? WRITE:
                            ridle_can_respone_cacop_mode_one|ridle_handling_store_uncache? MISS :
                            ridle_can_respone_cacop_mode_zero ? WRITEBLOCK :RIDLE;
   
   
   //read阶段

     assign read_handling_load             = rcs_eq_read & ~handling_cacop_en & ~handling_store_access;
     assign read_handling_store            = rcs_eq_read & ~handling_cacop_en & handling_store_access;
     assign read_handling_cacop_model_two  = rcs_eq_read & handling_cacop_en ;
     
    
     assign read_can_respone_ls           =  0;
     assign read_respone_load             =  read_can_respone_ls & cache_re;
     assign read_respone_store            =  read_can_respone_ls & cache_we;
     assign read_respone_ls               =  read_respone_load|read_respone_store;
     
     assign cs_eq_read_ns   =   (read_handling_load|read_handling_store |read_handling_cacop_model_two) ?  (cpu_mmu_finish_i?LOOKUP:READ):RIDLE;
   
   //lookup阶段
     //cache阶段正在执行的类型
     assign lookup_handling_cacop_model_two_cancle = rcs_eq_lookup & handling_cacop_en& handling_access_cancle_i;
     assign lookup_handling_load_req_cancle        = rcs_eq_lookup &~handling_cacop_en&~handling_store_access& handling_access_cancle_i;
     assign lookup_handling_store_req_cancle       = rcs_eq_lookup &~handling_cacop_en& handling_store_access& handling_access_cancle_i;
    
     assign lookup_handling_cacop_model_two_no_hit = rcs_eq_lookup & handling_cacop_en& ~handling_access_cancle_i&~cache_hit;
     assign lookup_handling_cacop_model_two_hit    = rcs_eq_lookup & handling_cacop_en& ~handling_access_cancle_i& cache_hit;   
     
     assign lookup_handling_load_req_uncache       = rcs_eq_lookup &~handling_cacop_en& ~handling_store_access& ~handling_access_cancle_i& uncache_i;
     assign lookup_handling_load_req_cache_hit     = rcs_eq_lookup &~handling_cacop_en& ~handling_store_access& ~handling_access_cancle_i&~uncache_i & cache_hit;
     assign lookup_handling_load_req_cache_unhit   = rcs_eq_lookup &~handling_cacop_en& ~handling_store_access& ~handling_access_cancle_i&~uncache_i & ~cache_hit;     
                                    
     assign lookup_handling_store_req_uncache      = rcs_eq_lookup &~handling_cacop_en& handling_store_access& ~handling_access_cancle_i& uncache_i;
     assign lookup_handling_store_req_cache_hit    = rcs_eq_lookup &~handling_cacop_en& handling_store_access& ~handling_access_cancle_i&~uncache_i & cache_hit;
     assign lookup_handling_store_req_cache_unhit  = rcs_eq_lookup &~handling_cacop_en& handling_store_access& ~handling_access_cancle_i&~uncache_i & ~cache_hit; 
     
     //完成
     assign lookup_no_write_cache_req_finish = lookup_handling_cacop_model_two_cancle|lookup_handling_load_req_cancle|lookup_handling_store_req_cancle
                                              |lookup_handling_cacop_model_two_no_hit|lookup_handling_load_req_cache_hit;
    
     assign lookup_req_finish                = lookup_handling_cacop_model_two_cancle|lookup_handling_load_req_cancle|lookup_handling_store_req_cancle|lookup_handling_cacop_model_two_no_hit|lookup_handling_load_req_cache_hit; 
     
     
     assign lookup_no_stage_two_can_respone_ls                = 0;
     assign lookup_stage_two_unstore_can_to_lookup_respone_ls = 0;
     
     assign lookup_can_respone_ls = lookup_no_stage_two_can_respone_ls|lookup_stage_two_unstore_can_to_lookup_respone_ls;
     assign lookup_respone_load   =  lookup_can_respone_ls&cache_re;
     assign lookup_respone_store  = lookup_can_respone_ls&cache_we;
     assign lookup_respone_ls     = lookup_respone_load|lookup_respone_store;
     
     assign cs_eq_lookup_ns =
                            (  (lookup_no_stage_two_can_respone_ls&(cache_re|cache_we))
                              |(lookup_req_finish&stage_two_cant_to_three)
                            ) ? READ :
                            (lookup_req_finish & stage_two_can_to_three)? LOOKUP :
                            (
                             lookup_handling_cacop_model_two_hit|lookup_handling_load_req_cache_unhit|lookup_handling_store_req_cache_unhit
                            ) ? MISS:
                          
                            lookup_handling_load_req_uncache ? REPLACE:RIDLE;
     //write
        assign write_handling_store_req_cache = rcs_eq_write;
        assign cs_eq_write_ns = RIDLE;
   
   
   
   //miss阶段正在执行
   
        assign miss_handling_load_req_cache_unhit  = rcs_eq_miss &~handling_cacop_en& ~handling_store_access;    
        assign miss_handling_cacop_model_one       = rcs_eq_miss & handling_cacop_en &(handling_cacop_op_mode ==2'd1) ;                             
        assign miss_handling_cacop_model_two_hit   = rcs_eq_miss & handling_cacop_en &(handling_cacop_op_mode ==2'd2) ;                                 
        assign miss_handling_store_req_uncache     = rcs_eq_miss &~handling_cacop_en& handling_store_access & handling_uncache;  
        assign miss_handling_store_req_cache_unhit = rcs_eq_miss &~handling_cacop_en& handling_store_access & ~handling_uncache;  
        
     
        
        assign miss_send_data_ok = 1'b0;
        
        assign cs_eq_miss_ns =  
                                 miss_handling_cacop_model_two_hit|miss_handling_cacop_model_one
                                |miss_handling_load_req_cache_unhit
                                |miss_handling_store_req_uncache|miss_handling_store_req_cache_unhit ? (axi_wr_rdy_i? WRITEBACK:MISS):RIDLE;
    
    //Writeback
         assign wbe_handling_load_req_cache_unhit_dirty    = rcs_eq_writeback &~handling_cacop_en & ~handling_store_access & handling_req_cache_rdata_dirty;
         assign wbe_handling_load_req_cache_unhit_undirty  = rcs_eq_writeback &~handling_cacop_en & ~handling_store_access & ~handling_req_cache_rdata_dirty;
         
         assign wbe_handling_cacop_model_one           = rcs_eq_writeback & handling_cacop_en & (handling_cacop_op_mode ==2'd1);
         assign wbe_handling_cacop_model_one_dirty     = wbe_handling_cacop_model_one &  handling_req_cache_rdata_dirty; 
         assign wbe_handling_cacop_model_one_undirty   = wbe_handling_cacop_model_one &  ~handling_req_cache_rdata_dirty;  
                                  
         assign wbe_handling_cacop_model_two_hit_dirty     = rcs_eq_writeback & handling_cacop_en & (handling_cacop_op_mode ==2'd2) &  handling_req_cache_rdata_dirty;
         assign wbe_handling_cacop_model_two_hit_undirty   = rcs_eq_writeback & handling_cacop_en & (handling_cacop_op_mode ==2'd2) &  ~handling_req_cache_rdata_dirty;                                  
         assign wbe_handling_store_req_uncache             = rcs_eq_writeback &~handling_cacop_en &  handling_store_access & handling_uncache;
         assign wbe_handling_store_req_cache_unhit_dirty   = rcs_eq_writeback &~handling_cacop_en &  handling_store_access & ~handling_uncache & handling_req_cache_rdata_dirty;
         assign wbe_handling_store_req_cache_unhit_undirty = rcs_eq_writeback &~handling_cacop_en &  handling_store_access & ~handling_uncache & ~handling_req_cache_rdata_dirty; 
         
         assign wbe_no_write_cache_req_finish = wbe_handling_store_req_uncache;
         assign wbe_req_finish = wbe_handling_store_req_uncache;
         
          assign wbe_no_stage_two_can_respone_ls                = wbe_no_write_cache_req_finish & no_stage_two_req;
          assign wbe_stage_two_unstore_can_to_lookup_respone_ls = wbe_no_write_cache_req_finish & having_unstore_stage_two_req& cpu_mmu_finish_i;
         
         
         assign wbe_can_respone_ls = wbe_no_stage_two_can_respone_ls| wbe_stage_two_unstore_can_to_lookup_respone_ls;
         assign wbe_respone_load   = wbe_can_respone_ls &cache_re; 
         assign wbe_respone_store  = wbe_can_respone_ls &cache_we; 
         assign wbe_respone_ls     = wbe_respone_load|wbe_respone_store;
         
         assign cs_eq_writeback_ns = 
                                (
                                    wbe_no_stage_two_can_respone_ls&(cache_re|cache_we)
                                    |wbe_req_finish&stage_two_cant_to_three
                                 )? READ :
                                 wbe_req_finish&stage_two_can_to_three?LOOKUP:
                                 (
                                    wbe_handling_load_req_cache_unhit_dirty|wbe_handling_load_req_cache_unhit_undirty
                                    |wbe_handling_cacop_model_two_hit_dirty|wbe_handling_cacop_model_two_hit_undirty
                                    |wbe_handling_store_req_cache_unhit_dirty|wbe_handling_store_req_cache_unhit_undirty
                                  )?REPLACE :
                                 (wbe_handling_cacop_model_one_dirty|wbe_handling_cacop_model_one_undirty)?WRITEBLOCK  :RIDLE;
                                 
      //replace
        assign replace_handling_cacop_model_two       = rcs_eq_replace &  handling_cacop_en;
        assign replace_handling_load_req_uncache      = rcs_eq_replace & ~handling_cacop_en& ~handling_store_access& handling_uncache;
        assign replace_handling_load_req_cache_unhit  = rcs_eq_replace & ~handling_cacop_en& ~handling_store_access& ~handling_uncache;
        assign replace_handling_store_req_cache_unhit = rcs_eq_replace & ~handling_cacop_en&  handling_store_access& ~handling_uncache;
        
        assign cs_eq_replace_ns = (replace_handling_load_req_uncache|replace_handling_load_req_cache_unhit|replace_handling_store_req_cache_unhit) ? 
                                                                                                                                                    (
                                                                                                                                                        axi_rd_rdy_i ? REFILL:REPLACE
                                                                                                                                                     ) :RIDLE;
      
      //refill
        assign refill_handling_cacop_model_two        = rcs_eq_refill &  handling_cacop_en;
        assign refill_handling_load_req_uncache       = rcs_eq_refill & ~handling_cacop_en& ~handling_store_access& handling_uncache;
        assign refill_handling_load_req_cache_unhit   = rcs_eq_refill & ~handling_cacop_en& ~handling_store_access& ~handling_uncache; 
        assign refill_handling_store_req_cache_unhit  = rcs_eq_refill & ~handling_cacop_en&  handling_store_access& ~handling_uncache;  
       
        assign cs_eq_refill_ns = (refill_handling_load_req_uncache|refill_handling_load_req_cache_unhit|refill_handling_store_req_cache_unhit)?
                                                                                                                                             ( 
                                                                                                                                                (axi_ret_valid_i& axi_ret_last_i) ? WRITEBLOCK : REFILL
                                                                                                                                              ) :RIDLE;
      
      //writeblock
        assign wbc_handling_load_req_uncache      = rcs_eq_writeblock & ~handling_cacop_en& ~handling_store_access& handling_uncache;
        assign wbc_handling_load_req_cache_unhit  = rcs_eq_writeblock & ~handling_cacop_en& ~handling_store_access& ~handling_uncache;
        
        assign wbc_handling_store_req_cache_unhit = rcs_eq_writeblock & ~handling_cacop_en& handling_store_access& ~handling_uncache;
        
        assign wbc_handling_cacop_model_zero              = rcs_eq_writeblock &  handling_cacop_en & handling_cacop_op_mode==2'b00;
        assign wbc_handling_cacop_model_one               = rcs_eq_writeblock &  handling_cacop_en & handling_cacop_op_mode==2'b01;
        assign wbc_handling_cacop_model_two               = rcs_eq_writeblock &  handling_cacop_en & handling_cacop_op_mode==2'b10;
        
        assign wbc_no_write_cache_req_finish     = wbc_handling_load_req_uncache;
        assign wbc_cache_req_finish              = wbc_handling_load_req_uncache|wbc_handling_load_req_cache_unhit|wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one|wbc_handling_cacop_model_two;
        assign wbc_send_data_ok                  = wbc_handling_load_req_uncache|wbc_handling_load_req_cache_unhit|wbc_handling_store_req_cache_unhit;
        assign wbc_req_finish                    = wbc_handling_load_req_uncache|wbc_handling_load_req_cache_unhit|wbc_handling_store_req_cache_unhit|wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one|wbc_handling_cacop_model_two;
       
        // 响应
         assign wbc_no_stage_two_can_respone_ls                = wbc_no_write_cache_req_finish & no_stage_two_req;
         assign wbc_stage_two_unstore_can_to_lookup_respone_ls = wbc_no_write_cache_req_finish & having_unstore_stage_two_req&cpu_mmu_finish_i ;   
         assign wbc_can_respone_ls = wbc_no_stage_two_can_respone_ls|wbc_stage_two_unstore_can_to_lookup_respone_ls;   
         assign wbc_respone_load   = wbc_can_respone_ls &cache_re;                                                   
         assign wbc_respone_store  = wbc_can_respone_ls &cache_we;                                                   
         assign wbc_respone_ls     = wbc_respone_load|wbc_respone_store;                                             
        
        //下一个状态
        assign cs_eq_writeblock_ns    = 
                                          (
                                             wbc_cache_req_finish&stage_two_cant_to_three
                                              //
                                            |(wbc_no_stage_two_can_respone_ls &(cache_re|cache_we))
                                          )? READ :
                                           wbc_cache_req_finish&stage_two_can_to_three?LOOKUP:RIDLE;
                                                  
                                                  
    assign cache_respone_ls =  ridle_respone_ls|read_respone_ls|lookup_respone_ls |wbe_respone_ls|wbc_respone_ls;
    assign cache_respone_store = ridle_respone_store|read_respone_store|lookup_respone_store |wbe_respone_store|wbc_respone_store;
    
    assign load_req_finish  = lookup_handling_cacop_model_two_cancle|lookup_handling_load_req_cancle|lookup_handling_store_req_cancle
                                    |lookup_handling_load_req_cache_hit|wbc_handling_load_req_cache_unhit
                                    |wbc_handling_load_req_uncache;
    
    
   
    assign store_req_part_finish = lookup_handling_store_req_cancle
                                   |lookup_handling_store_req_uncache|lookup_handling_store_req_cache_hit
                                   | wbc_handling_store_req_cache_unhit ;
                                   
    assign store_req_finish  = lookup_handling_store_req_cancle
                               |wbe_handling_store_req_uncache
                               |write_handling_store_req_cache;
    
                                             
    assign r_ns = cs_eq_ridle_ns |cs_eq_read_ns |cs_eq_lookup_ns |cs_eq_miss_ns |cs_eq_write_ns| cs_eq_writeback_ns |cs_eq_replace_ns |cs_eq_refill_ns |cs_eq_writeblock_ns ;     
    
     //主状态转移
    always @(posedge clk)begin
       if(~resetn)begin
           r_cs <= RIDLE;
       end else begin
           r_cs <= r_ns;
       end
    end                                             
                
                
                                             
     
 /***************************************缓存机制**************************************/ 
 
  reg rand_count;
    always @(posedge clk)begin
       if(resetn == 1'b0)begin
          rand_count <= 1'b0;
       end else begin
          rand_count <= rand_count +1;
       end
    end
 
   
 

 


          Queue #(15)cache_cpu_request_part1_Queue
        (
            .clk            (clk   )                  ,
            .rst_n          (resetn)                  ,
                          
            .we_i           (cpu_request_part1_queue_we)  ,
                           
            .wdata_i        ( cpu_request_part1_queue_wdata)       ,
                         
            .used_i         ( cpu_request_part1_queue_ce)          ,
                         
            .full_o         ()                        ,
                           
            .rdata_o        ({handling_cacop_en,handling_cacop_op_mode,handling_store_access,now_req_cache_index_offest}),//1+2+1+12
            .rdata2_o     ({waiting_cacop_en,waiting_cacop_op_mode,waiting_store_access,waiting_req_index_offest}),
            .rdata_valid_o  (handling_valid)
           
        );
        
        
        
        
        Queue #(21)cache_cpu_request_part2_Queue                                                    
        (                                                                         
            .clk            (clk   )                  ,                           
            .rst_n          (resetn)                  ,                           
                                                                                  
            .we_i           (cpu_request_part2_queue_we)  ,                               
                                                                                      
            .wdata_i        (cpu_request_part2_queue_wdata)       ,                               
                                                                                      
            .used_i         (cpu_request_part2_queue_ce)          ,                               
                                                                                      
            .full_o         ()                        ,                               
                                                                                      
            .rdata_o        ({now_req_hit_repalce_way,handling_uncache,now_req_cache_tag}),//1+1+20             
            .rdata_valid_o  ()                                                        
                                                                                      
        );
       
        
        Queue #(35)store_buffer_queue                                                      
        (                                                                         
            .clk            (clk   )                  ,                           
            .rst_n          (resetn)                  ,                           
                                                                                  
            .we_i           (store_buffer_queue_we )  ,                               
                                                                                      
            .wdata_i        (store_buffer_queue_wdata)       ,                               
                                                                                      
            .used_i         (store_buffer_queue_ce)          ,                               
                                                                                      
            .full_o         ()                        ,                               
                                                                                      
            .rdata_o        ({handling_store_wstrb,handling_store_wdata}),// 4+32            
            .rdata_valid_o  (store_buffer_queue_valid)                                                        
                                                                                      
        );
        
         //写缓存计数器
         reg cache_table_rdata_cache_en;
         wire cache_table_rdata_cache_en_start;
          always@(posedge clk)begin
            if(resetn == 1'b0)begin
                cache_table_rdata_cache_en <=1'b0;
            end else if(cache_table_rdata_cache_en_start)begin
                cache_table_rdata_cache_en <=1'b1;
            end else if (cache_table_rdata_cache_en)begin
                cache_table_rdata_cache_en <=1'b0;
            end else begin
                cache_table_rdata_cache_en <=cache_table_rdata_cache_en;
            end 
          end
        
   
   
       
        
        
        CacheRdataQueue #(149)cache_read_queue                                                      
        (                                                                         
            .clk            (clk   )                  ,                           
            .rst_n          (resetn)                  ,                           
                                                                                  
            .we_i           (cache_table_read_queue_we )         ,                               
                                                                                      
            .wdata_i        (cache_table_read_queue_wdata)       ,  
            
            //更新
            .update_en_i    (cache_table_update_en),//更新使能      
            //.update_en_i    (0),//更新使能      
            .update_way_i   (cache_table_update_way),//更新的way   
            .updata_data_i  (cache_table_update_data ),                                
                                                                                      
            .used_i         (cache_table_read_queue_ce)          ,                               
                                                                                      
            .full_o         ()                        ,                               
                                                                                      
            .rdata_o        (cache_table_read_queue_rdata),        
            .rdata_valid_o  (cache_table_read_queue_valid)                                              
                                                                                      
        );


    always @(posedge clk)begin
       
       if(resetn == 1'b0|axi_write_count_ce)begin
           axi_write_count <= 2'd0;
       end else if(axi_write_count_we)begin
           axi_write_count <= axi_write_count+1;
       end else begin
           axi_write_count <= axi_write_count;
       end
    
       
       if(resetn == 1'b0)begin
           exrt_axi_rdata_buffer0 <= 32'd0;
       end else if (2'd0 == axi_write_count[1:0] )begin
           exrt_axi_rdata_buffer0 <= axi_ret_data_i;
       end else begin
           exrt_axi_rdata_buffer0 <= exrt_axi_rdata_buffer0;
       end
       
        if(resetn == 1'b0)begin
           exrt_axi_rdata_buffer1 <= 32'd0;
       end else if (2'd1 == axi_write_count[1:0] )begin
           exrt_axi_rdata_buffer1 <= axi_ret_data_i;
       end else begin
           exrt_axi_rdata_buffer1 <= exrt_axi_rdata_buffer1;
       end
       
       if(resetn == 1'b0)begin
           exrt_axi_rdata_buffer2 <= 32'd0;
       end else if (2'd2 == axi_write_count[1:0])begin
           exrt_axi_rdata_buffer2 <= axi_ret_data_i;
       end else begin
           exrt_axi_rdata_buffer2 <= exrt_axi_rdata_buffer2;
       end
       
       
        if(resetn == 1'b0)begin
             exrt_axi_rdata_buffer3  = 32'd0;
        end else if (2'd3 == axi_write_count[1:0])begin
             exrt_axi_rdata_buffer3  = axi_ret_data_i;
        end else begin
             exrt_axi_rdata_buffer3  =  exrt_axi_rdata_buffer3 ;
        end
       
    end




    
 //cache查找表  
   cache_table cache_table_item(
       .clk       (clk)    ,
       .req_i     (cache_table_en)    ,
       .r_index_i (cache_table_rindex)    ,
       .r_data_o  (cache_table_rdata )    ,             
                  
                  
       .way_i     (cache_table_wway)      ,
       .w_index_i (cache_table_windex)    ,
       .w_type_i  (cache_table_wtype)     ,
       .offset_i  (cache_table_woffset)   ,                              
       .wstrb_i   (cache_table_wstr)      ,
       .w_data_i  (cache_table_wdatabus)   

    ); 
    
/**************************************************信号******************************************************************/
  assign cache_free_o =   rcs_eq_ridle &(~store_buffer_queue_valid|clear_store_buffer_en_i);
  assign addr_ok_o = cache_respone_ls;
  assign data_ok_o = load_req_finish|store_req_part_finish;
  assign handling_req_finish =load_req_finish|store_req_finish;
  
  
  //缓存信号
     assign  cpu_request_part1_queue_ce    = handling_req_finish|wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one| wbc_handling_cacop_model_two  ;
     
     assign  cpu_request_index_offest      = cacop_req_i ? { cacop_op_addr_index_i,cacop_op_addr_offset_i}:{index_i,offset_i };
     assign  cpu_request_part1_queue_wdata = {cacop_req_i,cacop_op_mode_i,op_i,cpu_request_index_offest};//1+2+1+12
     
     
     assign hit_or_replace_way         = rcs_eq_lookup&cache_hit ? way1_cache_hit : rand_count;
                                 
                                  
     
     
     assign cpu_req_tag = handling_cacop_en ? cacop_op_addr_tag_i :tag_i;  
     assign cpu_request_part2_queue_ce = handling_req_finish;     
     assign cpu_request_part2_queue_we = rcs_eq_lookup;
     assign cpu_request_part2_queue_wdata = {hit_or_replace_way,uncache_i,cpu_req_tag};
     
    
     assign store_buffer_queue_ce = store_req_finish;
     assign store_buffer_queue_we = cache_respone_store;
     assign store_buffer_queue_wdata = {store_wstrb_i,store_wdata_i};
     assign {handling_cache_table_way1_rdata,handling_cache_table_way0_rdata} = cache_table_read_queue_rdata ;
     
     //cache查找表读除缓存

       assign cache_table_update_en   =  (wbc_handling_load_req_cache_unhit|wbc_handling_store_req_cache_unhit|wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one|wbc_handling_cacop_model_two)&
                                          (waiting_req_index_offest[11:4]==now_req_cache_index_offest[11:4]) & having_stage_two_req ;     
       
       assign cache_table_update_way  = handling_way ;
       assign cache_table_update_data = cache_table_wdatabus;
     
     
     
     assign cache_table_read_queue_we =cache_table_rdata_cache_en ;
     assign cache_table_read_queue_wdata = cache_table_rdata;
     assign cache_table_read_queue_ce = rcs_eq_lookup;
     
     
     assign  axi_write_count_ce    =   rcs_eq_refill&axi_ret_valid_i &axi_ret_last_i;  
  
  
               
    assign cache_table_en     = cache_respone_ls 
                             
                               |((miss_handling_load_req_cache_unhit|miss_handling_cacop_model_one|miss_handling_cacop_model_two_hit |miss_handling_store_req_cache_unhit)&axi_wr_rdy_i)
                               
                               |(wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one|wbc_handling_cacop_model_two|wbc_handling_load_req_cache_unhit |wbc_handling_store_req_cache_unhit)
                              
                               |write_handling_store_req_cache;
                               
                                
    assign cache_table_rindex = (
                                    miss_handling_load_req_cache_unhit
                                    |miss_handling_cacop_model_one|miss_handling_cacop_model_two_hit 
                                    |miss_handling_store_req_cache_unhit
                                 ) ? handling_access_addr[11:4]:index_i ;
                                 
                                 
    assign cache_table_wway    = handling_way;
    assign cache_table_windex  = handling_access_addr[11:4];
    assign cache_table_wtype   = wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one|wbc_handling_cacop_model_two|wbc_handling_load_req_cache_unhit |wbc_handling_store_req_cache_unhit?2'b10:(write_handling_store_req_cache?2'b01:2'b00);
    assign cache_table_woffset = handling_access_addr[3:0];
    assign cache_table_wstr    = handling_store_wstrb;
    
                                
    assign cache_table_wv       =  wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one|wbc_handling_cacop_model_two ? 1'b0:1'b1;
    assign cache_table_wtag     = handling_access_addr[31:12];
    assign cache_table_wdata0   =  write_handling_store_req_cache? handling_store_wdata:exrt_axi_rdata_buffer0;
    assign cache_table_wdata    = {exrt_axi_rdata_buffer3,exrt_axi_rdata_buffer2,exrt_axi_rdata_buffer1,cache_table_wdata0};
    assign cache_table_wd       =  write_handling_store_req_cache;
    assign cache_table_wdatabus = (wbc_handling_cacop_model_zero|wbc_handling_cacop_model_one|wbc_handling_cacop_model_two)?150'd0:{{cache_table_wv,cache_table_wtag},cache_table_wdata,cache_table_wd};
  
  
  //缓存
  assign axi_write_count_we               = rcs_eq_refill&axi_ret_valid_i;
  assign cache_table_rdata_cache_en_start = cache_respone_ls|ridle_can_respone_cacop_mode_two;
  assign cpu_request_part1_queue_we       = cache_respone_ls|ridle_can_respone_cacop_mode_zero|ridle_can_respone_cacop_mode_one|ridle_can_respone_cacop_mode_two;
  
  
 
  
  
  
  //writeblack
  
  assign {handling_cache_table_way1_write_black_data,handling_cache_table_way0_write_black_data} = cache_table_rdata;
  assign cache_repalce_way0_valid = handling_cache_table_way0_write_black_data[`Way0VLocation];
  assign cache_repalce_way0_dirty = handling_cache_table_way0_write_black_data[`Way0DLocation];
  assign cache_repalce_way0_tag  = handling_cache_table_way0_write_black_data[`Way0TagLocation];
   
  assign cache_repalce_way1_valid = handling_cache_table_way1_write_black_data[`Way0VLocation];
  assign cache_repalce_way1_dirty = handling_cache_table_way1_write_black_data[`Way0DLocation];
  assign cache_repalce_way1_tag   = handling_cache_table_way1_write_black_data[`Way0TagLocation];
  
  assign cache_rdata_way0_dirty = cache_repalce_way0_valid& cache_repalce_way0_dirty ;
  assign cache_rdata_way1_dirty = cache_repalce_way1_valid& cache_repalce_way1_dirty;
  
  assign cache_repalce_way_tag            = handling_way? cache_repalce_way1_tag :cache_repalce_way0_tag;
  assign handling_req_cache_rdata_dirty   = handling_way? cache_rdata_way1_dirty :cache_rdata_way0_dirty;
  
  
  
                                        
  //axi信号
       assign axi_rd_req_o  = replace_handling_cacop_model_two|replace_handling_load_req_uncache|replace_handling_load_req_cache_unhit|replace_handling_store_req_cache_unhit;
       assign axi_rd_type_o = replace_handling_load_req_uncache? 3'b010:3'b100;
       assign axi_rd_addr_o = replace_handling_load_req_uncache? handling_access_addr :{handling_access_addr[31:4],4'd0};
       
                
                   
       assign axi_wr_req_o    = wbe_handling_load_req_cache_unhit_dirty |wbe_handling_cacop_model_two_hit_dirty|wbe_handling_store_req_cache_unhit_dirty|wbe_handling_store_req_uncache;
       assign axi_wr_type_o   = wbe_handling_store_req_uncache ?  3'b010:3'b100;
       assign axi_wr_addr_o   = wbe_handling_store_req_uncache ? handling_access_addr :{cache_repalce_way_tag ,handling_access_addr[11:4],4'd0};
       assign axi_wr_wstrb_o  = wbe_handling_store_req_uncache ? handling_store_wstrb :4'b1111;       
       
       assign axi_wr_data_o   = wbe_handling_store_req_uncache ?{96'd0,handling_store_wdata}:(handling_way?handling_cache_table_way1_write_black_data:handling_cache_table_way0_write_black_data);
       
       

         
       assign cs_o                     = r_cs                           ;
       assign uncache_en_buffer_o      = handling_uncache               ;
       assign search_addr_buffer_o     = handling_access_addr           ;
       assign exrt_axi_rdata_buffer0_o = exrt_axi_rdata_buffer0         ;
       assign exrt_axi_rdata_buffer1_o = exrt_axi_rdata_buffer1         ;
       assign exrt_axi_rdata_buffer2_o = exrt_axi_rdata_buffer2         ;
       assign exrt_axi_rdata_buffer3_o = exrt_axi_rdata_buffer3         ;
       assign way0_cache_hit_o         = way0_cache_hit                 ;
       assign way1_cache_hit_o         = way1_cache_hit                 ;
       assign search_buffer_o          = cache_table_read_queue_rdata   ;
       assign wait_dispose_inst_num_o  = inst_num                       ;
 
 
 wire [`DiffWriteBlockInstNumWidth]diff_write_block;
 assign diff_write_block={
 
 wbc_handling_load_req_uncache     ,
 wbc_handling_load_req_cache_unhit ,
                                   
 wbc_handling_store_req_cache_unhit,
                                   
 wbc_handling_cacop_model_zero     ,
 wbc_handling_cacop_model_one      ,
 wbc_handling_cacop_model_two      
 
 
 };
 
 
 
 
 
 
 wire [`DiffRefillInstNumWidth]diff_refill;
 assign diff_refill = {
 refill_handling_cacop_model_two      ,
 refill_handling_load_req_uncache     ,
 refill_handling_load_req_cache_unhit ,
 refill_handling_store_req_cache_unhit
 };
 
 
 wire [`DiffReplaceInstNumWidth]diff_replace;
 assign diff_replace = {
            replace_handling_cacop_model_two      ,
            replace_handling_load_req_uncache     ,
            replace_handling_load_req_cache_unhit ,
            replace_handling_store_req_cache_unhit
            
            };
            
 wire [`DiffWriteBackInstNumWidth]diff_write_back;
 assign diff_write_back={
 
 wbe_handling_load_req_cache_unhit_dirty     ,
 wbe_handling_load_req_cache_unhit_undirty   ,
 wbe_handling_cacop_model_two_hit_dirty      ,
 wbe_handling_cacop_model_two_hit_undirty    ,
 wbe_handling_store_req_uncache              ,
 wbe_handling_store_req_cache_unhit_dirty    ,
 wbe_handling_store_req_cache_unhit_undirty  
 };
  
 wire [`DiffMissInstNumWidth]diff_miss;
 assign diff_miss = {
          miss_handling_load_req_cache_unhit  ,
          miss_handling_cacop_model_two_hit   ,
          miss_handling_store_req_uncache     ,
          miss_handling_store_req_cache_unhit 
 
 } ;
  
wire [`DiffLookUpInstNumWidth]diff_look_up;
assign diff_look_up = {
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

};
wire [2:0]diff_read;
assign diff_read = {
    read_handling_load  ,read_handling_store ,read_handling_cacop_model_two

  };
 wire[31:0] diff_handling_addr =  {tag_i,handling_access_addr[11:0]};
assign diff_to_obus = { 



cache_repalce_way_tag,cache_repalce_way1_tag,cache_repalce_way0_tag,
exrt_axi_rdata_buffer3,exrt_axi_rdata_buffer2,exrt_axi_rdata_buffer1,exrt_axi_rdata_buffer0,
write_handling_store_req_cache,handling_way,handling_store_wdata,handling_access_addr,//1+1+32+32
axi_wr_addr_o,axi_wr_data_o,
r_ns,
r_cs,
diff_handling_addr,//当前访问地址32
diff_write_block ,//6
diff_refill      ,//4
diff_replace     ,//4
diff_write_back  ,//7
diff_miss        ,//4
diff_look_up     //11

};
  
     
endmodule
