`timescale 1ns / 1ps

module simple_axi_master #(
    parameter WIDTH = 32,
    parameter DEBUG = 0
)(
    input  logic             i_clk,
    input  logic             i_rstn,

    input  logic [2:0]       i_size,    // 0-byte, 1-half, 2-word, 3-dword
    input  logic [31:0]      i_addr,    // Address bus
    input  logic [WIDTH-1:0] i_wdata,   // Write data bus
    output logic [WIDTH-1:0] o_rdata,   // Read data bus
    input  logic [1:0]       i_rw,      // 00-idle, 01-write, 10-read, 11-reserved
    output logic             o_wait,    // Transfer active
    input  logic             i_clear,   // Clear done, error and invalid
    output logic             o_done,    // 1 after completing transfer
    output logic             o_error,   // Transaction failed
    output logic             o_invalid, // Requested invalid address

    output logic             m_axi_awvalid,
    input  logic             m_axi_awready,
    output logic [31:0]      m_axi_awaddr,
    output logic [2:0]       m_axi_awsize,
    output logic [3:0]       m_axi_awcache,
    output logic [2:0]       m_axi_awprot,
    output logic [1:0]       m_axi_awburst,
    output logic [7:0]       m_axi_awlen,
    output logic             m_axi_awlock,
    output logic [3:0]       m_axi_awqos,

    output logic             m_axi_wvalid,
    input  logic             m_axi_wready,
    output logic             m_axi_wlast,
    output logic [WIDTH-1:0] m_axi_wdata,
    output logic [WIDTH/8:0] m_axi_wstrb,

    input  logic             m_axi_bvalid,
    output logic             m_axi_bready,
    input  logic [1:0]       m_axi_bresp,

    output logic             m_axi_arvalid,
    input  logic             m_axi_arready,
    output logic [31:0]      m_axi_araddr,
    output logic [2:0]       m_axi_arsize,
    output logic [3:0]       m_axi_arcache,
    output logic [2:0]       m_axi_arprot,
    output logic [1:0]       m_axi_arburst,
    output logic [7:0]       m_axi_arlen,
    output logic             m_axi_arlock,
    output logic [3:0]       m_axi_arqos,

    input  logic             m_axi_rvalid,
    output logic             m_axi_rready,
    input  logic             m_axi_rlast,
    input  logic [WIDTH-1:0] m_axi_rdata,
    input  logic [1:0]       m_axi_rresp,

    output logic [3:0]       o_debug_state,
    output logic [31:0]      o_debug_latency
);

typedef enum logic [1:0] {
    RW_NOP   = 2'b00,
    RW_WRITE = 2'b01,
    RW_READ  = 2'b10
} rw_cmd_e;

typedef enum logic [1:0] {
    RESP_OKAY   = 2'b00,
    RESP_EXOKAY = 2'b01,
    RESP_SLVERR = 2'b10,
    RESP_DECERR = 2'b11
} axi_resp_e;

typedef enum logic [2:0] {
    SIZE_BYTE  = 3'b000,
    SIZE_HALF  = 3'b001,
    SIZE_WORD  = 3'b010,
    SIZE_DWORD = 3'b011
} transfer_size_e;

typedef enum logic [3:0] {
    S_IDLE        = 4'b0000,  // No active transaction
    S_DONE        = 4'b0001,  // Idle done with no error
    S_ERROR       = 4'b0010,  // Idle done where last returned error
    S_INVALID     = 4'b0011,  // Idle done where last was invalid
    S_W_SET_ADDR  = 4'b0100,  // Set write address
    S_W_ADDR_WAIT = 4'b0101,  // Wait for write address received
    S_W_DATA_LAST = 4'b0110,  // Send last data
    S_W_RET       = 4'b0111,  // Return write response
    S_R_SET_ADDR  = 4'b1000,  // Set read address
    S_R_ADDR_WAIT = 4'b1001,  // Wait for read address received
    S_R_DATA_LAST = 4'b1010   // Read last data and return
} state_e;

// Internal registers
state_e      r_state;
state_e      r_next_state;
logic [31:0] r_addr;
logic [63:0] r_wdata;
logic [2:0]  r_size;
logic [1:0]  r_rw;
logic [63:0] r_rdata;
logic        r_timer_active;
logic [31:0] r_cycle_count;

generate
    if (DEBUG) begin : gen_debug
        assign o_debug_state = r_state;
    end else begin : gen_no_debug
        assign o_debug_state = 4'b0;
    end
endgenerate

always_ff @(posedge i_clk) begin
    if (!i_rstn || i_clear) begin
        r_timer_active  <= 0;
        r_cycle_count   <= 0;
        o_debug_latency <= 0;
    end else begin
        if (r_state < 4 && i_rw != RW_NOP) begin
            r_timer_active <= 1;
            r_cycle_count  <= 0;
        end
        else if (o_done) begin
            r_timer_active  <= 0;
            o_debug_latency <= r_cycle_count;
        end
        else begin
            r_cycle_count <= r_cycle_count + 1;
        end
    end
end

// Alignment handling
logic [WIDTH-1:0] size_mask;
logic [WIDTH/8-1:0] base_strb;
logic [$clog2(WIDTH/8)-1:0] byte_offset;
assign byte_offset = r_addr[$clog2(WIDTH/8)-1:0];
assign m_axi_wstrb = base_strb << byte_offset;

generate
    if (WIDTH == 64) begin
        always_comb begin
            case (r_size)
                SIZE_BYTE: size_mask = 64'h00000000_000000FF;
                SIZE_HALF: size_mask = 64'h00000000_0000FFFF;
                SIZE_WORD: size_mask = 64'h00000000_FFFFFFFF;
                default:   size_mask = 64'hFFFFFFFF_FFFFFFFF;
            endcase

            case (r_size)
                SIZE_BYTE: base_strb = 8'b0000_0001;
                SIZE_HALF: base_strb = 8'b0000_0011;
                SIZE_WORD: base_strb = 8'b0000_1111;
                default:   base_strb = 8'b1111_1111;
            endcase
        end
        
    end else begin
        always_comb begin
            case (r_size)
                SIZE_BYTE: size_mask = 32'h000000FF;
                SIZE_HALF: size_mask = 32'h0000FFFF;
                default:   size_mask = 32'hFFFFFFFF;
            endcase

            case (r_size)
                SIZE_BYTE: base_strb = 4'b0001;
                SIZE_HALF: base_strb = 4'b0011;
                SIZE_WORD: base_strb = 4'b1111;
                default:   base_strb = 4'b1111;
            endcase
        end
    end
endgenerate

logic misaligned_request;
assign misaligned_request = (i_rw != RW_NOP) && (
    ((i_size == SIZE_HALF) && (i_addr[0] != 1'b0)) ||
    ((i_size == SIZE_WORD) && (i_addr[1:0] != 2'b00)) ||
    ((i_size == SIZE_DWORD) && (i_addr[2:0] != 3'b000))
);

// AXI assignments
assign o_rdata       = (m_axi_rvalid && m_axi_rready) ? (m_axi_rdata >> (byte_offset * 8)) & size_mask : r_rdata;
assign m_axi_awaddr  = r_addr;
assign m_axi_awsize  = r_size;
assign m_axi_awvalid = r_state == S_W_SET_ADDR || r_state == S_W_ADDR_WAIT;
assign m_axi_awcache = 4'b0011;
assign m_axi_awprot  = 3'b000;
assign m_axi_awburst = 2'b01; 
assign m_axi_awlen   = 8'h00;
assign m_axi_awlock  = 1'b0;
assign m_axi_awqos   = 4'h0;

assign m_axi_wdata   = r_wdata << (byte_offset * 8);
assign m_axi_araddr  = r_addr;
assign m_axi_arsize  = r_size;
assign m_axi_arvalid = r_state == S_R_SET_ADDR || r_state == S_R_ADDR_WAIT;
assign m_axi_arcache = 4'b0011;
assign m_axi_arprot  = 3'b000;
assign m_axi_arburst = 2'b01;
assign m_axi_arlen   = 8'h00;
assign m_axi_arlock  = 1'b0;
assign m_axi_arqos   = 4'h0;

// Sequential logic
always_ff @(posedge i_clk) begin
    if (!i_rstn) begin
        r_state <= S_IDLE;
        r_addr  <= '0;
        r_wdata <= '0;
        r_rdata <= '0;
        r_size  <= '0;
        r_rw    <= '0;
    end else begin
        r_state <= r_next_state;
        if (r_state < 4 && i_rw != RW_NOP) begin
            r_addr  <= i_addr;
            r_wdata <= i_wdata;
            r_size  <= i_size;
            r_rw    <= i_rw;
        end
        if (m_axi_rready && m_axi_rvalid) begin
            r_rdata <= (m_axi_rdata >> (byte_offset * 8)) & size_mask;
        end
    end
end

// Combinatorial logic
always_comb begin
    r_next_state  = r_state;
    o_wait        = (r_state >= 4);
    m_axi_wvalid  = '0;
    m_axi_wlast   = '0;
    m_axi_bready  = '0;
    m_axi_rready  = '0;
    o_done        = '0;
    o_error       = '0;
    o_invalid     = '0;

    unique case (r_state)

    // Idle states
    S_IDLE, S_DONE, S_ERROR, S_INVALID: begin
        if (i_rw == RW_WRITE || i_rw == RW_READ) begin
            if (misaligned_request) begin
                r_next_state = S_INVALID;
                o_done = 1'b1;
                o_error = 1'b1;
                o_invalid = 1'b1;
            end else begin
                r_next_state = (i_rw == RW_WRITE) ? S_W_SET_ADDR : S_R_SET_ADDR;
                o_wait = 1'b1;
            end
        end else begin
            r_next_state = (i_clear) ? S_IDLE : r_state;
            o_done = (i_clear) ? 1'b0 : (r_state != S_IDLE);
            o_error = (i_clear) ? 1'b0 : (r_state == S_ERROR || r_state == S_INVALID);
            o_invalid = (i_clear) ? 1'b0 : (r_state == S_INVALID);
        end
    end

    // Write path
    S_W_SET_ADDR: begin
        r_next_state  = (m_axi_awready) ? S_W_DATA_LAST : S_W_ADDR_WAIT;
    end

    S_W_ADDR_WAIT: begin
        r_next_state = (m_axi_awready) ? S_W_DATA_LAST : S_W_ADDR_WAIT;
    end

    S_W_DATA_LAST: begin
        m_axi_wvalid = 1'b1;
        if (m_axi_wready) begin
            r_next_state = S_W_RET;
            m_axi_wlast  = 1'b1;
        end
    end

    S_W_RET: begin
        m_axi_bready = 1'b1;
        if (m_axi_bvalid) begin
            o_wait = 1'b0;
            o_done = 1'b1;
            o_error = (m_axi_bresp != RESP_OKAY);
            o_invalid = (m_axi_bresp == RESP_DECERR);
            r_next_state = (i_clear) ? S_IDLE :
                           (m_axi_bresp == RESP_DECERR) ? S_INVALID :
                           (m_axi_bresp != RESP_OKAY) ? S_ERROR :
                           S_DONE;
        end
    end

    // Read path
    S_R_SET_ADDR: begin
        r_next_state  = (m_axi_arready) ? S_R_DATA_LAST :  S_R_ADDR_WAIT;
    end

    S_R_ADDR_WAIT: begin
        r_next_state = (m_axi_arready) ? S_R_DATA_LAST : S_R_ADDR_WAIT;
    end

    S_R_DATA_LAST: begin
        m_axi_rready = 1'b1;
        if (m_axi_rvalid) begin
            o_wait = 1'b0;
            o_done = 1'b1;
            o_error = (m_axi_rresp != RESP_OKAY);
            o_invalid = (m_axi_rresp == RESP_DECERR);
            r_next_state = (i_clear) ? S_IDLE :
                           (m_axi_rresp == RESP_DECERR) ? S_INVALID :
                           (m_axi_rresp != RESP_OKAY) ? S_ERROR :
                           S_DONE;
        end
    end
    endcase
end

endmodule
