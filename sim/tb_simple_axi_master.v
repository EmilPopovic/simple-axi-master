`timescale 1ns / 1ps

module tb_simple_axi_master();

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // Host bus
    reg  [31:0] addr;
    reg  [31:0] wdata;
    wire [31:0] rdata;
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

    // Write Data (W) channel
    wire        axi_wvalid;
    reg         axi_wready = 0;
    wire [31:0] axi_wdata;
    wire        axi_wlast;

    // Write Response (B) channel
    reg         axi_bvalid = 0;
    wire        axi_bready;
    reg  [1:0]  axi_bresp = 2'b00;

    // Read Address (AR) channel
    wire        axi_arvalid;
    reg         axi_arready = 0;
    wire [31:0] axi_araddr;

    // Read Data (R) channel
    reg         axi_rvalid = 0;
    wire        axi_rready;
    reg  [31:0] axi_rdata = 0;
    reg  [1:0]  axi_rresp = 2'b00;
    reg         axi_rlast = 0;

    // Master instance
    simple_axi_master #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) dut (
        .i_clk(clk),
        .i_rst(rst),

        .i_addr(addr),
        .i_wdata(wdata),
        .o_rdata(rdata),
        .i_rw(rw),
        .o_wait(wait_sig),
        .o_done(done),
        .i_clear_done(clear_done),
        .o_invalid(invalid),
        .o_error(error),

        .o_axi_awvalid(axi_awvalid),
        .i_axi_awready(axi_awready),
        .o_axi_awaddr(axi_awaddr),
        .o_axi_awsize(),
        .o_axi_awburst(),
        .o_axi_awcache(),
        .o_axi_awprot(),
        .o_axi_awlen(),
        .o_axi_awlock(),
        .o_axi_awqos(),

        .o_axi_wvalid(axi_wvalid),
        .i_axi_wready(axi_wready),
        .o_axi_wlast(axi_wlast),
        .o_axi_wdata(axi_wdata),
        .o_axi_wstrb(),

        .i_axi_bvalid(axi_bvalid),
        .o_axi_bready(axi_bready),
        .i_axi_bresp(axi_bresp),

        .o_axi_arvalid(axi_arvalid),
        .i_axi_arready(axi_arready),
        .o_axi_araddr(axi_araddr),
        .o_axi_arsize(),
        .o_axi_arburst(),
        .o_axi_arcache(),
        .o_axi_arprot(),
        .o_axi_arlen(),
        .o_axi_arlock(),
        .o_axi_arqos(),

        .i_axi_rvalid(axi_rvalid),
        .o_axi_rready(axi_rready),
        .i_axi_rlast(axi_rlast),
        .i_axi_rdata(axi_rdata),
        .i_axi_rresp(axi_rresp)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz

    // Simple AXI slave model
    always @(posedge clk) begin
        // Write address
        if (axi_awvalid && !axi_awready) begin
            axi_awready <= 1;
        end else begin
            axi_awready <= 0;
        end

        // Write data
        if (axi_wvalid && !axi_wready) begin
            axi_wready <= 1;
            #1 $display("[%0t] AXI Write: addr=0x%08x, data=0x%08x", $time, axi_awaddr, axi_wdata);
        end else begin
            axi_wready <= 0;
        end

        // Write response
        if (axi_bready && !axi_bvalid) begin
            axi_bvalid <= 1;
            axi_bresp <= 2'b00; // OKAY
        end else if (axi_bvalid) begin
            axi_bvalid <= 0;
        end

        // Read address
        if (axi_arvalid && !axi_arready) begin
            axi_arready <= 1;
        end else begin
            axi_arready <= 0;
        end

        // Read data
        if (axi_rready && !axi_rvalid) begin
            axi_rvalid <= 1;
            axi_rdata <= 32'hDEADBEEF; // Test data
            axi_rlast <= 1;
            axi_rresp <= 2'b00; // OKAY
            #1 $display("[%0t] AXI Read: addr=0x%08x, data=0x%08x", $time, axi_araddr, axi_rdata);
        end else if (axi_rvalid) begin
            axi_rvalid <= 0;
            axi_rlast <= 0;
        end
    end

    // Run test
    initial begin
        $display("=== AXI Master Testbench ===");

        // Initialize
        addr = 0;
        wdata = 0;
        rw = 2'b00;
        clear_done = 0;

        // Reset
        #20 rst = 0;
        #50;

        // Test 1: Write transaction
        $display("\n[Test 1] Write transaction");
        addr = 32'h1000_0000;
        wdata = 32'hCAFEBABE;
        rw = 2'b01; // Write
        #10;

        // Wait for done
        wait(done);
        $display("[%0t] Write done!", $time);
        rw = 2'b00;
        clear_done = 1;
        #10 clear_done = 0;
        #50;

        // Test 2: Read transaction
        $display("\n[Test 2] Read transaction");
        addr = 32'h2000_0000;
        rw = 2'b10; // Read
        #10;

        // Wait for done
        wait(done);
        $display("[%0t] Read done! Data: 0x%08x", $time, rdata);
        rw = 2'b00;
        clear_done = 1;
        #10 clear_done = 0;
        #50;

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
