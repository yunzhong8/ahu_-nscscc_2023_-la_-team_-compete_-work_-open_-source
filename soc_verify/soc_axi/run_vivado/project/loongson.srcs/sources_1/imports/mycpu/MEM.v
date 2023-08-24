/*
*作者：zzq
*创建时间：2023-03-31
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*输出：
*模块功能：
*
*/
/*************\

\*************/

`include "define.v"
module MEM(

    input  wire                            next_allowin_i,
    input  wire                            now_valid_i,
    
    //
    output wire                            now_allowin_o,
    output wire                            now_to_next_valid_o,
    input  wire                            excep_flush_i,
    
    input  wire                            data_sram_data_ok_i,
    input  wire [`LineMmToNextBusWidth]    pre_to_ibus       ,
    input  wire [`MemDataWidth]            mem_rdata_i    ,
    
    output wire [`LineMemtOIlaBusWidth]         to_ila_obus          ,
    output wire                          now_sent_mem_req_o,
    output wire [19:0]inst_cacop_op_addr_tag_o    ,  
    output wire [19:0]data_cacop_op_addr_tag_o    ,  
    output wire                            store_buffer_ce_o             , 
    output wire [`LineMemForwardBusWidth]  forward_obus,
    output wire                            to_pre_obus,
    output wire [`LineMemToNextBusWidth]   to_next_obus ,
    output wire [`MemToCacheBusWidth]      to_cache_obus       
);

/***************************************input variable define(输入变量定义)**************************************/
 wire [`PcWidth]pc_i;
 wire [`InstWidth]inst_i; 
  
  
    //存储器
         wire mem_req_i ;
         wire mem_we_i; 
         wire [`spMemRegsWdataSrcWidth] mem_regs_wdata_src_i;
         wire [`spMemMemDataSrcWidth] mem_mem_data_src_i;
         wire [`MemAddrWidth]         mem_rwaddr_i   ;
    //寄存器组
         wire[`RegsAddrWidth] regs_waddr_i;
         wire regs_we_i;
         wire [`RegsDataWidth] regs_wdata_i;
         wire  [`RegsDataWidth]regs_rdata1_i;
         wire  [`RegsDataWidth]regs_rdata2_i;
    //csr  
      wire is_kernel_inst_i,wb_regs_wdata_src_i;    
      wire csr_wdata_src_i;                         
      wire csr_raddr_src_i;                 
      wire csr_we_i;                        
      wire [`CsrAddrWidth]csr_waddr_i;      
      wire [`RegsDataWidth]csr_wdata_i;     
   //llbit                               
      wire llbit_we_i;                      
      wire llbit_wdata_i;      
    //tlb
     wire tlbidx_found_i;
     wire tlbidx_ne_i;
     wire [`TlbIndexWidth]tlbidx_index_i;
     wire [1:0]tlb_search_type_i;
     wire tlb_re_i         ; 
     wire tlb_se_i         ;
     wire tlb_ie_i         ; 
     wire tlb_we_i         ; 
     wire tlb_fe_i          ;
     wire [4:0]tlb_op_i     ;   
                     
    //例外                                          
         wire [`ExceptionTypeWidth]excep_type_i;    
         wire excep_en_i;   
      wire refetch_flush_i; 
     //cache
        wire cache_refill_valid_i;
        wire uncache_i;
        wire [`PpnWidth]p_tag_i;
        wire sotre_buffer_we_i;  
           
         wire idle_en_i,cacop_en_i;
        wire [4:0]cacop_code_i;
     //跳转冲刷
        wire branch_flush_i;
        wire [`PcWidth]jmp_addr_i;  
        
     //
     
      //mul   
      wire mul_en_i;
            wire mul_hl_i;                        
 wire [63:0]mul_part_data_s10_i;
 wire [63:0]mul_part_data_c10_i;
 wire [63:0]mul_part_data_s11_i;
 wire [63:0]mul_part_data_c11_i;   
        
        
                 

/***************************************output variable define(输出变量定义)**************************************/
    //存储器
         wire mem_req_o;
         wire [`MemWeWidth]mem_we_o;
         wire [`MemAddrWidth]mem_rwaddr_o;
        
        
    //寄存器组
         wire regs_we_o;
         wire[`RegsAddrWidth]regs_waddr_o;
         wire[`RegsDataWidth] regs_wdata_o;
     //csr
      wire csr_raddr_src_o;
      wire csr_we_o;
      wire [`CsrAddrWidth]csr_waddr_o;
      wire [`RegsDataWidth]csr_wdata_o;
    //llbit
      wire llbit_we_o;
      wire llbit_wdata_o;  
     //tlb
    
     wire tlb_re_o         ; 
     wire tlb_se_o         ;
     wire tlb_ie_o         ; 
     wire tlb_we_o         ; 
     wire tlb_fe_o         ;
     wire [4:0]tlb_op_o     ; 
    //例外信号                                                          
         wire [`ExceptionTypeWidth] excep_type_o; 
         wire excep_en_o;  
    //相关检测器要求暂停
      wire dr_stall_o;
     //cache
        wire sotre_buffer_we_o; 
        wire [19:0]p_tag_o;//物理标记地址  
        wire idle_en_o,cacop_en_o;
       
        wire refetch_flush_o;
        wire uncache_o;
        wire cache_refill_valid_o;
     //跳转冲刷
        wire branch_flush_o;
        
    
/***************************************parameter define(常量定义)**************************************/


wire diff_load_en_o ;
wire diff_store_en_o; 
wire[31:0] diff_ls_paddr_o;


wire [`MmToDiffBusWidth] mm_to_diff_ibus;
wire [`MemToDiffBusWidth] mem_to_diff_obus;
/***************************************inner variable define(内部变量定义)**************************************/
wire now_ctl_valid;
wire now_ctl_base_valid;
wire excep_en;

 reg [`MemDataWidth]mem_rdata;
 wire [1:0] mem_rwaddr_low2;
 
 //tlb例外
 wire tlb_memr_excep_i    ;
 wire tlb_pil_excep_i     ;
 wire tlb_pis_excep_i     ;
 
 wire tlb_pme_excep_i     ;
 wire tlb_ppi_excep_i ;
 
 wire [63:0]mul_result;
 //握手信号
 wire now_ready_go;
 
/****************************************input decode(输入解码)***************************************/
 assign   {
           mul_hl_i,mul_en_i,mul_part_data_s10_i,mul_part_data_c10_i,mul_part_data_s11_i,mul_part_data_c11_i,
           mm_to_diff_ibus,
           idle_en_i,cacop_en_i,cacop_code_i,
           cache_refill_valid_i,uncache_i,p_tag_i, 
           branch_flush_i,jmp_addr_i,
           refetch_flush_i,sotre_buffer_we_i,
           tlb_fe_i,tlb_se_i,tlb_re_i,tlb_we_i,tlb_ie_i,
           tlb_op_i,tlbidx_found_i,tlbidx_ne_i,tlbidx_index_i,
           is_kernel_inst_i,csr_wdata_src_i,regs_rdata1_i,regs_rdata2_i,
           excep_en_i,excep_type_i,
           llbit_we_i,llbit_wdata_i,                                  
           csr_raddr_src_i,csr_we_i,csr_waddr_i,csr_wdata_i,//csr写使能  
           mem_regs_wdata_src_i,mem_mem_data_src_i,mem_req_i,mem_we_i,mem_rwaddr_i,
           wb_regs_wdata_src_i,regs_we_i,regs_waddr_i,regs_wdata_i,
           pc_i,inst_i} = pre_to_ibus;
/****************************************output code(输出解码)***************************************/
assign to_next_obus={
                      
                      mem_to_diff_obus,
                      idle_en_o,cacop_en_o,
                      branch_flush_o,jmp_addr_i,
                      refetch_flush_o,sotre_buffer_we_o,
                      tlb_fe_o,tlb_se_o,tlb_re_o,tlb_we_o,tlb_ie_o,
                      tlb_op_o,tlbidx_found_i,tlbidx_ne_i,tlbidx_index_i,
                      is_kernel_inst_i,
                      csr_wdata_src_i,regs_rdata1_i,regs_rdata2_i,
                      excep_en_o,excep_type_o,mem_rwaddr_o,
                      llbit_we_o,llbit_wdata_o,                                 
                      csr_raddr_src_o,csr_we_o,csr_waddr_o,csr_wdata_o,//csr写使能 
                      wb_regs_wdata_src_i,regs_we_o,regs_waddr_o,regs_wdata_o,
                      pc_i,inst_i};
                      
assign forward_obus={llbit_we_o,llbit_wdata_o,                                                                      
                     regs_we_o,regs_waddr_o,regs_wdata_o,
                     dr_stall_o};

assign now_sent_mem_req_o = mem_req_i&now_valid_i;

assign to_pre_obus   = 1'b0;
assign to_cache_obus = {cache_refill_valid_o,uncache_o,p_tag_o};
assign store_buffer_ce_o = mem_we_i&mem_req_i&excep_flush_i;

 assign to_ila_obus = {inst_i,pc_i};
/*******************************complete logical function (逻辑功能实现)*******************************/
  //forward
  assign dr_stall_o =  now_valid_i & (wb_regs_wdata_src_i | (mem_req_i & (~data_sram_data_ok_i)) );
  //寄存器组
    assign regs_we_o    = regs_we_i & now_ctl_valid;//因为有forward，所以可能无效要立马实现，we——i=1&&当前数据有效，we_o=1
    assign regs_waddr_o = regs_waddr_i;  
    assign regs_wdata_o = mul_en_i ? (mul_hl_i? mul_result[63:32] :mul_result[31:0]):
                          mem_regs_wdata_src_i ? mem_rdata :regs_wdata_i;

    assign mem_rwaddr_low2 = mem_rwaddr_i[1:0];
    
    
    
    wallace_mul_pipeline3  wallace_mul_pipeline3_item(
    .s10(mul_part_data_s10_i ) ,
    .c10(mul_part_data_c10_i ) ,
    .s11(mul_part_data_s11_i ) ,
    .c11(mul_part_data_c11_i ) ,
    .r  ( mul_result ) 
);
    
    
    
    
    
    
    
    
    
    
    
    
   
    always @(*)begin
            case(mem_mem_data_src_i)
                `spMemMemDataSrcLen'b000:begin//字
                    mem_rdata = mem_rdata_i ;
                end
                `spMemMemDataSrcLen'b010:begin//半字0扩展
                    case(mem_rwaddr_low2[1])
                        1'b0:begin
                            mem_rdata = {16'd0,mem_rdata_i[15:0]};
                        end
                        default:begin
                            mem_rdata = {16'd0,mem_rdata_i[31:16]};
                        end
                    endcase    
                end
                `spMemMemDataSrcLen'b011:begin//半字符号扩展
                    case(mem_rwaddr_low2[1])
                        1'b0:begin
                            mem_rdata = {{16{mem_rdata_i[15]}},mem_rdata_i[15:0]};
                        end
                        1'b1:begin
                            mem_rdata = { {16{mem_rdata_i[31]}},mem_rdata_i[31:16] };
                        end
                        default:begin
                            mem_rdata = `ZeroWord32B;
                        end
                    endcase
                end
                `spMemMemDataSrcLen'b100:begin//字节0扩展
                    case(mem_rwaddr_low2)
                        2'b00:begin
                            mem_rdata = {24'd0,mem_rdata_i[7:0]};
                        end
                        2'b01:begin
                            mem_rdata = {24'd0,mem_rdata_i[15:8]};
                        end
                        2'b10:begin
                            mem_rdata = {24'd0,mem_rdata_i[23:16]};
                        end
                        default:begin
                            mem_rdata = {24'd0,mem_rdata_i[31:24]};
                        end
                    endcase
                end
                `spMemMemDataSrcLen'b101:begin//字节符号扩展
                    case(mem_rwaddr_low2)
                        2'b00:begin
                            mem_rdata = { {24{mem_rdata_i[7]}},mem_rdata_i[7:0] };
                        end
                        2'b01:begin
                            mem_rdata = { {24{mem_rdata_i[15]}},mem_rdata_i[15:8]};
                        end
                        2'b10:begin
                            mem_rdata = {{24{mem_rdata_i[23]}},mem_rdata_i[23:16]};
                        end
                        default:begin
                            mem_rdata = {{24{mem_rdata_i[31]}},mem_rdata_i[31:24]};
                        end
                    endcase
                end default:begin
                            mem_rdata = `ZeroWord32B;
                end
            endcase
        end

//存储器  
    
    assign  mem_we_o     = mem_we_i & now_ctl_valid;//写使能    
    assign  mem_rwaddr_o = mem_rwaddr_i; 
    assign  mem_req_o    = mem_req_i& now_ctl_valid   ;
 //cache
    assign sotre_buffer_we_o = sotre_buffer_we_i & now_ctl_valid;
    assign p_tag_o           = p_tag_i;
    assign inst_cacop_op_addr_tag_o = p_tag_i;
    assign data_cacop_op_addr_tag_o = p_tag_i;
    
    
    
    
    
    
 
    assign uncache_o = `CLOSE_DCACHE ? 1'b1: uncache_i & now_ctl_valid;
   
   
    assign cache_refill_valid_o =  cache_refill_valid_i&now_ctl_valid;
 //csr
    assign csr_raddr_src_o =  csr_raddr_src_i; 
    assign csr_we_o        =  csr_we_i & now_ctl_valid;        
    assign csr_waddr_o     =  csr_waddr_i;     
    assign csr_wdata_o     =  csr_wdata_i;     
    //llbit                                    
    assign llbit_we_o    =   llbit_we_i & now_ctl_valid;       
    assign llbit_wdata_o =  llbit_wdata_i;  
 //TLB   
    assign tlb_re_o = tlb_re_i & now_ctl_valid;
    assign tlb_se_o = tlb_se_i & now_ctl_valid;
    assign tlb_ie_o = tlb_ie_i & now_ctl_valid;
    assign tlb_we_o = tlb_we_i & now_ctl_valid;
    assign tlb_fe_o = tlb_fe_i & now_ctl_valid;
    assign tlb_op_o = tlb_op_i;
   
    //idle
     assign idle_en_o =  idle_en_i&now_ctl_valid;
     //cache
     assign cacop_en_o= cacop_en_i&now_ctl_valid;
    
     //例外
     assign excep_type_o[`IntLocation]                 = excep_type_i[`IntLocation] ; //0
     assign excep_type_o[`PilLocation]                 = excep_type_i[`PilLocation]&now_ctl_base_valid;//1
     assign excep_type_o[2]                            = excep_type_i[2]&now_ctl_base_valid;//2
     assign excep_type_o[`PifLocation]                 = excep_type_i[`PifLocation] ; //3
     assign excep_type_o[4]                            = excep_type_i[4]&now_ctl_base_valid;//4
     assign excep_type_o[5]                            = excep_type_i[5]&now_ctl_base_valid;//5
     assign excep_type_o[`AdefLocation]                = excep_type_i[`AdefLocation]; //6
     assign excep_type_o[`AdemLocation]                = excep_type_i[`AdemLocation]& &now_ctl_base_valid; //7
       //地址不对齐
     assign excep_type_o[`AleLocation]                 = excep_type_i[`AleLocation];//8
     assign excep_type_o[`FpeLocation:`AleLocation+1]  = excep_type_i[`FpeLocation:`AleLocation+1]; //14：9
     assign excep_type_o[`TlbrLocation]                = excep_type_i[`TlbrLocation]&now_ctl_base_valid;
     assign excep_type_o[`IfPpiLocation:`ErtnLocation] = excep_type_i[`IfPpiLocation:`ErtnLocation];//19：16 
     
     assign excep_en   = excep_en_i ;
     assign excep_en_o = excep_en & now_ctl_base_valid;
     
     assign refetch_flush_o = refetch_flush_i &now_ctl_valid;
  //跳转冲刷
     assign branch_flush_o = branch_flush_i &now_ctl_valid;  
  //有效信号
  assign now_ctl_valid      = now_ctl_base_valid & (~excep_en);                      
  assign now_ctl_base_valid = (~excep_flush_i) & now_valid_i ;    
  
  //握手信号
    assign now_ready_go   = mem_req_i  ? (data_sram_data_ok_i ? 1'b1:1'b0) :1'b1; 
    assign now_allowin_o  = !now_valid_i 
                             || (now_ready_go && next_allowin_i);
    assign now_to_next_valid_o = now_valid_i && now_ready_go;

//差分测试
    assign  diff_load_en_o    = mem_req_i&~mem_we_i& now_ctl_valid;
    assign  diff_store_en_o   = mem_we_i & now_ctl_valid;
    assign  diff_ls_paddr_o   = {p_tag_i,mem_rwaddr_i[11:0]};
    wire [31:0]diff_store_wdata_i;
    wire diff_rdcn_en_i;
    wire [63:0]diff_time_value_i;
    wire [7:0] diff_load_type_i,diff_store_type_i;    
        
   assign  {diff_store_wdata_i,diff_rdcn_en_i,diff_time_value_i,diff_load_type_i,diff_store_type_i}  = mm_to_diff_ibus  ;
        
    assign mem_to_diff_obus = {diff_load_en_o,diff_store_en_o,diff_ls_paddr_o,mm_to_diff_ibus};
endmodule

