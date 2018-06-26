//--------------------------------------------------------------------------------
// Project    : SWITCH
// File       : pcie_app.v
// Version    : 0.1
// Author     : Vipin.K
//
// Description: PCI Express application top. Instantiates Rx, Tx engines, register set
//              the user PCIe stream controllers.
//--------------------------------------------------------------------------------

`timescale 1ps / 1ps

`define PCI_EXP_EP_OUI                           24'h000A35
`define PCI_EXP_EP_DSN_1                         {{8'h1},`PCI_EXP_EP_OUI}
`define PCI_EXP_EP_DSN_2                         32'h00000001

module  pcie_app#(
  parameter C_DATA_WIDTH     = 256,            // RX/TX interface data width
  parameter NUM_PCIE_STRM    = 4,
  parameter RECONFIG_ENABLE  = 1,
  // Do not override parameters below this line
  parameter KEEP_WIDTH                            = C_DATA_WIDTH / 32,
  parameter [1:0]  AXISTEN_IF_WIDTH               = (C_DATA_WIDTH == 256) ? 2'b10 : (C_DATA_WIDTH == 128) ? 2'b01 : 2'b00,
  parameter        AXISTEN_IF_RQ_ALIGNMENT_MODE   = "FALSE",
  parameter        AXISTEN_IF_CC_ALIGNMENT_MODE   = "FALSE",
  parameter        AXISTEN_IF_CQ_ALIGNMENT_MODE   = "FALSE",
  parameter        AXISTEN_IF_RC_ALIGNMENT_MODE   = "FALSE",
  parameter        AXISTEN_IF_ENABLE_CLIENT_TAG   = 0,
  parameter        AXISTEN_IF_RQ_PARITY_CHECK     = 0,
  parameter        AXISTEN_IF_CC_PARITY_CHECK     = 0,
  parameter        AXISTEN_IF_MC_RX_STRADDLE      = 0,
  parameter        AXISTEN_IF_ENABLE_RX_MSG_INTFC = 0,
  parameter [17:0] AXISTEN_IF_ENABLE_MSG_ROUTE    = 18'h2FFFF
)(

  input                                      pcie_core_clk,
  input                                      user_reset,
  input                                      user_lnk_up,

  //----------------------------------------------------------------------------------------------------------------//
  //  AXI Interface                                                                                                 //
  //----------------------------------------------------------------------------------------------------------------//

  output                                     s_axis_rq_tlast,
  output              [C_DATA_WIDTH-1:0]     s_axis_rq_tdata,
  output                          [59:0]     s_axis_rq_tuser,
  output                [KEEP_WIDTH-1:0]     s_axis_rq_tkeep,
  input                            [3:0]     s_axis_rq_tready,
  output                                     s_axis_rq_tvalid,

  input               [C_DATA_WIDTH-1:0]     m_axis_rc_tdata,
  input                           [74:0]     m_axis_rc_tuser,
  input                                      m_axis_rc_tlast,
  input                 [KEEP_WIDTH-1:0]     m_axis_rc_tkeep,
  input                                      m_axis_rc_tvalid,
  output                                     m_axis_rc_tready,

  input               [C_DATA_WIDTH-1:0]     m_axis_cq_tdata,
  input                           [84:0]     m_axis_cq_tuser,
  input                                      m_axis_cq_tlast,
  input                 [KEEP_WIDTH-1:0]     m_axis_cq_tkeep,
  input                                      m_axis_cq_tvalid,
  output                                     m_axis_cq_tready,

  output              [C_DATA_WIDTH-1:0]     s_axis_cc_tdata,
  output                          [32:0]     s_axis_cc_tuser,
  output                                     s_axis_cc_tlast,
  output                [KEEP_WIDTH-1:0]     s_axis_cc_tkeep,
  output                                     s_axis_cc_tvalid,
  input                            [3:0]     s_axis_cc_tready,

  input                            [3:0]     pcie_rq_seq_num,
  input                                      pcie_rq_seq_num_vld,
  input                            [5:0]     pcie_rq_tag,
  input                                      pcie_rq_tag_vld,

  input                            [1:0]     pcie_tfc_nph_av,
  input                            [1:0]     pcie_tfc_npd_av,
  output                                     pcie_cq_np_req,
  input                            [5:0]     pcie_cq_np_req_count,

  //----------------------------------------------------------------------------------------------------------------//
  //  Configuration (CFG) Interface                                                                                 //
  //----------------------------------------------------------------------------------------------------------------//

  //----------------------------------------------------------------------------------------------------------------//
  // EP and RP                                                                                                      //
  //----------------------------------------------------------------------------------------------------------------//

  input                                      cfg_phy_link_down,
  input                            [3:0]     cfg_negotiated_width,
  input                            [2:0]     cfg_current_speed,
  input                            [2:0]     cfg_max_payload,
  input                            [2:0]     cfg_max_read_req,
  input                            [7:0]     cfg_function_status,
  input                            [5:0]     cfg_function_power_state,
  input                           [11:0]     cfg_vf_status,
  input                           [17:0]     cfg_vf_power_state,
  input                            [1:0]     cfg_link_power_state,

  // Management Interface
  output reg                      [18:0]     cfg_mgmt_addr,
  output reg                                 cfg_mgmt_write,
  output reg                      [31:0]     cfg_mgmt_write_data,
  output reg                       [3:0]     cfg_mgmt_byte_enable,
  output reg                                 cfg_mgmt_read,
  input                           [31:0]     cfg_mgmt_read_data,
  input                                      cfg_mgmt_read_write_done,
  output wire                                cfg_mgmt_type1_cfg_reg_access,

  // Error Reporting Interface
  input                                      cfg_err_cor_out,
  input                                      cfg_err_nonfatal_out,
  input                                      cfg_err_fatal_out,
  //input                                      cfg_local_error,

  input                                      cfg_ltr_enable,
  input                            [5:0]     cfg_ltssm_state,
  input                            [1:0]     cfg_rcb_status,
  input                            [1:0]     cfg_dpa_substate_change,
  input                            [1:0]     cfg_obff_enable,
  input                                      cfg_pl_status_change,

  input                            [1:0]     cfg_tph_requester_enable,
  input                            [5:0]     cfg_tph_st_mode,
  input                            [5:0]     cfg_vf_tph_requester_enable,
  input                           [17:0]     cfg_vf_tph_st_mode,

  input                                      cfg_msg_received,
  input                            [7:0]     cfg_msg_received_data,
  input                            [4:0]     cfg_msg_received_type,

  output                                     cfg_msg_transmit,
  output                           [2:0]     cfg_msg_transmit_type,
  output                          [31:0]     cfg_msg_transmit_data,
  input                                      cfg_msg_transmit_done,

  input                            [7:0]     cfg_fc_ph,
  input                           [11:0]     cfg_fc_pd,
  input                            [7:0]     cfg_fc_nph,
  input                           [11:0]     cfg_fc_npd,
  input                            [7:0]     cfg_fc_cplh,
  input                           [11:0]     cfg_fc_cpld,
  output                           [2:0]     cfg_fc_sel,

  output  wire                     [2:0]     cfg_per_func_status_control,
  input                           [15:0]     cfg_per_func_status_data,
  output  wire                     [2:0]     cfg_per_function_number,
  output  wire                               cfg_per_function_output_request,
  input                                      cfg_per_function_update_done,

  output wire                     [63:0]     cfg_dsn,
  output                                     cfg_power_state_change_ack,
  input                                      cfg_power_state_change_interrupt,
  output wire                                cfg_err_cor_in,
  output wire                                cfg_err_uncor_in,

  input                            [1:0]     cfg_flr_in_process,
  output wire                      [1:0]     cfg_flr_done,
  input                            [5:0]     cfg_vf_flr_in_process,
  output wire                      [5:0]     cfg_vf_flr_done,

  output wire                                cfg_link_training_enable,

  input                                      cfg_ext_read_received,
  input                                      cfg_ext_write_received,
  input                            [9:0]     cfg_ext_register_number,
  input                            [7:0]     cfg_ext_function_number,
  input                           [31:0]     cfg_ext_write_data,
  input                            [3:0]     cfg_ext_write_byte_enable,
  output wire                     [31:0]     cfg_ext_read_data,
  output wire                                cfg_ext_read_data_valid,

  output wire                      [7:0]     cfg_ds_port_number,
  output wire                      [7:0]     cfg_ds_bus_number,
  output wire                      [4:0]     cfg_ds_device_number,
  output wire                      [2:0]     cfg_ds_function_number,
  //----------------------------------------------------------------------------------------------------------------//
  // EP Only                                                                                                        //
  //----------------------------------------------------------------------------------------------------------------//

  // Interrupt Interface Signals
  output                           [3:0]     cfg_interrupt_int,
  output wire                      [1:0]     cfg_interrupt_pending,
  input                                      cfg_interrupt_sent,

  input                            [1:0]     cfg_interrupt_msi_enable,
  input                            [5:0]     cfg_interrupt_msi_vf_enable,
  input                            [5:0]     cfg_interrupt_msi_mmenable,
  input                                      cfg_interrupt_msi_mask_update,
  input                           [31:0]     cfg_interrupt_msi_data,
  output wire                      [3:0]     cfg_interrupt_msi_select,
  output                          [31:0]     cfg_interrupt_msi_int,
  output wire                     [63:0]     cfg_interrupt_msi_pending_status,
  input                                      cfg_interrupt_msi_sent,
  input                                      cfg_interrupt_msi_fail,
  
  output wire                      [2:0]     cfg_interrupt_msi_attr,
  output wire                                cfg_interrupt_msi_tph_present,
  output wire                      [1:0]     cfg_interrupt_msi_tph_type,
  output wire                      [8:0]     cfg_interrupt_msi_tph_st_tag,
  output wire                      [2:0]     cfg_interrupt_msi_function_number,

// EP only
  input                                      cfg_hot_reset_in,
  output wire                                cfg_config_space_enable,
  output wire                                cfg_req_pm_transition_l23_ready,

// RP only
  output wire                                cfg_hot_reset_out,

 //user
 output                                      user_clk_o,
 output                                      user_reset_o,
 input                                       user_intr_req_i,
 output                                      user_intr_ack_o,
 output                                      user_str_data_valid_o,
 input                                       user_str_ack_i,
 output [C_DATA_WIDTH-1:0]                   user_str_data_o,
 input                                       user_str_data_valid_i,
 output                                      user_str_ack_o,
 input  [C_DATA_WIDTH-1:0]                   user_str_data_i,
 output  [31:0]                              sys_user_dma_addr_o,
 output  [31:0]                              user_sys_dma_addr_o,
 output  [31:0]                              sys_user_dma_len_o, 
 output  [31:0]                              user_sys_dma_len_o, 
 output                                      user_sys_dma_en_o,
 output                                      sys_user_dma_en_o,
 
 output [31:0]                               user_data_o,   
 output [31:0]                               user_addr_o,   
 output                                      user_wr_req_o, 
 input                                       user_wr_ack_i,
 input  [31:0]                               user_data_i,   
 input                                       user_rd_ack_i, 
 output                                      user_rd_req_o, 
 
//icap 100MHz clock from PCIe clock generator
 input                                       icap_clk_i
);


  wire     m_axis_cq_tready_bit;
  wire     m_axis_rc_tready_bit;
  wire     engine_reset_n;


  //----------------------------------------------------------------------------------------------------------------//
  // PCIe Block EP Tieoffs - Example PIO doesn't support the following outputs                                      //
  //----------------------------------------------------------------------------------------------------------------//

  assign cfg_dsn                             = {`PCI_EXP_EP_DSN_2, `PCI_EXP_EP_DSN_1};  // Assign the input DSN

//  assign cfg_mgmt_addr                       = 19'h0;                // Zero out CFG MGMT 19-bit address port
//  assign cfg_mgmt_write                      = 1'b0;                 // Do not write CFG space
//  assign cfg_mgmt_write_data                 = 32'h0;                // Zero out CFG MGMT input data bus
//  assign cfg_mgmt_byte_enable                = 4'h0;                 // Zero out CFG MGMT byte enables
//  assign cfg_mgmt_read                       = 1'b0;                 // Do not read CFG space
  assign cfg_mgmt_type1_cfg_reg_access       = 1'b0;

  assign cfg_per_func_status_control         = 3'h0;                 // Do not request per function status
  assign cfg_per_function_number             = 3'h0;                 // Zero out function num for status req
  assign cfg_per_function_output_request     = 1'b0;                 // Do not request configuration status update

  assign cfg_err_cor_in                      = 1'b0;                 // Never report Correctable Error
  assign cfg_err_uncor_in                    = 1'b0;                 // Never report UnCorrectable Error

  //assign cfg_flr_done                        = 1'b0;                 // FIXME : how to drive this?
  //assign cfg_vf_flr_done                     = 1'b0;                 // FIXME : how to drive this?

  assign cfg_link_training_enable            = 1'b1;                 // Always enable LTSSM to bring up the Link

  assign cfg_ext_read_data                   = 32'h0;                // Do not provide cfg data externally
  assign cfg_ext_read_data_valid             = 1'b0;                 // Disable external implemented reg cfg read

  assign cfg_interrupt_pending               = 2'h0;
  assign cfg_interrupt_msi_select            = 4'h0;
  assign cfg_interrupt_msi_pending_status    = 64'h0;

  assign cfg_interrupt_msi_attr              = 3'h0;
  assign cfg_interrupt_msi_tph_present       = 1'b0;
  assign cfg_interrupt_msi_tph_type          = 2'h0;
  assign cfg_interrupt_msi_tph_st_tag        = 9'h0;
  assign cfg_interrupt_msi_function_number   = 3'h0;

  assign cfg_config_space_enable             = 1'b1;
  assign cfg_req_pm_transition_l23_ready     = 1'b0;

  assign cfg_hot_reset_out                   = 1'b0;

  assign cfg_ds_port_number                  = 8'h0;
  assign cfg_ds_bus_number                   = 8'h0;
  assign cfg_ds_device_number                = 5'h0;
  assign cfg_ds_function_number              = 3'h0;
/*
  assign drp_clk                             = user_clk;
  assign drp_en                              = 1'b0;
  assign drp_we                              = 1'b0;
  assign drp_addr                            = 11'h0;
  assign drp_di                              = 16'h0;
*/

  assign m_axis_cq_tready                    = m_axis_cq_tready_bit;
  assign m_axis_rc_tready                    = m_axis_rc_tready_bit;
  
  assign engine_reset_n   = user_lnk_up && !user_reset;
  
  assign cfg_msg_transmit           = 1'b0;
  assign cfg_msg_transmit_type      = 3'h0;
  assign cfg_msg_transmit_data      = 32'h00000000;
  assign cfg_interrupt_msix_data    = 32'h00000000;
  assign cfg_fc_sel                 = 3'h0;
  assign cfg_power_state_change_ack = 1'b0;
  assign cfg_interrupt_int          = 4'h0;
  assign cfg_interrupt_msix_address = 64'h0;
  assign cfg_interrupt_msix_int     = 1'b0;
  assign cfg_interrupt_msi_int[31:1]= 31'd0;
	
reg                       [1:0]     cfg_flr_done_reg0;
reg                       [5:0]     cfg_vf_flr_done_reg0;
reg                       [1:0]     cfg_flr_done_reg1;
reg                       [5:0]     cfg_vf_flr_done_reg1;


assign user_sys_dma_en_o  = user1_sys_strm_en;
assign sys_user_dma_en_o  = user_str1_en;

assign user_reset_o = system_soft_reset;


always @(posedge pcie_core_clk)
  begin
   if (user_reset) begin
      cfg_flr_done_reg0       <= 2'b0;
      cfg_vf_flr_done_reg0    <= 6'b0;
      cfg_flr_done_reg1       <= 2'b0;
      cfg_vf_flr_done_reg1    <= 6'b0;
    end
   else begin
      cfg_flr_done_reg0       <= cfg_flr_in_process;
      cfg_vf_flr_done_reg0    <= cfg_vf_flr_in_process;
      cfg_flr_done_reg1       <= cfg_flr_done_reg0;
      cfg_vf_flr_done_reg1    <= cfg_vf_flr_done_reg0;
    end
  end


assign cfg_flr_done[0] = ~cfg_flr_done_reg1[0] && cfg_flr_done_reg0[0]; assign cfg_flr_done[1] = ~cfg_flr_done_reg1[1] && cfg_flr_done_reg0[1];

assign cfg_vf_flr_done[0] = ~cfg_vf_flr_done_reg1[0] && cfg_vf_flr_done_reg0[0]; assign cfg_vf_flr_done[1] = ~cfg_vf_flr_done_reg1[1] && cfg_vf_flr_done_reg0[1]; assign cfg_vf_flr_done[2] = ~cfg_vf_flr_done_reg1[2] && cfg_vf_flr_done_reg0[2]; assign cfg_vf_flr_done[3] = ~cfg_vf_flr_done_reg1[3] && cfg_vf_flr_done_reg0[3]; assign cfg_vf_flr_done[4] = ~cfg_vf_flr_done_reg1[4] && cfg_vf_flr_done_reg0[4]; assign cfg_vf_flr_done[5] = ~cfg_vf_flr_done_reg1[5] && cfg_vf_flr_done_reg0[5];

wire [1:0]        addr_type;
wire [2:0]        req_tc;                        // Memory Read TC
wire [2:0]        req_attr;                      // Memory Read Attribute
wire [10:0]       req_len;                       // Memory Read Length (1DW)
wire [15:0]       req_rid;                       // Memory Read Requestor ID
wire [7:0]        req_tag;                       // Memory Read Tag
wire [6:0]        req_addr;                      // Memory Read Address
wire [31:0]       reg_data;                      // Write data to register
wire [9:0]        reg_addr;                      // Register address
wire [7:0]        cpld_tag;
wire [9:0]        fpga_reg_addr;
wire [31:0]       fpga_reg_data;
wire [31:0]       fpga_reg_value;
wire [255:0]      rcvd_data;
wire  [12:0]      sys_user1_dma_req_len;
wire  [12:0]      sys_user_dma_req_len;
wire  [31:0]      dma_len;
wire [255:0]      user_str1_data;
wire [31:0]       user1_sys_dma_wr_addr;
wire [31:0]       user_str1_dma_addr;
wire [31:0]       user_str1_dma_len;
wire [31:0]       sys_user_dma_rd_addr;
wire [7:0]        sys_user1_dma_tag;
wire [7:0]        sys_user_dma_tag;
wire [31:0]       user_sys_wr_addr;
wire [255:0]      user_sys_data;
wire [4:0]        user_sys_data_len;
wire [31:0]       user_str1_wr_addr;
wire [4:0]        user_str1_data_len;
wire [7:0]        dma_rd_tag;
wire [31:0]       user1_sys_stream_len;
wire [31:0]       sys_user1_dma_rd_addr;
wire              sys_user1_dma_req_done;
wire              user_str1_data_rd;
wire              user_str1_wr_ack;
wire              sys_user1_dma_req;
wire              user_str1_data_avail;
wire       [1:0]  user_clk_sel;
wire              sys_user_dma_req;
wire              sys_user_dma_req_done;
wire              user_sys_data_avail;
wire              user_sys_data_rd;
wire              user_sys_sream_done;
wire              config_rd_req;
wire       [31:0] config_rd_req_addr;
wire       [12:0] config_rd_req_len; 
wire              config_rd_req_ack;
wire       [7:0]  config_req_tag;
wire       [31:0] config_src_addr;
wire       [31:0] config_len;
wire              config_strm_en;
wire              config_done;
wire              config_done_ack;
wire              user_clk_swch;
wire      [31:0]  sys_user1_dma_addr;
wire      [31:0]  user1_sys_dma_addr;


// Instantiate the module
rx_engine #(
    .C_DATA_WIDTH(C_DATA_WIDTH),                                    // RX interface data width
	.KEEP_WIDTH(C_DATA_WIDTH/32)
	)
    rx_engine (
    .clk_i(pcie_core_clk), 
    .rst_n(engine_reset_n), 
    // AXIS RX
    .m_axis_cq_tdata(m_axis_cq_tdata), 
    .m_axis_cq_tlast(m_axis_cq_tlast), 
    .m_axis_cq_tvalid(m_axis_cq_tvalid), 
    .m_axis_cq_tuser(m_axis_cq_tuser), 
    .m_axis_cq_tkeep(m_axis_cq_tkeep), 
    .m_axis_cq_tready(m_axis_cq_tready_bit), 
    .pcie_cq_np_req(pcie_cq_np_req), 
    .m_axis_rc_tdata(m_axis_rc_tdata), 
    .m_axis_rc_tlast(m_axis_rc_tlast), 
    .m_axis_rc_tvalid(m_axis_rc_tvalid), 
    .m_axis_rc_tkeep(m_axis_rc_tkeep), 
    .m_axis_rc_tuser(m_axis_rc_tuser), 
    .m_axis_rc_tready(m_axis_rc_tready_bit), 
    //Tx engine
    .compl_done_i(compl_done),
    .req_compl_wd_o(req_compl_wd),
    .addr_type_o(addr_type),       
    .tx_reg_data_o(reg_data),
    .req_tc_o(req_tc),       
    .req_attr_o(req_attr),
    .req_len_o(req_len),
    .req_rid_o(req_rid),
    .req_tag_o(req_tag),                 
    .req_addr_o(req_addr),   
    //Register file
    .reg_data_o(fpga_reg_data),
    .reg_data_valid_o(fpga_reg_data_valid),
    .reg_addr_o(fpga_reg_addr),
    .fpga_reg_wr_ack_i(fpga_reg_wr_ack),   
    .fpga_reg_rd_o(fpga_reg_rd),
    .reg_data_i(fpga_reg_value),
    .fpga_reg_rd_ack_i(fpga_reg_rd_ack),
    .cpld_tag_o(cpld_tag),
    //user /if
    .user_data_o(user_data_o), 
    .user_wr_req_o(user_wr_req_o),
    .user_wr_ack_i(user_wr_ack_i),
    .user_data_i(user_data_i),
    .user_rd_ack_i(user_rd_ack_i), 
    .user_rd_req_o(user_rd_req_o),	
    //Stream   
    .rcvd_data_o(rcvd_data),
    .rcvd_data_valid_o(rcvd_data_valid) 
 );

  //
  // Register file
  //

  reg_file reg_file (
    .clk_i(pcie_core_clk),
    .rst_n(engine_reset_n), 
    .system_soft_reset_o(system_soft_reset),
    //Rx engine
    .addr_i(fpga_reg_addr), 
    .data_i(fpga_reg_data), 
    .data_valid_i(fpga_reg_data_valid), 
    .fpga_reg_wr_ack_o(fpga_reg_wr_ack),
    .fpga_reg_rd_i(fpga_reg_rd),
    .fpga_reg_rd_ack_o(fpga_reg_rd_ack),
    .data_o(fpga_reg_value),
    //User stream controllers
    //1 
    .o_user_str1_en(user_str1_en),
    .i_user_str1_done(user_str1_done),
    .o_user_str1_done_ack(user_str1_done_ack),
    .o_user_str1_dma_addr(user_str1_dma_addr),
    .o_user_str1_dma_len(user_str1_dma_len), 
    .user1_sys_strm_en_o(user1_sys_strm_en),
    .user1_sys_dma_wr_addr_o(user1_sys_dma_wr_addr), 
    .user1_sys_stream_len_o(user1_sys_stream_len), 
    .user1_sys_strm_done_i(user1_sys_strm_done),
    .user1_sys_strm_done_ack_o(user1_sys_strm_done_ack), 
    .o_sys_user1_dma_addr(sys_user1_dma_addr),
    .o_user1_sys_dma_addr(user1_sys_dma_addr), 
    //reconfig
    .i_icap_clk(icap_clk_i),
    .o_conf_addr(config_src_addr),
    .o_conf_len(config_len),
    .o_conf_req(config_strm_en),
    .i_config_done(config_done),
    .o_conf_done_ack(config_done_ack),
     //clock
    .user_clk_swch_o(user_clk_swch),
    .user_clk_sel_o(user_clk_sel),
    //interrupt
    .intr_req_o(intr_req),
    .intr_req_done_i(intr_done),
    .user_intr_req_i(user_intr_req_i),
    .user_intr_ack_o(user_intr_ack_o),
    //Misc
    .user_reset_o(),///////////////
    .user_addr_o(user_addr_o),
    //Link status
    .i_pcie_link_stat(user_lnk_up)
  );  
  
   
  //
  //Transmit Controller
  //

tx_engine 
     #(
    // TX interface data width
    .C_DATA_WIDTH(C_DATA_WIDTH),
    .KEEP_WIDTH(C_DATA_WIDTH/32)
    )
    tx_engine 
(
    .clk_i(pcie_core_clk), 
    .rst_n(engine_reset_n), 
    // AXIS Tx
    .s_axis_cc_tdata(s_axis_cc_tdata), 
    .s_axis_cc_tkeep(s_axis_cc_tkeep), 
    .s_axis_cc_tlast(s_axis_cc_tlast), 
    .s_axis_cc_tvalid(s_axis_cc_tvalid), 
    .s_axis_cc_tuser(s_axis_cc_tuser), 
    .s_axis_cc_tready(s_axis_cc_tready[0]), 
    .s_axis_rq_tdata(s_axis_rq_tdata), 
    .s_axis_rq_tkeep(s_axis_rq_tkeep), 
    .s_axis_rq_tlast(s_axis_rq_tlast), 
    .s_axis_rq_tvalid(s_axis_rq_tvalid), 
    .s_axis_rq_tuser(s_axis_rq_tuser), 
    .s_axis_rq_tready(s_axis_rq_tready[0]), 
    //Rx engine
    .req_compl_wd_i(req_compl_wd),
    .addr_type_i(addr_type),
    .compl_done_o(compl_done),
    .req_tc_i(req_tc),
    .req_attr_i(req_attr),
    .req_len_i(req_len),
    .req_rid_i(req_rid),
    .req_tag_i(req_tag),
    .req_addr_i(req_addr),
    .reg_data_i(reg_data),
    //config control
    .config_dma_req_i(config_rd_req),
    .config_dma_rd_addr_i(config_rd_req_addr),
    .config_dma_req_len_i(config_rd_req_len),
    .config_dma_req_done_o(config_rd_req_ack),
    .config_dma_req_tag_i(config_req_tag), 
    //DRA 
    .sys_user_dma_req_i(sys_user_dma_req),
    .sys_user_dma_req_done_o(sys_user_dma_req_done),
    .sys_user_dma_req_len_i(sys_user_dma_req_len),
    .sys_user_dma_rd_addr_i(sys_user_dma_rd_addr),
    .sys_user_dma_tag_i(sys_user_dma_tag),
    //User stream interface
    .user_str_data_avail_i(user_sys_data_avail),
    .user_sys_dma_wr_addr_i(user_sys_wr_addr),
    .user_str_data_rd_o(user_sys_data_rd),
    .user_str_data_i(user_sys_data),
    .user_str_len_i(user_sys_data_len),
    .user_str_dma_done_o(user_sys_sream_done),
    //Interrupt
    .intr_req_i(intr_req),
    .intr_req_done_o(intr_done),
    .cfg_interrupt_o(cfg_interrupt_msi_int[0]),
    .cfg_interrupt_rdy_i(cfg_interrupt_msi_sent)
);
  
  user_pcie_stream_generator
  #(
  .TAG1(8'd1),
  .TAG2(8'd2)
  )
  psg1
  (
    .clk_i(pcie_core_clk),
    .rst_n(system_soft_reset),
    .sys_user_strm_en_i(user_str1_en),
    .user_sys_strm_en_i(user1_sys_strm_en),
    .dma_done_o(user_str1_done),
    .dma_done_ack_i(user_str1_done_ack),
    .dma_rd_req_o(sys_user1_dma_req),
    .dma_req_ack_i(sys_user1_dma_req_done),
    .dma_rd_req_len_o(sys_user1_dma_req_len),
    .dma_rd_req_addr_o(sys_user1_dma_rd_addr),
    .dma_src_addr_i(user_str1_dma_addr),
    .dma_len_i(user_str1_dma_len),
    .sys_user_dma_addr_i(sys_user1_dma_addr),
    .user_sys_dma_addr_i(user1_sys_dma_addr),
    .dma_tag_i(cpld_tag),
    .dma_data_valid_i(rcvd_data_valid),
    .dma_data_i(rcvd_data),
    .dma_tag_o(sys_user1_dma_tag),
    .stream_len_i(user1_sys_stream_len), 
    .user_sys_strm_done_o(user1_sys_strm_done), 
    .user_sys_strm_done_ack(user1_sys_strm_done_ack),
    .dma_wr_start_addr_i(user1_sys_dma_wr_addr),
	 
    .stream_data_valid_o(user_str_data_valid_o),
    .stream_data_ready_i(user_str_ack_i),
    .stream_data_o(user_str_data_o),
    .sys_user_dma_addr_o(sys_user_dma_addr_o),
    .sys_user_dma_len_o(sys_user_dma_len_o),
	 
    .stream_data_valid_i(user_str_data_valid_i),
    .stream_data_ready_o(user_str_ack_o),
    .stream_data_i(user_str_data_i), 
    .user_sys_dma_addr_o(user_sys_dma_addr_o),
    .user_sys_dma_len_o(user_sys_dma_len_o),
	 
    .user_stream_data_avail_o(user_str1_data_avail), 
    .user_stream_data_rd_i(user_str1_data_rd),
    .user_stream_data_o(user_str1_data),
    .user_stream_data_len_o(user_str1_data_len),
    .user_stream_wr_addr_o(user_str1_wr_addr),
    .user_stream_wr_ack_i(user_str1_wr_ack)
  );
  
   user_dma_req_arbitrator #(
    .NUM_SLAVES(NUM_PCIE_STRM)
    )
   dra
   (
    .i_clk(pcie_core_clk),
    .i_rst_n(system_soft_reset),
    //To PSG slaves
    .i_slave_dma_req(sys_user1_dma_req),
    .i_slave_dma_addr(sys_user1_dma_rd_addr),
    .i_slave_dma_len(sys_user1_dma_req_len),
    .i_slave_dma_tag(sys_user1_dma_tag),
    .o_slave_dma_ack(sys_user1_dma_req_done), 
    .i_slave_dma_data_avail(user_str1_data_avail),
    .i_slave_dma_wr_addr(user_str1_wr_addr),
    .o_slave_dma_data_rd(user_str1_data_rd),
    .i_slave_dma_data(user_str1_data),
    .i_slave_dma_wr_len(user_str1_data_len),
    .o_slave_dma_done(user_str1_wr_ack),
    //To PCIe Tx engine
    .o_dma_req(sys_user_dma_req),
    .i_dma_ack(sys_user_dma_req_done),
    .o_dma_req_addr(sys_user_dma_rd_addr),
    .o_dma_req_len(sys_user_dma_req_len),
    .o_dma_req_tag(sys_user_dma_tag),
    //
    .o_dma_data_avail(user_sys_data_avail),
    .o_dma_wr_addr(user_sys_wr_addr),
    .i_dma_data_rd(user_sys_data_rd),
    .o_dma_data(user_sys_data),
    .o_dma_len(user_sys_data_len),
    .i_dma_done(user_sys_sream_done)
    );

assign user_clk_o = pcie_core_clk;
  
  //--------------------------------------------------------------------------------------------------------------------//
  // CFG_WRITE : Description : Write Configuration Space MI decode error, Disabling LFSR update from SKP. CR# 
  //--------------------------------------------------------------------------------------------------------------------//
    reg write_cfg_done_1;
      always @(posedge pcie_core_clk) begin : cfg_write_skp_nolfsr 
        if (user_reset) begin
            cfg_mgmt_addr        <=  32'b0;
            cfg_mgmt_write_data  <=  32'b0;
            cfg_mgmt_byte_enable <=  4'b0;
            cfg_mgmt_write       <=  1'b0;
            cfg_mgmt_read        <=  1'b0;
            write_cfg_done_1     <=  1'b0; end
        else begin
          if (cfg_mgmt_read_write_done == 1'b1 && write_cfg_done_1 == 1'b1) begin
              cfg_mgmt_addr        <= 0;
              cfg_mgmt_write_data  <= 0;
              cfg_mgmt_byte_enable <= 0;
              cfg_mgmt_write       <= 0;
              cfg_mgmt_read        <= 0;  end
          else if (cfg_mgmt_read_write_done == 1'b1 && write_cfg_done_1 == 1'b0) begin
              cfg_mgmt_addr        <= 32'h40082;
              cfg_mgmt_write_data[31:28] <= cfg_mgmt_read_data[31:28];
              cfg_mgmt_write_data[27]    <= 1'b1; 
              cfg_mgmt_write_data[26:0]  <= cfg_mgmt_read_data[26:0];
              cfg_mgmt_byte_enable <= 4'hF;
              cfg_mgmt_write       <= 1'b1;
              cfg_mgmt_read        <= 1'b0;  
              write_cfg_done_1     <= 1'b1; end
          else if (write_cfg_done_1 == 1'b0) begin
              cfg_mgmt_addr        <= 32'h40082;
              cfg_mgmt_write_data  <= 32'b0;
              cfg_mgmt_byte_enable <= 4'hF;
              cfg_mgmt_write       <= 1'b0;
              cfg_mgmt_read        <= 1'b1;  end
          end
      end

endmodule
