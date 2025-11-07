`timescale 1ns / 1ps

`define RW_NOP   2'b00
`define RW_WRITE 2'b01
`define RW_READ  2'b10

`define RESP_OKAY   2'b00
`define RESP_EXOKAY 2'b01
`define RESP_SLVERR 2'b10
`define RESP_DECERR 2'b11

`define SIZE_BYTE  3'b000
`define SIZE_HALF  3'b001
`define SIZE_WORD  3'b010
`define SIZE_DWORD 3'b011

module simple_axi_master(
    input  wire        i_clk,  // Global clock
    input  wire        i_rst,  // Global reset

    // Internal bus side
    input  wire [2:0]  i_size,        // 0-byte, 1-half, 2-word, 3-dword
    input  wire [31:0] i_addr,        // Address bus
    input  wire [63:0] i_wdata,       // Write data bus
    output reg  [63:0] o_rdata,       // Read data bus
    input  wire [1:0]  i_rw,          // 00-idle, 01-write, 10-read, 11-reserved
    output reg         o_wait,        // Transfer active
    output reg         o_done,        // 1 after completing transfer
    input  wire        i_clear_done,  // Clear done status (sets done to 0)
    output reg         o_invalid,     // Requested invalid address
    output reg         o_error,       // AXI returned error

    // Write Address (AW) channel signals
    output reg         m_axi_awvalid,
    input  wire        m_axi_awready,
    output wire [31:0] m_axi_awaddr,
    output wire [2:0]  m_axi_awsize,
    output wire [1:0]  m_axi_awburst,
    output wire [3:0]  m_axi_awcache,
    output wire [2:0]  m_axi_awprot,
    output wire [7:0]  m_axi_awlen,
    output wire        m_axi_awlock,
    output wire [3:0]  m_axi_awqos,

    // Write Data (W) channel signals
    output reg         m_axi_wvalid,
    input  wire        m_axi_wready,
    output reg         m_axi_wlast,
    output wire [63:0] m_axi_wdata,
    output reg  [7:0]  m_axi_wstrb,

    // Write Response (B) channel signals
    input  wire        m_axi_bvalid,
    output reg         m_axi_bready,
    input  wire [1:0]  m_axi_bresp,

    // Read Address (AR) channel signals
    output reg         m_axi_arvalid,
    input  wire        m_axi_arready,
    output wire [31:0] m_axi_araddr,
    output wire [2:0]  m_axi_arsize,
    output wire [1:0]  m_axi_arburst,
    output wire [3:0]  m_axi_arcache,
    output wire [2:0]  m_axi_arprot,
    output wire [7:0]  m_axi_arlen,
    output wire        m_axi_arlock,
    output wire [3:0]  m_axi_arqos,

    // Read Data (R) channel signals
    input  wire        m_axi_rvalid,
    output reg         m_axi_rready,
    input  wire        m_axi_rlast,
    input  wire [63:0] m_axi_rdata,
    input  wire [1:0]  m_axi_rresp
);
    // States
    localparam S_IDLE             = 4'b0000;  // No active transaction
    localparam S_IDLE_DONE        = 4'b0001;  // Idle with done flag set
    localparam S_W_SET_ADDR       = 4'b0010;  // Set write address
    localparam S_W_ADDR_WAIT_RDY  = 4'b0011;  // Wait for write address received
    localparam S_W_SET_DATA_LAST  = 4'b0100;  // Send last data
    localparam S_W_RET            = 4'b0101;  // Return write response
    localparam S_R_SET_ADDR       = 4'b0110;  // Set read address
    localparam S_R_ADDR_WAIT_RDY  = 4'b0111;  // Wait for read address received
    localparam S_R_READ_DATA_LAST = 4'b1000;  // Read last data and return

    // Internal registers
    reg [3:0]  r_state;
    reg [3:0]  r_next_state;
    reg [31:0] r_addr;
    reg [63:0] r_wdata;
    reg [2:0]  r_size;
    reg [1:0]  r_rw;

    wire [2:0] byte_offset = r_addr[2:0];

    wire [63:0] size_mask;
    assign size_mask = (r_size == `SIZE_BYTE) ? 64'h00000000_000000FF :
                       (r_size == `SIZE_HALF) ? 64'h00000000_0000FFFF :
                       (r_size == `SIZE_WORD) ? 64'h00000000_FFFFFFFF :
                                                64'hFFFFFFFF_FFFFFFFF;

    // AXI constants
    assign m_axi_awaddr  = r_addr;
    assign m_axi_awsize  = r_size;
    assign m_axi_awburst = 2'b01;    // INCR
    assign m_axi_awcache = 4'b0011;  // Bufferable
    assign m_axi_awprot  = 3'b000;   // Unprivileged
    assign m_axi_awlen   = 8'h0;     // Single beat
    assign m_axi_awlock  = 1'b0;     // Normal
    assign m_axi_awqos   = 4'h0;     // No QoS

    assign m_axi_wdata   = r_wdata << (byte_offset * 8);

    assign m_axi_araddr  = r_addr;
    assign m_axi_arsize  = r_size;
    assign m_axi_arburst = 2'b01;    // INCR
    assign m_axi_arcache = 4'b0011;  // Bufferable
    assign m_axi_arprot  = 3'b000;   // Unprivileged
    assign m_axi_arlen   = 8'h0;     // Single beat
    assign m_axi_arlock  = 1'b0;     // Normal
    assign m_axi_arqos   = 4'h0;     // No QoS

    // Strobe calculation
    always @(*) begin
        case(i_size)
            `SIZE_BYTE:  m_axi_wstrb = 8'b0000_0001 << (byte_offset);  // 1 byte
            `SIZE_HALF:  m_axi_wstrb = 8'b0000_0011 << (byte_offset);  // 2 bytes
            `SIZE_WORD:  m_axi_wstrb = 8'b0000_1111 << (byte_offset);  // 4 bytes
            `SIZE_DWORD: m_axi_wstrb = 8'b1111_1111;                   // 8 bytes
            default:     m_axi_wstrb = 8'b0000_0000;
        endcase
    end

    // Sequential logic
    always @(posedge i_clk) begin
        if (i_rst) begin
            r_state <= S_IDLE;
            r_addr  <= 32'b0;
            r_wdata <= 64'b0;
            r_size  <= 2'b0;
            r_rw    <= 2'b00;
            o_rdata <= 64'b0;
        end else begin
            r_state <= r_next_state;

            if ((r_state == S_IDLE || r_state == S_IDLE_DONE) && i_rw != `RW_NOP) begin
                r_addr  <= i_addr;
                r_wdata <= i_wdata;
                r_size  <= i_size;
                r_rw    <= i_rw;
            end

            if (r_state == S_R_READ_DATA_LAST && m_axi_rvalid) begin
                o_rdata <= m_axi_rdata >> (byte_offset * 8) & size_mask;
            end
        end
    end

    // Combinatorial logic
    always @(*) begin
        r_next_state  = r_state;
        m_axi_awvalid = 1'b0;
        m_axi_wvalid  = 1'b0;
        m_axi_wlast   = 1'b0;
        m_axi_bready  = 1'b0;
        m_axi_arvalid = 1'b0;
        m_axi_rready  = 1'b0;
        o_done        = 1'b0;
        o_wait        = 1'b0;
        o_error       = 1'b0;
        o_invalid     = 1'b0;

        case (r_state)

        // Idle states
        S_IDLE: begin
            case (i_rw)

            `RW_WRITE: begin
                r_next_state = S_W_SET_ADDR;
                o_wait = 1'b1;
            end

            `RW_READ: begin
                r_next_state = S_R_SET_ADDR;
                o_wait = 1'b1;
            end

            default: begin
                r_next_state = S_IDLE;
                o_wait = 1'b0;
            end

            endcase
        end

        S_IDLE_DONE: begin
            case (i_rw)

            `RW_WRITE: begin
                r_next_state = S_W_SET_ADDR;
                o_wait = 1'b1;
            end

            `RW_READ: begin
                r_next_state = S_R_SET_ADDR;
                o_wait = 1'b1;
            end

            default: begin
                o_wait = 1'b0;
                if (i_clear_done) begin
                    r_next_state = S_IDLE;
                    o_done = 1'b0;
                end else begin
                    r_next_state = S_IDLE_DONE;
                    o_done = 1'b1;
                end
            end

            endcase
        end

        // Write path
        S_W_SET_ADDR: begin
            r_next_state  = S_W_ADDR_WAIT_RDY;
            m_axi_awvalid = 1'b1;
            o_wait = 1'b1;
        end

        S_W_ADDR_WAIT_RDY: begin
            o_wait = 1'b1;
            m_axi_awvalid = 1'b1;

            if (m_axi_awready) begin
                r_next_state = S_W_SET_DATA_LAST;
            end
        end

        S_W_SET_DATA_LAST: begin
            o_wait = 1'b1;
            m_axi_wvalid = 1'b1;

            if (m_axi_wready) begin
               r_next_state = S_W_RET;
               m_axi_wlast  = 1'b1;
            end
        end

        S_W_RET: begin
            o_wait = 1'b1;
            m_axi_bready = 1'b1;

            if (m_axi_bvalid) begin
                if (i_clear_done) begin
                    r_next_state = S_IDLE;
                end else begin
                    r_next_state = S_IDLE_DONE;
                end

                o_wait = 1'b0;
                o_done = 1'b1;

                o_error   = (m_axi_bresp != `RESP_OKAY);
                o_invalid = (m_axi_bresp == `RESP_DECERR);
            end
        end

        // Read path
        S_R_SET_ADDR: begin
            r_next_state  = S_R_ADDR_WAIT_RDY;
            m_axi_arvalid = 1'b1;
            o_wait = 1'b1;
        end

        S_R_ADDR_WAIT_RDY: begin
            o_wait = 1'b1;
            m_axi_arvalid = 1'b1;

            if (m_axi_arready) begin
                r_next_state = S_R_READ_DATA_LAST;
            end
        end

        S_R_READ_DATA_LAST: begin
            o_wait = 1'b1;
            m_axi_rready = 1'b1;

            if (m_axi_rvalid) begin
                if (i_clear_done) begin
                    r_next_state = S_IDLE;
                end else begin
                    r_next_state = S_IDLE_DONE;
                end

                o_wait = 1'b0;
                o_done = 1'b1;

                o_error   = (m_axi_rresp != `RESP_OKAY);
                o_invalid = (m_axi_rresp == `RESP_DECERR);
            end
        end

        default: r_next_state = S_IDLE;

        endcase
    end
endmodule
