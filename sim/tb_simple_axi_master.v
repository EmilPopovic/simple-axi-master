`timescale 1ns / 1ps

module tb_simple_axi_master();

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // Host bus
    reg  [31:0] addr;
    reg  [2:0]  wsize;
    reg  [63:0] wdata;
    wire [63:0] rdata;
    reg  [1:0]  rw;
    wire        wait_sig;
    wire        done;
    reg         clear_done;
    wire        invalid;
    wire        error;

    // AXI signals
    // Write Address (AW) channel
    wire        axi_awvalid;
    reg         axi_awready = 0;
    wire [31:0] axi_awaddr;
    wire [2:0]  axi_awsize;

    // Write Data (W) channel
    wire        axi_wvalid;
    reg         axi_wready = 0;
    wire [63:0] axi_wdata;
    wire        axi_wlast;
    wire [7:0]  axi_wstrb;

    // Write Response (B) channel
    reg         axi_bvalid = 0;
    wire        axi_bready;
    reg  [1:0]  axi_bresp = 2'b00;

    // Read Address (AR) channel
    wire        axi_arvalid;
    reg         axi_arready = 0;
    wire [31:0] axi_araddr;
    wire [2:0]  axi_arsize;

    // Read Data (R) channel
    reg         axi_rvalid = 0;
    wire        axi_rready;
    reg  [63:0] axi_rdata = 0;
    reg  [1:0]  axi_rresp = 2'b00;
    reg         axi_rlast = 0;

    // Master instance
    simple_axi_master dut (
        .i_clk(clk),
        .i_rst(rst),

        .i_addr(addr),
        .i_wsize(wsize),
        .i_wdata(wdata),
        .o_rdata(rdata),
        .i_rw(rw),
        .o_wait(wait_sig),
        .o_done(done),
        .i_clear_done(clear_done),
        .o_invalid(invalid),
        .o_error(error),

        // Write channel
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

        // Write response
        .m_axi_bvalid(axi_bvalid),
        .m_axi_bready(axi_bready),
        .m_axi_bresp(axi_bresp),

        // Read channel
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
    always #5 clk = ~clk; // 100MHz

    // Simple AXI slave storage model
    reg [63:0] mem [0:255];
    reg [31:0] last_addr;
    reg [7:0]  last_wstrb;
    reg [63:0] last_wdata;

    // AXI slave behavior
    always @(posedge clk) begin
        // Write address
        if (axi_awvalid && !axi_awready) begin
            axi_awready <= 1;
            last_addr   <= axi_awaddr;
        end else begin
            axi_awready <= 0;
        end

        // Write data
        if (axi_wvalid && !axi_wready) begin
            axi_wready <= 1;
            last_wdata <= axi_wdata;
            last_wstrb <= axi_wstrb;
            // Store byte-wise in memory
            integer k;
            for (k=0; k<8; k=k+1) begin
                if (axi_wstrb[k])
                    mem[last_addr[10:3]][8*k +:8] <= axi_wdata[8*k +:8];
            end
            #1 $display("[%0t] AXI Write: addr=0x%08x, wstrb=0x%02x, data=0x%016x", $time, last_addr, last_wstrb, last_wdata);
        end else begin
            axi_wready <= 0;
        end

        // Write response
        if (axi_bready && !axi_bvalid) begin
            axi_bvalid <= 1;
            axi_bresp  <= 2'b00; // OKAY
        end else if (axi_bvalid) begin
            axi_bvalid <= 0;
        end

        // Read address
        if (axi_arvalid && !axi_arready) begin
            axi_arready <= 1;
            last_addr   <= axi_araddr;
        end else begin
            axi_arready <= 0;
        end

        // Read data
        if (axi_rready && !axi_rvalid) begin
            axi_rvalid <= 1;
            axi_rdata  <= mem[last_addr[10:3]];
            axi_rlast  <= 1;
            axi_rresp  <= 2'b00;
            #1 $display("[%0t] AXI Read: addr=0x%08x, data=0x%016x", $time, last_addr, mem[last_addr[10:3]]);
        end else if (axi_rvalid) begin
            axi_rvalid <= 0;
            axi_rlast  <= 0;
        end
    end

    // Run test
    initial begin
        $display("=== AXI Master Testbench ===");
        addr = 0;
        wdata = 0;
        wsize = 0;
        rw = 2'b00;
        clear_done = 0;

        // Reset
        #20 rst = 0;
        #50;

        // Byte write at offset 2
        $display("\n[Test 1] Write byte at offset 2");
        addr  = 32'h1000_0002; wsize = 0; wdata = 64'h00000000000000AA; rw = 2'b01;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Write done!", $time);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        // Halfword write at offset 4
        $display("\n[Test 2] Write halfword at offset 4");
        addr  = 32'h1000_0004; wsize = 1; wdata = 64'h000000000000BEEF; rw = 2'b01;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Write done!", $time);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        // Word write at offset 0
        $display("\n[Test 3] Write word at offset 0");
        addr  = 32'h1000_0000; wsize = 2; wdata = 64'h00000000DEADBEEF; rw = 2'b01;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Write done!", $time);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        // Dword write at offset 0
        $display("\n[Test 4] Write dword at offset 0");
        addr  = 32'h1000_0000; wsize = 3; wdata = 64'h1122334455667788; rw = 2'b01;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Write done!", $time);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        // Read test: byte at offset 2
        $display("\n[Test 5] Read byte at offset 2");
        addr  = 32'h1000_0002; wsize = 0; rw = 2'b10;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Read done! Data: 0x%016x", $time, rdata);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        // Read test: halfword at offset 4
        $display("\n[Test 6] Read halfword at offset 4");
        addr  = 32'h1000_0004; wsize = 1; rw = 2'b10;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Read done! Data: 0x%016x", $time, rdata);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        // Read test: word at offset 0
        $display("\n[Test 7] Read word at offset 0");
        addr  = 32'h1000_0000; wsize = 2; rw = 2'b10;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Read done! Data: 0x%016x", $time, rdata);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        // Read test: dword at offset 0
        $display("\n[Test 8] Read dword at offset 0");
        addr  = 32'h1000_0000; wsize = 3; rw = 2'b10;
        repeat (2) @(posedge clk);
        wait(done); $display("[%0t] Read done! Data: 0x%016x", $time, rdata);
        rw = 2'b00;  clear_done = 1; @(posedge clk); clear_done = 0; #20;

        $display("\n=== Test Complete ===");
        $finish;
    end

    // Timeout
    initial begin
        #10000;
        $display("ERROR: Timeout!");
        $finish;
    end

endmodule
