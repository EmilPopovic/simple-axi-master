`timescale 1ns / 1ps

module tb_simple_axi_master();

// Clock and reset
logic clk = 0;
logic rst = 1;

// Host bus
logic [31:0] addr;
logic [2:0]  size;
logic [63:0] wdata;
logic [63:0] rdata;
logic [1:0]  rw;
logic        wait_sig;
logic        done;
logic        clear;
logic        invalid;
logic        error;

// AXI signals
logic        axi_awvalid;
logic        axi_awready = 0;
logic [31:0] axi_awaddr;
logic [2:0]  axi_awsize;

logic        axi_wvalid;
logic        axi_wready = 0;
logic [63:0] axi_wdata;
logic        axi_wlast;
logic [7:0]  axi_wstrb;

logic        axi_bvalid = 0;
logic        axi_bready;
logic [1:0]  axi_bresp = 2'b00;

logic        axi_arvalid;
logic        axi_arready = 0;
logic [31:0] axi_araddr;
logic [2:0]  axi_arsize;

logic        axi_rvalid = 0;
logic        axi_rready;
logic [63:0] axi_rdata = 0;
logic [1:0]  axi_rresp = 2'b00;
logic        axi_rlast = 0;

// Master instance
simple_axi_master dut (
    .i_clk(clk),
    .i_rst(rst),
    .i_addr(addr),
    .i_size(size),
    .i_wdata(wdata),
    .o_rdata(rdata),
    .i_rw(rw),
    .o_wait(wait_sig),
    .o_done(done),
    .i_clear(clear),
    .o_invalid(invalid),
    .o_error(error),

    .m_axi_awvalid(axi_awvalid),
    .m_axi_awready(axi_awready),
    .m_axi_awaddr(axi_awaddr),
    .m_axi_awsize(axi_awsize),
    .m_axi_awburst(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awlen(),
    .m_axi_awlock(),
    .m_axi_awqos(),

    .m_axi_wvalid(axi_wvalid),
    .m_axi_wready(axi_wready),
    .m_axi_wlast(axi_wlast),
    .m_axi_wdata(axi_wdata),
    .m_axi_wstrb(axi_wstrb),

    .m_axi_bvalid(axi_bvalid),
    .m_axi_bready(axi_bready),
    .m_axi_bresp(axi_bresp),

    .m_axi_arvalid(axi_arvalid),
    .m_axi_arready(axi_arready),
    .m_axi_araddr(axi_araddr),
    .m_axi_arsize(axi_arsize),
    .m_axi_arburst(),
    .m_axi_arcache(),
    .m_axi_arprot(),
    .m_axi_arlen(),
    .m_axi_arlock(),
    .m_axi_arqos(),

    .m_axi_rvalid(axi_rvalid),
    .m_axi_rready(axi_rready),
    .m_axi_rlast(axi_rlast),
    .m_axi_rdata(axi_rdata),
    .m_axi_rresp(axi_rresp)
);

// Clock generation
always #5 clk = ~clk;

// 16 x 64-bit words = 128 bytes (0x00 to 0x7F)
logic [63:0] mem [0:15];
logic [31:0] read_addr;
logic [31:0] write_addr;
int slave_delay_counter;
int slave_delay_load;
logic slave_delay_reload;
logic [1:0] error_response;

initial begin
    for (int i = 0; i < 16; i++) begin
        mem[i] = 64'h0000_0000_0000_0000;
    end
end

task dump_memory(input string title = "Memory");
    $display("\n--- %s ---", title);
    for (int i = 0; i < 16; i++) begin
        $display("  [0x%02X]: 0x%016X", i*8, mem[i]);
    end
    $display("-------------------\n");
endtask

task display_status(input string msg = "");
    $display("  Status: done=%0b, error=%0b, invalid=%0b, wait=%0b %s",
             done, error, invalid, wait_sig, msg);
endtask

// AXI slave
always_ff @(posedge clk) begin
    if (rst) begin
        axi_awready <= 0;
        axi_wready <= 0;
        axi_bvalid <= 0;
        axi_arready <= 0;
        axi_rvalid <= 0;
        axi_rlast <= 0;
        slave_delay_counter <= 0;
    end else begin
        // Handle reload request
        if (slave_delay_reload) begin
            slave_delay_counter <= slave_delay_load;
        // Decrement counter if non-zero
        end else if (slave_delay_counter > 0) begin
            slave_delay_counter <= slave_delay_counter - 1;
        end

        // Write address channel
        if (axi_awvalid && !axi_awready) begin
            if (slave_delay_counter == 0) begin
                axi_awready <= 1;
                write_addr  <= axi_awaddr;
            end
        end else begin
            axi_awready <= 0;
        end

        // Write data channel
        if (axi_wvalid && !axi_wready) begin
            if (slave_delay_counter == 0) begin
                axi_wready <= 1;
                if (error_response == 2'b00) begin
                    // Write bytes according to strobe
                    for (int k = 0; k < 8; k++) begin
                        if (axi_wstrb[k])
                            mem[write_addr[6:3]][8*k +: 8] = axi_wdata[8*k +: 8];
                    end
                end
                $display("  [%0t] AXI Write: addr=0x%08X, strb=0x%02X, data=0x%016X",
                            $time, write_addr, axi_wstrb, axi_wdata);
            end
        end else begin
            axi_wready <= 0;
        end

        // Write response
        if (axi_bready && !axi_bvalid) begin
            if (slave_delay_counter == 0) begin
                axi_bvalid <= 1;
                axi_bresp  <= error_response;
            end
        end else if (axi_bvalid) begin
            axi_bvalid <= 0;
        end

        // Read address channel
        if (axi_arvalid && !axi_arready) begin
            if (slave_delay_counter == 0) begin
                axi_arready <= 1;
                read_addr   <= axi_araddr;
            end
        end else begin
            axi_arready <= 0;
        end

        // Read data channel
        if (axi_rready && !axi_rvalid) begin
            if (slave_delay_counter == 0) begin
                axi_rvalid <= 1;
                axi_rdata  <= (error_response == 2'b00) ? mem[read_addr[6:3]] : 64'h0;
                axi_rlast  <= 1;
                axi_rresp  <= error_response;
                $display("  [%0t] AXI Read: addr=0x%08X, data=0x%016X",
                            $time, read_addr, (error_response == 2'b00) ? mem[read_addr[6:3]] : 64'h0);
            end
        end else if (axi_rvalid) begin
            axi_rvalid <= 0;
            axi_rlast  <= 0;
        end
    end
end

// Write transaction task
task automatic do_write(input logic [31:0] addr_in,
                        input logic [2:0]  size_in,
                        input logic [63:0] data_in,
                        input int delay = 0);
    $display("\n[Write] addr=0x%08X, size=%0d, data=0x%016X, delay=%0d",
                addr_in, size_in, data_in, delay);
    slave_delay_load = delay;
    slave_delay_reload = 1;
    @(posedge clk);
    slave_delay_reload = 0;

    addr = addr_in;
    size = size_in;
    wdata = data_in;
    rw = 2'b01;
    @(posedge clk);
    wait(done || invalid);
    @(posedge clk);
    display_status();
    rw = 2'b00;
endtask

// Read transaction task
task automatic do_read(input logic [31:0] addr_in,
                        input logic [2:0]  size_in,
                        input int delay = 0);
    $display("\n[Read] addr=0x%08X, size=%0d, delay=%0d",
                addr_in, size_in, delay);
    slave_delay_load = delay;
    slave_delay_reload = 1;
    @(posedge clk);
    slave_delay_reload = 0;

    addr = addr_in;
    size = size_in;
    rw = 2'b10;
    @(posedge clk);
    wait(done || invalid);
    @(posedge clk);
    $display("  Data read: 0x%016X", rdata);
    display_status();
    rw = 2'b00;
endtask

// Clear status task
task do_clear();
    $display("  [Clearing status flags]");
    clear = 1;
    @(posedge clk);
    clear = 0;
    @(posedge clk);
    display_status("after clear");
endtask

// Main test sequence
initial begin
    $display("\n=======================");
    $display("=== AXI Master Test ===");
    $display("=======================\n");

    addr = 0;
    wdata = 0;
    size = 0;
    rw = 2'b00;
    clear = 0;
    slave_delay_load = 0;
    slave_delay_reload = 0;
    error_response = 2'b00; // OKAY

    #20 rst = 0;
    #50;

    dump_memory("Initial Memory State");

    // ================================================
    // Test 1: Aligned writes (all sizes)
    // ================================================
    $display("\n========== TEST 1: Aligned Writes ==========");

    do_write(32'h0000_0000, 3'b000, 64'h00000000_000000AA, 0); // byte
    do_clear();

    do_write(32'h0000_0002, 3'b001, 64'h00000000_0000BBBB, 0); // half
    do_clear();

    do_write(32'h0000_0004, 3'b010, 64'h00000000_CCCCCCCC, 0); // word
    do_clear();

    do_write(32'h0000_0008, 3'b011, 64'hDDDDDDDD_DDDDDDDD, 0); // dword
    do_clear();

    dump_memory("After Aligned Writes");

    // ================================================
    // Test 2: Aligned reads (all sizes)
    // ================================================
    $display("\n========== TEST 2: Aligned Reads ==========");

    do_read(32'h0000_0000, 3'b000, 0); // byte
    do_clear();

    do_read(32'h0000_0002, 3'b001, 0); // half
    do_clear();

    do_read(32'h0000_0004, 3'b010, 0); // word
    do_clear();

    do_read(32'h0000_0008, 3'b011, 0); // dword
    do_clear();

    // ================================================
    // Test 3: Slow slave
    // ================================================
    $display("\n========== TEST 3: Slow Slave ==========");

    do_write(32'h0000_0010, 3'b010, 64'h00000000_11111111, 3);
    do_clear();

    do_read(32'h0000_0010, 3'b010, 5);
    do_clear();

    do_write(32'h0000_0018, 3'b011, 64'h22222222_22222222, 7);
    do_clear();

    dump_memory("After Slow Slave Tests");

    // ================================================
    // Test 4: Misaligned accesses (should error)
    // ================================================
    $display("\n========== TEST 4: Misaligned Accesses ==========");

    $display("\n[Misaligned halfword to 0x01]");
    do_write(32'h0000_0001, 3'b001, 64'h00000000_0000EEEE, 0);
    $display("  Expected: invalid=1, error=1");
    display_status();
    // Don't clear
    @(posedge clk); @(posedge clk); @(posedge clk);
    display_status("(3 cycles later, not cleared)");
    do_clear();

    $display("\n[Misaligned word to 0x02]");
    do_write(32'h0000_0002, 3'b010, 64'h00000000_FFFFFFFF, 0);
    $display("  Expected: invalid=1, error=1");
    display_status();
    do_clear();

    $display("\n[Misaligned dword to 0x04]");
    do_write(32'h0000_0004, 3'b011, 64'h99999999_99999999, 0);
    $display("  Expected: invalid=1, error=1");
    display_status();
    do_clear();

    $display("\n[Misaligned read]");
    do_read(32'h0000_0003, 3'b010, 0);
    $display("  Expected: invalid=1, error=1");
    display_status();
    do_clear();

    dump_memory("After Misaligned Tests (should be unchanged)");

    // ================================================
    // Test 5: AXI SLVERR response
    // ================================================
    $display("\n========== TEST 5: AXI SLVERR ==========");
    error_response = 2'b10; // SLVERR

    $display("\n[Write with SLVERR]");
    do_write(32'h0000_0020, 3'b010, 64'h00000000_BAAAAAAD, 0);
    $display("  Expected: error=1, invalid=0");
    display_status();
    // Test that we can start new transaction without clearing
    @(posedge clk); @(posedge clk);
    display_status("(still in error state)");
    do_clear();

    $display("\n[Read with SLVERR]");
    do_read(32'h0000_0020, 3'b010, 0);
    $display("  Expected: error=1, invalid=0");
    display_status();
    do_clear();

    // ================================================
    // Test 6: AXI DECERR response
    // ================================================
    $display("\n========== TEST 6: AXI DECERR ==========");
    error_response = 2'b11; // DECERR

    $display("\n[Write with DECERR]");
    do_write(32'h0000_0028, 3'b010, 64'h00000000_DEADDEAD, 0);
    $display("  Expected: error=1, invalid=1");
    display_status();
    do_clear();

    $display("\n[Read with DECERR]");
    do_read(32'h0000_0028, 3'b010, 0);
    $display("  Expected: error=1, invalid=1");
    display_status();
    do_clear();

    error_response = 2'b00; // Back to OKAY

    // ================================================
    // Test 7: Status persistence (no clear)
    // ================================================
    $display("\n========== TEST 7: Status Persistence ==========");

    $display("\n[Successful write, then check persistence]");
    do_write(32'h0000_0030, 3'b010, 64'h00000000_12345678, 0);
    display_status();

    repeat(5) @(posedge clk);
    display_status("(5 cycles later, no clear)");

    // Try to start new transaction
    $display("\n[Starting new transaction from done state (no clear)]");
    do_write(32'h0000_0038, 3'b010, 64'h00000000_ABCDEFAB, 0);
    display_status();
    do_clear();

    dump_memory("After Status Persistence Tests");

    // ================================================
    // Test 8: Back-to-back transactions
    // ================================================
    $display("\n========== TEST 8: Back-to-Back Transactions ==========");

    do_write(32'h0000_0040, 3'b000, 64'h00000000_000000FF, 0);
    // Clear and immediately start next
    clear = 1; @(posedge clk); clear = 0;

    do_write(32'h0000_0041, 3'b000, 64'h00000000_000000EE, 0);
    clear = 1; @(posedge clk); clear = 0;

    do_read(32'h0000_0040, 3'b001, 0);
    do_clear();

    dump_memory("Final Memory State");

    // ================================================
    $display("\n========================================");
    $display("=== All Tests Complete ===");
    $display("========================================\n");
    $finish;
end

// Timeout watchdog
initial begin
    #500000;
    $display("\n*** ERROR: Timeout! ***\n");
    $finish;
end

endmodule
