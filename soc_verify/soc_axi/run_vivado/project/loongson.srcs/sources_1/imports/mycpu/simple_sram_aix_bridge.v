
/*
*作者：zzq
*创建时间：2023-04-22
*email:3486829357@qq.com
*github:yunzhong8
*输入：
*req_i:读写请求(rd_req)
*rlen_i读长度(用rd_type表示)
*r_ready_o
:
*raddr_i读地址rd_addr
*we:使能wr_req
*size:一次读写长度(由rd_type表示)
*wstrb:写字节使能(wr_wstrb)
*wdata:写数据128bit(wr_data)
*rlast_o:读组合一个字节ret_last
*
*输出：
*模块功能：
*支持burst传输的转接桥
*/
/*************\
\*************/
`include "define.v"
module simple_sram_aix_bridge(
    //时钟
    input  wire  clk      ,
    input  wire  rst_n    ,
    //sram1
    input  wire [`SramIbusWidth]sram_ibus1,
    input  wire [`SramIbusWidth]sram_ibus2,
    
    output wire [`SramObusWidth]sram_obus1,
    output wire [`SramObusWidth]sram_obus2,
    //sram2
    
    //axi
    //ar
  output  wire  [3 :0] axi_arid_o   ,
  output  wire  [31:0] axi_araddr_o ,
  output  wire  [7 :0] axi_arlen_o  ,
  output  wire  [2 :0] axi_arsize_o ,
  output  wire  [1 :0] axi_arburst_o,
  output  wire  [1 :0] axi_arlock_o ,
  output  wire  [3 :0] axi_arcache_o,
  output  wire  [2 :0] axi_arprot_o ,
  output  wire        axi_arvalid_o,
  input   wire        axi_arready_i,
  //r
  input  wire [3 :0] axi_rid_i    ,
  input  wire [31:0] axi_rdata_i  ,
  input  wire [1 :0] axi_rresp_i  ,
  input  wire        axi_rlast_i  ,
  input  wire        axi_rvalid_i ,
  output wire        axi_rready_o ,
  //aw
  output  wire [3 :0] axi_awid_o   ,//不涉及
  output  wire [31:0] axi_awaddr_o ,
  output  wire [7 :0] axi_awlen_o  ,//不涉及
  output  wire [2 :0] axi_awsize_o ,
  output  wire [1 :0] axi_awburst_o,//不涉及
  output  wire [1 :0] axi_awlock_o ,//不涉及
  output  wire [3 :0] axi_awcache_o,//不涉及
  output  wire [2 :0] axi_awprot_o ,//不涉及
  output  wire        axi_awvalid_o,
  input   wire        axi_awready_i,
  //w
  output  wire [3 :0] axi_wid_o    ,//不涉及
  output  wire [31:0] axi_wdata_o  ,
  output  wire [3 :0] axi_wstrb_o  ,
  output  wire        axi_wlast_o  ,//不涉及
  output  wire        axi_wvalid_o ,
  input   wire        axi_wready_i ,
  //b
  input   wire [3 :0] axi_bid_i    ,//不涉及
  input   wire [1 :0] axi_bresp_i  ,//不涉及
  input   wire        axi_bvalid_i ,
  output  wire        axi_bready_o ,
  
  output wire  [`BridgeToDiffBusWidth]       to_diff_obus
         
);

/***************************************input variable define(输入变量定义)**************************************/
  wire        sram2_req_i,sram1_req_i;  
  wire        sram2_wr_i,sram1_wr_i;       
   
  wire [3:0]  sram2_wstrb_i,sram1_wstrb_i;
  wire [31:0] sram2_raddr_i,sram1_raddr_i;    
  wire [31:0] sram2_waddr_i,sram1_waddr_i;    
  wire [2:0]  sram2_rtype_i,sram1_rtype_i;
  wire [2:0]  sram2_wtype_i,sram1_wtype_i;
  wire [127:0] sram2_wdata_i,sram1_wdata_i;   

  wire  sram1_rready_o;
  wire  sram1_rvalid_o;
  wire  sram1_wready_o  ;

  wire  sram2_rready_o;
  wire  sram2_rvalid_o;
  wire  sram2_wready_o  ;
  
  wire [31:0] sram2_rdata_o,sram1_rdata_o;   
  



/***************************************output variable define(输出变量定义)**************************************/
  wire        sram2_rlast_o,sram1_rlast_o;
/***************************************inner variable define(内部变量定义)**************************************/

wire now_write_arrive,now_writing;
wire now_read_arrive,now_reading;

//写外部axi
reg [31:0]axi_w_data[3:0];
reg [1:0]write_count_reg ;
reg [1:0]write_count_max ;
wire write_count_reg_rst1;
wire write_count_reg_rst3;
wire write_count_reg_sub ;
always @(posedge clk)begin
    if(rst_n == `RstEnable)begin
        write_count_reg <= 2'b00;
        write_count_max <=2'b00;
   end else if(write_count_reg_rst1)begin
        write_count_reg <= 2'b00;
        write_count_max <=2'b00;
   end else if(write_count_reg_rst3)begin
        write_count_reg <= 2'b11;
        write_count_max <=2'b11;
        
   end else if(write_count_reg_sub)begin
        write_count_reg <= write_count_reg-2'd1;
   end else begin
        write_count_reg <= write_count_reg;
   end
end

reg  axi_accept_raddr_finish;
wire axi_accept_raddr_finish_we;
wire axi_accept_raddr_finish_rst;

always@(posedge clk)begin
    if(rst_n == `RstEnable|axi_accept_raddr_finish_rst)begin
         axi_accept_raddr_finish <= 1'b0;
    end else if(axi_accept_raddr_finish_we)begin
        axi_accept_raddr_finish <= 1'b1;
    end
end


reg mw_addr_finish,mw_data_finish;
wire mw_addr_finish_we,mw_data_finish_we;
wire mw_addr_finish_rst,mw_data_finish_rst;
always@(posedge clk)begin
    if(rst_n == `RstEnable)begin
         mw_addr_finish <= 1'b0;
    end else if(mw_addr_finish_rst)begin
         mw_addr_finish <= 1'b0;
    end else if( mw_addr_finish_we)begin
         mw_addr_finish <= 1'b1;
    end else begin
       mw_addr_finish   <= mw_addr_finish;
    end
    
     if(rst_n == `RstEnable)begin
         mw_data_finish <= 1'b0;
     end else if(mw_data_finish_rst)begin
        mw_data_finish <= 1'b0;
     end else if(mw_data_finish_we)begin
        mw_data_finish <= 1'b1;
     end else begin
        mw_data_finish <= mw_data_finish;
     end
end  
  
  
  wire axi_cache_re;
  wire axi_cache_we;
  
  reg [3:0]reg_axi_arid_o    ;
  reg [31:0]reg_axi_araddr_o  ;
  reg [7:0]reg_axi_arlen_o   ;
  reg [3:0]reg_axi_arsize_o  ;
  
  
  
  assign sram1_req = ~sram2_req_i&sram1_req_i;
  assign sram2_req = sram2_req_i;
  always @(posedge clk)begin
     if(rst_n == `RstEnable)begin
        reg_axi_arid_o     <= 0;
        reg_axi_araddr_o   <= 0;
        reg_axi_arlen_o    <= 0;           
        reg_axi_arsize_o   <= 0;
                                                      
   end else if(axi_cache_re)begin
               reg_axi_arid_o     <= sram2_req ? 4'b1 :4'b0 ;
               reg_axi_araddr_o   <= sram2_req ? sram2_raddr_i: sram1_raddr_i;
               reg_axi_arlen_o    <= (
                                         (sram2_req &sram2_rtype_i == 3'b100)
                                        |(sram1_req &sram1_rtype_i == 3'b100)
                                    ) ? 8'd3 :8'd0;
                   
               reg_axi_arsize_o   <= (
                                     (sram1_req&(sram1_rtype_i == 3'b001|sram1_rtype_i == 3'b100))
                                    |(sram2_req&(sram2_rtype_i == 3'b001|sram2_rtype_i == 3'b100))
                                  ) ? 3'd2 :3'd0;
    
    
   end else begin
            reg_axi_arid_o     <= reg_axi_arid_o  ;
            reg_axi_araddr_o   <= reg_axi_araddr_o;
            reg_axi_arlen_o    <= reg_axi_arlen_o ;
                                    
            reg_axi_arsize_o   <= reg_axi_arsize_o;
    end
 end

reg [31:0]reg_axi_awaddr_o ;
reg [7:0]reg_axi_awlen_o  ;
reg [3:0]reg_axi_awsize_o ;
reg [3:0]reg_axi_wstrb_o  ;
    
  always @(posedge clk)begin
     if(rst_n == `RstEnable)begin  
        reg_axi_awaddr_o   <= 0;
        reg_axi_awlen_o    <= 0;
        reg_axi_awsize_o   <= 0;
        reg_axi_wstrb_o    <= sram2_wstrb_i;
        axi_w_data[0]      <= 32'd0; 
        axi_w_data[1]      <= 32'd0;
        axi_w_data[2]      <= 32'd0;
        axi_w_data[3]      <= 32'd0;
        
     end else if(axi_cache_we)begin
         reg_axi_awaddr_o   <= sram2_waddr_i;
         reg_axi_awlen_o    <= sram2_wtype_i == 3'b100 ?8'd3:8'd0;
         reg_axi_awsize_o   <= (sram2_wtype_i == 3'b010) |(sram2_wtype_i == 3'b100)? 3'd2 :3'd0;
         
         reg_axi_wstrb_o    <= sram2_wstrb_i;
         
         axi_w_data[0]     <= sram2_wdata_i[31:0]   ;
         axi_w_data[1]     <= sram2_wdata_i[63:32]  ;
         axi_w_data[2]     <= sram2_wdata_i[95:64]  ;
         axi_w_data[3]     <= sram2_wdata_i[127:96] ;
         
     end else begin
        reg_axi_awaddr_o   <= reg_axi_awaddr_o ;
        reg_axi_awlen_o    <= reg_axi_awlen_o  ;
        reg_axi_awsize_o   <= reg_axi_awsize_o ;
        reg_axi_wstrb_o    <= reg_axi_wstrb_o;
        
        axi_w_data[0]     <= axi_w_data[0] ;
        axi_w_data[1]     <= axi_w_data[1] ;
        axi_w_data[2]     <= axi_w_data[2] ;
        axi_w_data[3]     <= axi_w_data[3] ;
        
        
        
        
     end
  
end        
  
    
    
    
  
  
  
  
  
  
  
  
/***************************************parameter define(常量定义)**************************************/
  parameter REmpty = 2'b00;//读初始状态
 
  parameter RWaitExtAXIAcceptAddr= 2'b01;//读等待外部AIX接受地址
  parameter RWaitExtAXIData=2'b10;
  
  parameter WEmpty = 2'b00;//读初始状态 0
  
   parameter WWaitExtAXIAcceptAddrData = 2'b01;//读持续接受CPU数据`2
   parameter WWaitExtAXIWriteFnish = 2'b10;//5
   reg  [1:0]r_cs;
   wire  [1:0]r_ns;
   reg  [1:0]w_cs;
   wire  [1:0]w_ns;
   
   wire rcs_eq_rempty,rcs_eq_rwait_axi_acp_raddr,rcs_eq_rwait_axit_retdata;
   wire[1:0]rcs_eq_rempty_ns,rcs_eq_rwait_axi_acp_raddr_ns,rcs_eq_rwait_axit_retdata_ns;
  
    
   wire wcs_eq_wempty,wcs_eq_wwait_axi_acp_waddr_wdata,wcs_eq_wwait_axi_wfinish;
   wire[1:0]wcs_eq_wempty_ns,wcs_eq_wwait_axi_acp_waddr_wdata_ns,wcs_eq_wwait_axi_wfinish_ns;
   
 
 
 
 
 /***************************************inner variable define(ILA)**************************************/
`ifdef OPEN_ILA 
        (*mark_debug = "true"*) wire [`CacheStateWidth]    ila_r_cs;
        (*mark_debug = "true"*) wire [`CacheStateWidth]    ila_w_cs;
        assign ila_r_cs  = r_cs;
        assign ila_w_cs  = w_cs;
      
    `ifdef OPEN_ILA_Bridge
                                          
          (*mark_debug = "true"*) wire  [3 :0] ila_axi_arid_o        ;
          (*mark_debug = "true"*) wire  [31:0] ila_axi_araddr_o      ;
          (*mark_debug = "true"*) wire  [7 :0] ila_axi_arlen_o       ;
          (*mark_debug = "true"*) wire  [2 :0] ila_axi_arsize_o      ;
   
          (*mark_debug = "true"*) wire         ila_axi_arvalid_o     ;
          (*mark_debug = "true"*) wire         ila_axi_arready_i     ;
          //r
          (*mark_debug = "true"*) wire  [3 :0] ila_axi_rid_i     ;
          (*mark_debug = "true"*) wire  [31:0] ila_axi_rdata_i   ;
          (*mark_debug = "true"*) wire         ila_axi_rlast_i   ;
          (*mark_debug = "true"*) wire         ila_axi_rvalid_i  ;
          (*mark_debug = "true"*) wire         ila_axi_rready_o  ;
          //aw
          (*mark_debug = "true"*) wire  [3 :0] ila_axi_awid_o    ;//不涉及
          (*mark_debug = "true"*) wire  [31:0] ila_axi_awaddr_o  ;
          (*mark_debug = "true"*) wire  [7 :0] ila_axi_awlen_o   ;//不涉及
          (*mark_debug = "true"*) wire         ila_axi_awvalid_o ;
          (*mark_debug = "true"*) wire         ila_axi_awready_i ;
          //w
         (*mark_debug = "true"*) wire  [31:0]  ila_axi_wdata_o  ;
         (*mark_debug = "true"*) wire  [3 :0]  ila_axi_wstrb_o  ;
         (*mark_debug = "true"*) wire          ila_axi_wlast_o  ;//不涉及
         (*mark_debug = "true"*) wire          ila_axi_wvalid_o ;
         (*mark_debug = "true"*) wire          ila_axi_wready_i ;
          //b
          
          (*mark_debug = "true"*) wire         ila_axi_bvalid_i;
          (*mark_debug = "true"*) wire         ila_axi_bready_o;
         
         assign ila_axi_arid_o                =   axi_arid_o       ;      
         assign ila_axi_araddr_o              =   axi_araddr_o     ;
         assign ila_axi_arlen_o               =   axi_arlen_o      ;
         
                                                                   
         assign ila_axi_arvalid_o             =   axi_arvalid_o    ;
         assign ila_axi_arready_i             =   axi_arready_i    ;
                                                                   
         assign ila_axi_rid_i                 =   axi_rid_i        ;
         assign ila_axi_rdata_i               =   axi_rdata_i      ;
         assign ila_axi_rlast_i               =   axi_rlast_i      ;
         assign ila_axi_rvalid_i              =   axi_rvalid_i     ;
         assign ila_axi_rready_o              =   axi_rready_o     ;
                                                                   
         assign ila_axi_awid_o                =   axi_awid_o       ;
         assign ila_axi_awaddr_o              =   axi_awaddr_o     ;
         assign ila_axi_awlen_o               =   axi_awlen_o      ;
         assign ila_axi_awvalid_o             =   axi_awvalid_o    ;
         assign ila_axi_awready_i             =   axi_awready_i    ;
                                                                   
         assign ila_axi_wdata_o               =   axi_wdata_o      ;
        
         assign ila_axi_wlast_o               =   axi_wlast_o      ;
         assign ila_axi_wvalid_o              =   axi_wvalid_o     ;
         assign ila_axi_wready_i              =   axi_wready_i     ;
                                                                   
         assign ila_axi_bvalid_i              =   axi_bvalid_i     ;
         assign ila_axi_bready_o              =   axi_bready_o     ;
          `ifdef OPEN_ILA_Bridge_WHOLE
              assign ila_axi_arsize_o         =   axi_arsize_o     ;
         
              assign ila_axi_wstrb_o          =   axi_wstrb_o      ;
           `endif
       
       `endif                                                   
      
 `endif  
  
/****************************************input decode(输入解码)***************************************/
assign   {sram1_req_i,sram1_rtype_i,sram1_raddr_i,
          sram1_wr_i, sram1_wtype_i,sram1_waddr_i,sram1_wstrb_i,sram1_wdata_i}=sram_ibus1;
assign   {sram2_req_i,sram2_rtype_i,sram2_raddr_i,
          sram2_wr_i,sram2_wtype_i,sram2_waddr_i,sram2_wstrb_i,sram2_wdata_i}=sram_ibus2;
/****************************************output code(输出解码)***************************************/
assign sram_obus1 = {sram1_rlast_o,1'b1,sram1_rvalid_o,sram1_rready_o,sram1_rdata_o};
assign sram_obus2 = {sram2_rlast_o,sram2_wready_o,sram2_rvalid_o,sram2_rready_o,sram2_rdata_o};


/*******************************complete logical function (读写状态机)*******************************/
 assign rcs_eq_rempty              = r_cs== REmpty;
 assign rcs_eq_rwait_axi_acp_raddr = r_cs== RWaitExtAXIAcceptAddr; 
 assign rcs_eq_rwait_axit_retdata  = r_cs== RWaitExtAXIData;
 
 assign axi_cache_re = rcs_eq_rempty &(!now_write_arrive && !now_writing)&(sram1_req|sram2_req);

 
 assign rcs_eq_rempty_ns               = axi_cache_re? RWaitExtAXIAcceptAddr:REmpty;
 assign rcs_eq_rwait_axi_acp_raddr_ns  = rcs_eq_rwait_axi_acp_raddr ? ( axi_arready_i   ? RWaitExtAXIData  : RWaitExtAXIAcceptAddr) :REmpty;
 assign rcs_eq_rwait_axit_retdata_ns   = rcs_eq_rwait_axit_retdata  ? (axi_rvalid_i& axi_rlast_i ? REmpty :RWaitExtAXIData) :REmpty;
 
 assign  r_ns = rcs_eq_rempty_ns |rcs_eq_rwait_axi_acp_raddr_ns|rcs_eq_rwait_axit_retdata_ns;





 assign wcs_eq_wempty                      = w_cs == WEmpty           ;
 assign wcs_eq_wwait_axi_acp_waddr_wdata   = w_cs == WWaitExtAXIAcceptAddrData ;
 assign wcs_eq_wwait_axi_wfinish           = w_cs == WWaitExtAXIWriteFnish     ;
  
 assign axi_cache_we                          = wcs_eq_wempty  &(!now_reading ) &sram2_wr_i; 
 assign wcs_eq_wempty_ns                      = axi_cache_we     ? WWaitExtAXIAcceptAddrData  : WEmpty;                
 assign wcs_eq_wwait_axi_acp_waddr_wdata_ns   = wcs_eq_wwait_axi_acp_waddr_wdata  ? 
                                                                                   ((mw_data_finish & mw_addr_finish) ? WWaitExtAXIWriteFnish : WWaitExtAXIAcceptAddrData
                                                                                   ) : WEmpty;   
                                                         
 assign wcs_eq_wwait_axi_wfinish_ns           = wcs_eq_wwait_axi_wfinish  ?(axi_bvalid_i    ?  WEmpty:WWaitExtAXIWriteFnish ):WEmpty ;            
  
 assign w_ns =wcs_eq_wempty_ns| wcs_eq_wwait_axi_acp_waddr_wdata_ns|wcs_eq_wwait_axi_wfinish_ns;





assign now_write_arrive = (w_cs==WEmpty)  && sram2_wr_i;

assign now_writing =  w_cs!=WEmpty;

assign now_read_arrive =  r_cs == REmpty && (sram2_req  || sram1_req);
assign now_reading = r_cs != REmpty;



assign axi_arid_o     = reg_axi_arid_o;
assign axi_araddr_o   = reg_axi_araddr_o;
assign axi_arlen_o    = reg_axi_arlen_o;

assign axi_arsize_o   = reg_axi_arsize_o;
                         
assign axi_arburst_o  = 2'b01;
assign axi_arlock_o   = 0;
assign axi_arcache_o  = 0;
assign axi_arprot_o   = 0;
assign axi_arvalid_o  = rcs_eq_rwait_axi_acp_raddr& ~axi_accept_raddr_finish;

            
assign axi_rready_o    = rcs_eq_rwait_axit_retdata;
   
assign axi_awid_o     = 4'b0001;
assign axi_awaddr_o   = reg_axi_awaddr_o;
assign axi_awlen_o    = reg_axi_awlen_o  ;
assign axi_awsize_o   = reg_axi_awsize_o ;
assign axi_awburst_o  = 2'b01;
assign axi_awlock_o   = 0; 
assign axi_awcache_o  = 0; 
assign axi_awprot_o   = 0;

assign axi_awvalid_o  = wcs_eq_wwait_axi_acp_waddr_wdata&~mw_addr_finish;



 wire [1:0]wirte_back_index;

 assign axi_wid_o        = 4'b0001;
 assign wirte_back_index = write_count_max-write_count_reg;
assign axi_wdata_o   = axi_w_data[wirte_back_index];
assign axi_wstrb_o   = reg_axi_wstrb_o;
assign axi_wlast_o   = write_count_reg==2'b00;

`ifdef BRIDGE_WA_WD_SERIAL
    //地址接受完成才发数据
    assign axi_wvalid_o  = wcs_eq_wwait_axi_acp_waddr_wdata & mw_addr_finish & ~mw_data_finish;
`else
    //数据地址同时接收
    assign axi_wvalid_o  = wcs_eq_wwait_axi_acp_waddr_wdata & ~mw_data_finish;
`endif    

 
assign axi_bready_o = wcs_eq_wwait_axi_wfinish;




assign sram1_rlast_o = axi_rlast_i;
assign sram2_rlast_o = axi_rlast_i;

assign sram2_rdata_o   = axi_rdata_i;//返回数据传给端口2
assign sram1_rdata_o   = axi_rdata_i;

 assign sram1_rready_o = rcs_eq_rempty&!now_write_arrive && !now_writing&~sram2_req;
 assign sram1_rvalid_o = rcs_eq_rwait_axit_retdata&&( axi_rid_i==4'b0)&axi_rvalid_i;
 assign sram1_wready_o = wcs_eq_wempty&~now_reading&~now_read_arrive ;
        
 assign sram2_rready_o = rcs_eq_rempty&!now_write_arrive && !now_writing;
 assign sram2_rvalid_o = rcs_eq_rwait_axit_retdata&&( axi_rid_i==4'b1)&axi_rvalid_i;
 assign sram2_wready_o  =  wcs_eq_wempty&~now_reading&~now_read_arrive ;


assign  write_count_reg_rst1= wcs_eq_wempty&&~now_reading&sram2_wr_i&(sram2_wtype_i!=3'b100)?1'b1:1'b0;                                                    
assign  write_count_reg_rst3= wcs_eq_wempty&&~now_reading&sram2_wr_i&(sram2_wtype_i==3'b100)?1'b1:1'b0;

assign  write_count_reg_sub = wcs_eq_wwait_axi_acp_waddr_wdata & axi_wvalid_o & axi_wready_i?1'b1:1'b0;


assign axi_accept_raddr_finish_rst =  rcs_eq_rempty|rcs_eq_rwait_axit_retdata;
assign axi_accept_raddr_finish_we  =  rcs_eq_rwait_axi_acp_raddr & axi_arready_i;


                                          
assign  mw_addr_finish_rst = wcs_eq_wempty|wcs_eq_wwait_axi_wfinish;                                                 
assign  mw_data_finish_rst = wcs_eq_wempty|wcs_eq_wwait_axi_wfinish;                                                   
assign  mw_addr_finish_we =  wcs_eq_wwait_axi_acp_waddr_wdata&axi_awready_i ;                                               
assign  mw_data_finish_we =  wcs_eq_wwait_axi_acp_waddr_wdata&(write_count_reg==2'b00)&axi_wvalid_o&axi_wready_i;



always@(posedge clk)begin
        if(rst_n == `RstEnable )begin
            r_cs <= REmpty;
        end else begin 
            r_cs <= r_ns;
        end
 end
 
 


 always@(posedge clk)begin
        if(rst_n == `RstEnable )begin
            w_cs <= WEmpty;
        end else begin 
            w_cs <= w_ns;
        end
 end
 
 
 
 
 //打印轨迹接口
assign to_diff_obus ={

axi_arid_o   ,axi_araddr_o ,axi_arlen_o  ,//4+31+8//43
             
             
axi_arvalid_o,axi_arready_i,//2
             
axi_rid_i    ,axi_rdata_i  ,axi_rlast_i  ,axi_rvalid_i ,axi_rready_o ,//4+32+1+1+1//39
             
axi_arsize_o  ,axi_wstrb_o   ,axi_awaddr_o ,axi_awlen_o  ,axi_awvalid_o,axi_awready_i,//3+4+32+8+1+1=49
             
axi_wdata_o  ,axi_wlast_o  ,axi_wvalid_o ,axi_wready_i ,//+32+1+1+1=35
             
axi_bvalid_i ,axi_bready_o //1+1=2
             

             

};//2+35+49+39+2+43=


endmodule
