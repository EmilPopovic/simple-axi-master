`timescale 1ns / 1ps

module simple_axi_master_wrapper #(
    parameter integer C_HOST_DATA_WIDTH = 32
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
    input  wire [C_HOST_DATA_WIDTH-1:0] i_wdata,
    output wire [C_HOST_DATA_WIDTH-1:0] o_rdata,
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
    input  wire [1:0]  m_axi_rresp
);

    wire [63:0] w_wrapped_wdata;
    wire [63:0] w_wrapped_rdata;

    generate
        if (C_HOST_DATA_WIDTH == 32) begin
            assign w_wrapped_wdata = {32'b0, i_wdata};
            assign o_rdata = w_wrapped_rdata[31:0];
        end else begin
            assign w_wrapped_wdata = i_wdata;
            assign o_rdata = w_wrapped_rdata;
        end
    endgenerate

simple_axi_master simple_axi_master (
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
    .m_axi_rvalid   (m_axi_rvalid),
    .m_axi_rready   (m_axi_rready),
    .m_axi_rlast    (m_axi_rlast),
    .m_axi_rdata    (m_axi_rdata),
    .m_axi_rresp    (m_axi_rresp)
);

endmodule
