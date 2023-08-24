//`include "DefineModuleBus.h"
`include "define.v"
module mycpu_top(
    input  wire        aclk,
    input  wire        aresetn,
    input  wire  [7:0] ext_int,
        //ar                                                
    output  wire [3 :0] arid   ,                        
    output  wire [31:0] araddr ,                        
    output  wire [7 :0] arlen  ,                        
    output  wire [2 :0] arsize ,                        
    output  wire [1 :0] arburst,                        
    output  wire [1 :0] arlock ,                        
    output  wire [3 :0] arcache,                        
    output  wire [2 :0] arprot ,                        
    output  wire        arvalid,                        
    input wire          arready,                          
    //r                                                   
    input wire [3 :0] rid    ,                          
    input wire [31:0] rdata  ,                          
    input wire [1 :0] rresp  ,                          
    input wire        rlast  ,                          
    input wire        rvalid ,                          
    output  wire      rready ,                        
    //aw                                                  
    output  wire [3 :0] awid   ,                        
    output  wire [31:0] awaddr ,                        
    output  wire [7 :0] awlen  ,                        
    output  wire [2 :0] awsize ,                        
    output  wire [1 :0] awburst,                        
    output  wire [1 :0] awlock ,                        
    output  wire [3 :0] awcache,                        
    output  wire [2 :0] awprot ,                        
    output  wire        awvalid,                        
    input wire          awready,                          
    //w                                                   
    output  wire [3 :0] wid    ,                        
    output  wire [31:0] wdata  ,                        
    output  wire [3 :0] wstrb  ,                        
    output  wire        wlast  ,                        
    output  wire        wvalid ,                        
    input wire          wready ,                          
    //b                                                   
    input wire [3 :0] bid    ,                          
    input wire [1 :0] bresp  ,                          
    input wire        bvalid ,                          
    output  wire      bready,     
    //cpu 
    output wire error_o, 
    
    //差分测试接口
  
   output wire  [`LineOffcialWbToDiffBusWidth] line1_wb_diiff_obus,
   output wire  [`LineOffcialWbToDiffBusWidth] line2_wb_diiff_obus,
   output wire [`CsrToDiffBusWidth]        csr_diff_obus  ,
   output wire [`RegsToDiffBusWidth]       regs_diff_obus ,
    
    
    
    //trace 
    output wire [31:0] debug_wb_pc,                           
    output wire [ 3:0] debug_wb_rf_we,                        
    output wire [ 4:0] debug_wb_rf_wnum,                      
    output wire [31:0] debug_wb_rf_wdata                      
                        
                     

);


/***************************************input variable define(输入变量定义)**************************************/

     wire                         inst_rd_req        ;
     wire [2:0]                   inst_rd_type       ;
     wire [31:0]                  inst_rd_addr       ;
                                                    
     wire                         inst_rd_rdy        ;
     wire                         inst_ret_valid     ;
     wire                         inst_ret_last      ;
     wire [31:0]                  inst_ret_data      ;
                                                   
     wire                         inst_wr_req        ;
     wire [2:0]                   inst_wr_type       ;
     wire [31:0]                  inst_wr_addr       ;
     wire [3:0]                   inst_wr_wstrb      ;
     wire [`CacheBurstDataWidth]  inst_wr_data       ;
     wire                         inst_wr_rdy        ;
                                                     
     wire                         data_rd_req        ;
     wire [2:0]                   data_rd_type       ;
     wire [31:0]                  data_rd_addr       ;
                                                    
     wire                         data_rd_rdy        ;
     wire                         data_ret_valid     ;
     wire                         data_ret_last      ;
     wire [31:0]                  data_ret_data      ;
                                                     
     wire                         data_wr_req        ;
     wire [2:0]                   data_wr_type       ;
     wire [31:0]                  data_wr_addr       ;
     wire [3:0]                   data_wr_wstrb      ;
     wire [`CacheBurstDataWidth]  data_wr_data       ;
     wire                         data_wr_rdy        ;   
                                                            
    
    
 
    wire [`SramIbusWidth]sram_ibus2,sram_ibus1;
    wire [`SramObusWidth]sram_obus2,sram_obus1;
    
    wire[`BridgeToDiffBusWidth] bridge_to_diff_obus;
//cp/*******************************complete logical function (逻辑功能实现)*******************************/u
mycpu_cache_top  mycpu_cache_item (

         .aclk           (aclk   ),     
         .aresetn        (aresetn),     
                            
                            
         .inst_rd_req_o      (inst_rd_req    ),
         .inst_rd_type_o     (inst_rd_type   ),
         .inst_rd_addr_o     (inst_rd_addr   ),
                           
         .inst_rd_rdy_i      (inst_rd_rdy    ),  
         .inst_ret_valid_i   (inst_ret_valid ), 
         .inst_ret_last_i    (inst_ret_last  ),
         .inst_ret_data_i    (inst_ret_data  ),
                            
         .inst_wr_req_o      (inst_wr_req    ),
         .inst_wr_type_o     (inst_wr_type   ),
         .inst_wr_addr_o     (inst_wr_addr   ),
         .inst_wr_wstrb_o    (inst_wr_wstrb  ),
         .inst_wr_data_o     (inst_wr_data   ),
         .inst_wr_rdy_i      (inst_wr_rdy    ),//
                           
                           
         .data_rd_req_o      (data_rd_req    ),
         .data_rd_type_o     (data_rd_type   ),
         .data_rd_addr_o     (data_rd_addr   ),
                           
         .data_rd_rdy_i      (data_rd_rdy    ),
         .data_ret_valid_i   (data_ret_valid ),
         .data_ret_last_i    (data_ret_last  ),
         .data_ret_data_i    (data_ret_data  ),
                            
         .data_wr_req_o      (data_wr_req    ),
         .data_wr_type_o     (data_wr_type   ),
         .data_wr_addr_o     (data_wr_addr   ),
         .data_wr_wstrb_o    (data_wr_wstrb  ),
         .data_wr_data_o     (data_wr_data   ),
         .data_wr_rdy_i      (data_wr_rdy    ),
         //中断
         .hardware_interrupt_data(ext_int),
         //CPU错误信息
         .error_o (error_o),
         //差分
          .wb_diiff_obus  ({line2_wb_diiff_obus,line1_wb_diiff_obus}), 
          .csr_diff_obus  (csr_diff_obus  ), 
          .regs_diff_obus (regs_diff_obus ), 
         
         //debug interface
         .debug_wb_pc      (debug_wb_pc      ),
         .debug_wb_rf_we   (debug_wb_rf_we   ),
         .debug_wb_rf_wnum (debug_wb_rf_wnum ),
         .debug_wb_rf_wdata(debug_wb_rf_wdata) 
         );
assign sram_ibus1 = {inst_rd_req,inst_rd_type,inst_rd_addr,
                    inst_wr_req,inst_wr_type,inst_wr_addr,inst_wr_wstrb,inst_wr_data  };
                    
assign sram_ibus2 = {data_rd_req,data_rd_type,data_rd_addr,
                     data_wr_req,data_wr_type,data_wr_addr,data_wr_wstrb,data_wr_data};
                     
assign {inst_ret_last,inst_wr_rdy,inst_ret_valid,inst_rd_rdy,inst_ret_data} = sram_obus1;
assign {data_ret_last,data_wr_rdy,data_ret_valid,data_rd_rdy,data_ret_data} = sram_obus2;



  simple_sram_aix_bridge simple_sram_axi_bridge_item(
    //时钟
      .clk      (aclk),
      .rst_n    (aresetn),
    //sram1
    .sram_ibus1(sram_ibus1),
    .sram_ibus2(sram_ibus2),
    .sram_obus1(sram_obus1),
    .sram_obus2(sram_obus2),
    //sram2
    
    //axi
    //ar
  .axi_arid_o   (arid   ),
  .axi_araddr_o (araddr ),
  .axi_arlen_o  (arlen  ),
  .axi_arsize_o (arsize ),
  .axi_arburst_o(arburst),
  .axi_arlock_o (arlock ),
  .axi_arcache_o(arcache),
  .axi_arprot_o (arprot ),
  .axi_arvalid_o(arvalid),
  .axi_arready_i(arready),
  //r
  .axi_rid_i    (rid   ),
  .axi_rdata_i   (rdata ),
  .axi_rresp_i   (rresp ),
  .axi_rlast_i   (rlast ),
  .axi_rvalid_i  (rvalid),
  .axi_rready_o (rready),
 //aw
  .axi_awid_o   (awid   ),
  .axi_awaddr_o (awaddr ),
  .axi_awlen_o  (awlen  ),
  .axi_awsize_o (awsize ),
  .axi_awburst_o(awburst),
  .axi_awlock_o (awlock ),
  .axi_awcache_o(awcache),
  .axi_awprot_o (awprot ),
  .axi_awvalid_o(awvalid),
  .axi_awready_i(awready),
  //w
  .axi_wid_o    (wid   ),
  .axi_wdata_o  (wdata ),
  .axi_wstrb_o  (wstrb ),
  .axi_wlast_o  (wlast ),
  .axi_wvalid_o (wvalid),
  .axi_wready_i (wready),
  //b
  .axi_bid_i     (bid   ),
  .axi_bresp_i   (bresp ),
  .axi_bvalid_i  (bvalid),
  .axi_bready_o  (bready),
  .to_diff_obus (bridge_to_diff_obus)
  );
    
 





 `ifdef OPEN_DIFF 
    diff_bridge   diff_bridge_item
(
     .clk     (aclk   ) ,
     .rst_n   (aresetn) ,
  



    .to_diff_ibus (bridge_to_diff_obus)    
    
); 
   `endif
  
  endmodule