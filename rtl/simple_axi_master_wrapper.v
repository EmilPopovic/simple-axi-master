`timescale 1ns / 1ps

module simple_axi_master_wrapper(
    input  wire        i_clk,
    input  wire        i_rst,

    input  wire [2:0]  i_size,     // 0-byte, 1-half, 2-word, 3-dword
    input  wire [31:0] i_addr,     // Address bus
    input  wire [63:0] i_wdata,    // Write data bus
    output wire [63:0] o_rdata,    // Read data bus
    input  wire [1:0]  i_rw,       // 00-idle, 01-write, 10-read, 11-reserved
    output wire        o_wait,     // Transfer active
    input  wire        i_clear,    // Clear done, error and invalid
    output wire        o_done,     // 1 after completing transfer
    output wire        o_error,    // Transaction failed
    output wire        o_invalid,  // Requested invalid address

    output wire        m_axi_awvalid,
    input  wire        m_axi_awready,
    output wire [31:0] m_axi_awaddr,
    output wire [2:0]  m_axi_awsize,
    output wire [1:0]  m_axi_awburst,
    output wire [3:0]  m_axi_awcache,
    output wire [2:0]  m_axi_awprot,
    output wire [7:0]  m_axi_awlen,
    output wire        m_axi_awlock,
    output wire [3:0]  m_axi_awqos,
    output wire [3:0]  m_axi_awregion,
    output wire [0:0]  m_axi_awid,

    output wire        m_axi_wvalid,
    input  wire        m_axi_wready,
    output wire        m_axi_wlast,
    output wire [63:0] m_axi_wdata,
    output wire [7:0]  m_axi_wstrb,

    input  wire        m_axi_bvalid,
    output wire        m_axi_bready,
    input  wire [1:0]  m_axi_bresp,
    input  wire [0:0]  m_axi_bid,

    output wire        m_axi_arvalid,
    input  wire        m_axi_arready,
    output wire [31:0] m_axi_araddr,
    output wire [2:0]  m_axi_arsize,
    output wire [1:0]  m_axi_arburst,
    output wire [3:0]  m_axi_arcache,
    output wire [2:0]  m_axi_arprot,
    output wire [7:0]  m_axi_arlen,
    output wire        m_axi_arlock,
    output wire [3:0]  m_axi_arqos,
    output wire [3:0]  m_axi_arregion,
    output wire [0:0]  m_axi_arid,

    input  wire        m_axi_rvalid,
    output wire        m_axi_rready,
    input  wire        m_axi_rlast,
    input  wire [63:0] m_axi_rdata,
    input  wire [1:0]  m_axi_rresp,
    input  wire [0:0]  m_axi_rid
);

simple_axi_master simple_axi_master (
    .i_clk          (i_clk),
    .i_rst          (i_rst),
    .i_size         (i_size),
    .i_addr         (i_addr),
    .i_wdata        (i_wdata),
    .o_rdata        (o_rdata),
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
    .m_axi_awburst  (m_axi_awburst),
    .m_axi_awcache  (m_axi_awcache),
    .m_axi_awprot   (m_axi_awprot),
    .m_axi_awlen    (m_axi_awlen),
    .m_axi_awlock   (m_axi_awlock),
    .m_axi_awqos    (m_axi_awqos),
    .m_axi_awregion (m_axi_awregion),
    .m_axi_awid     (m_axi_awid),
    .m_axi_wvalid   (m_axi_wvalid),
    .m_axi_wready   (m_axi_wready),
    .m_axi_wlast    (m_axi_wlast),
    .m_axi_wdata    (m_axi_wdata),
    .m_axi_wstrb    (m_axi_wstrb),
    .m_axi_bvalid   (m_axi_bvalid),
    .m_axi_bready   (m_axi_bready),
    .m_axi_bresp    (m_axi_bresp),
    .m_axi_bid      (m_axi_bid),
    .m_axi_arvalid  (m_axi_arvalid),
    .m_axi_arready  (m_axi_arready),
    .m_axi_araddr   (m_axi_araddr),
    .m_axi_arsize   (m_axi_arsize),
    .m_axi_arburst  (m_axi_arburst),
    .m_axi_arcache  (m_axi_arcache),
    .m_axi_arprot   (m_axi_arprot),
    .m_axi_arlen    (m_axi_arlen),
    .m_axi_arlock   (m_axi_arlock),
    .m_axi_arqos    (m_axi_arqos),
    .m_axi_arregion (m_axi_arregion),
    .m_axi_arid     (m_axi_arid),
    .m_axi_rvalid   (m_axi_rvalid),
    .m_axi_rready   (m_axi_rready),
    .m_axi_rlast    (m_axi_rlast),
    .m_axi_rdata    (m_axi_rdata),
    .m_axi_rresp    (m_axi_rresp),
    .m_axi_rid      (m_axi_rid)
);

endmodule
