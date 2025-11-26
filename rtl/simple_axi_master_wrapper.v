`timescale 1ns / 1ps

module simple_axi_master_wrapper #(
    parameter integer HOST_DATA_WIDTH = 32,
    parameter integer DEBUG = 0
) (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 i_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF m_axi, ASSOCIATED_RESET i_rstn" *)
    input  wire        i_clk,
    
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 i_rstn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input  wire        i_rstn,

    // Host bus
    input  wire [2:0]  i_size,
    input  wire [31:0] i_addr,
    input  wire [HOST_DATA_WIDTH-1:0] i_wdata,
    output wire [HOST_DATA_WIDTH-1:0] o_rdata,
    input  wire [1:0]  i_rw,
    output wire        o_wait,
    input  wire        i_clear,
    output wire        o_done,
    output wire        o_error,
    output wire        o_invalid,

    // AXI4 Master Write Address Channel
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWVALID" *)
    output wire        m_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWREADY" *)
    input  wire        m_axi_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWADDR" *)
    output wire [31:0] m_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWSIZE" *)
    output wire [2:0]  m_axi_awsize,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWCACHE" *)
    output wire [3:0]  m_axi_awcache,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWPROT" *)
    output wire [2:0]  m_axi_awprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWBURST" *)
    output wire [1:0]  m_axi_awburst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWLEN" *)
    output wire [7:0]  m_axi_awlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWLOCK" *)
    output wire        m_axi_awlock,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWQOS" *)
    output wire [3:0]  m_axi_awqos,

    // AXI4 Master Write Data Channel
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WVALID" *)
    output wire        m_axi_wvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WREADY" *)
    input  wire        m_axi_wready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WLAST" *)
    output wire        m_axi_wlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WDATA" *)
    output wire [63:0] m_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WSTRB" *)
    output wire [7:0]  m_axi_wstrb,

    // AXI4 Master Write Response Channel
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BVALID" *)
    input  wire        m_axi_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BREADY" *)
    output wire        m_axi_bready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BRESP" *)
    input  wire [1:0]  m_axi_bresp,

    // AXI4 Master Read Address Channel
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARVALID" *)
    output wire        m_axi_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARREADY" *)
    input  wire        m_axi_arready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARADDR" *)
    output wire [31:0] m_axi_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARSIZE" *)
    output wire [2:0]  m_axi_arsize,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARCACHE" *)
    output wire [3:0]  m_axi_arcache,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARPROT" *)
    output wire [2:0]  m_axi_arprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARBURST" *)
    output wire [1:0]  m_axi_arburst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARLEN" *)
    output wire [7:0]  m_axi_arlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARLOCK" *)
    output wire        m_axi_arlock,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARQOS" *)
    output wire [3:0]  m_axi_arqos,

    // AXI4 Master Read Data Channel
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RVALID" *)
    input  wire        m_axi_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RREADY" *)
    output wire        m_axi_rready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RLAST" *)
    input  wire        m_axi_rlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RDATA" *)
    input  wire [63:0] m_axi_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RRESP" *)
    input  wire [1:0]  m_axi_rresp,

    // Debug signals
    output wire [3:0]  o_debug_state,
    output wire [31:0] o_debug_latency
);

generate
    if (DEBUG == 0) begin : gen_no_debug
        assign o_debug_state = 4'b0;
        assign o_debug_latency = 32'b0;
    end
endgenerate

    wire [63:0] w_wrapped_wdata;
    wire [63:0] w_wrapped_rdata;

    generate
        if (HOST_DATA_WIDTH == 32) begin
            assign w_wrapped_wdata = {32'b0, i_wdata};
            assign o_rdata = w_wrapped_rdata[31:0];
        end else begin
            assign w_wrapped_wdata = i_wdata;
            assign o_rdata = w_wrapped_rdata;
        end
    endgenerate

simple_axi_master #(
    .DEBUG(DEBUG)
) simple_axi_master (
    .i_clk          (i_clk),
    .i_rstn         (i_rstn),
    .i_size         (i_size),
    .i_addr         (i_addr),
    .i_wdata        (w_wrapped_wdata),
    .o_rdata        (w_wrapped_rdata),
    .i_rw           (i_rw),
    .o_wait         (o_wait),
    .i_clear        (i_clear),
    .o_done         (o_done),
    .o_error        (o_error),
    .o_invalid      (o_invalid),
    .m_axi_awvalid  (m_axi_awvalid),
    .m_axi_awready  (m_axi_awready),
    .m_axi_awaddr   (m_axi_awaddr),
    .m_axi_awsize   (m_axi_awsize),
    .m_axi_awcache  (m_axi_awcache),
    .m_axi_awprot   (m_axi_awprot),
    .m_axi_awburst  (m_axi_awburst),
    .m_axi_awlen    (m_axi_awlen),
    .m_axi_awlock   (m_axi_awlock),
    .m_axi_awqos    (m_axi_awqos),
    .m_axi_wvalid   (m_axi_wvalid),
    .m_axi_wready   (m_axi_wready),
    .m_axi_wlast    (m_axi_wlast),
    .m_axi_wdata    (m_axi_wdata),
    .m_axi_wstrb    (m_axi_wstrb),
    .m_axi_bvalid   (m_axi_bvalid),
    .m_axi_bready   (m_axi_bready),
    .m_axi_bresp    (m_axi_bresp),
    .m_axi_arvalid  (m_axi_arvalid),
    .m_axi_arready  (m_axi_arready),
    .m_axi_araddr   (m_axi_araddr),
    .m_axi_arsize   (m_axi_arsize),
    .m_axi_arcache  (m_axi_arcache),
    .m_axi_arprot   (m_axi_arprot),
    .m_axi_arburst  (m_axi_arburst),
    .m_axi_arlen    (m_axi_arlen),
    .m_axi_arlock   (m_axi_arlock),
    .m_axi_arqos    (m_axi_arqos),
    .m_axi_rvalid   (m_axi_rvalid),
    .m_axi_rready   (m_axi_rready),
    .m_axi_rlast    (m_axi_rlast),
    .m_axi_rdata    (m_axi_rdata),
    .m_axi_rresp    (m_axi_rresp),
    .o_debug_state  (o_debug_state),
    .o_debug_latency(o_debug_latency)
);

endmodule
