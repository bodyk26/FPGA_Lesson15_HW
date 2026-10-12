`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2026 23:08:31
// Design Name: 
// Module Name: tb_mov_max
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_moving_max;

    localparam N_SAMPLES = 64;
    localparam LOOKBACK  = 7;
    localparam CLK_HALF  = 5;        // 100 МГц
    localparam TIMEOUT   = 10000;    // тактів на один запуск

    reg         ap_clk = 1'b0;
    reg         ap_rst = 1'b1;
    reg         ap_start = 1'b0;
    wire        ap_done;
    wire        ap_idle;
    wire        ap_ready;

    wire [5:0]  in_data_address0;
    wire        in_data_ce0;
    reg  [31:0] in_data_q0;

    wire [5:0]  out_data_address0;
    wire        out_data_ce0;
    wire        out_data_we0;
    wire [31:0] out_data_d0;

    always #CLK_HALF ap_clk = ~ap_clk;

    moving_max_0 dut (
        .ap_clk            (ap_clk),
        .ap_rst            (ap_rst),
        .ap_start          (ap_start),
        .ap_done           (ap_done),
        .ap_idle           (ap_idle),
        .ap_ready          (ap_ready),
        .in_data_address0  (in_data_address0),
        .in_data_ce0       (in_data_ce0),
        .in_data_q0        (in_data_q0),
        .out_data_address0 (out_data_address0),
        .out_data_ce0      (out_data_ce0),
        .out_data_we0      (out_data_we0),
        .out_data_d0       (out_data_d0)
    );

    reg signed [31:0] in_mem  [0:N_SAMPLES-1];
    reg signed [31:0] out_mem [0:N_SAMPLES-1];
    reg signed [31:0] ref_mem [0:N_SAMPLES-1];

    // Вхідна пам'ять
    always @(posedge ap_clk) begin
        if (in_data_ce0)
            in_data_q0 <= in_mem[in_data_address0];
    end

    // Вихідна пам'ять
    always @(posedge ap_clk) begin
        if (out_data_ce0 && out_data_we0)
            out_mem[out_data_address0] <= out_data_d0;
    end

    // Прямий перебір
    task ref_moving_max;
        integer n, i, start;
        reg signed [31:0] m;
        begin
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                start = (n < LOOKBACK) ? 0 : (n - LOOKBACK);
                m = in_mem[start];
                for (i = start + 1; i <= n; i = i + 1)
                    if (in_mem[i] > m) m = in_mem[i];
                ref_mem[n] = m;
            end
        end
    endtask

    // Скидання
    task rst;
        begin
            ap_rst = 1'b1;
            repeat (3) @(posedge ap_clk);
            ap_rst = 1'b0;
            repeat (2) @(posedge ap_clk);
        end
    endtask
    
    // Запуск ядра
    task run_dut;
        integer cycles;
        reg     done_seen;
        begin
            rst; // Виконати скидання
            @(negedge ap_clk); //negedge - щоб виставити сигнал до його зчитування (ap_start читається на posedge) 
            ap_start  = 1'b1;
            done_seen = 1'b0;
            cycles    = 0;
            while (!done_seen && cycles < TIMEOUT) begin //Поки не з'явиться done або не буде таймаут
                @(posedge ap_clk);
                #1;
                if (ap_ready) ap_start  = 1'b0; //ap_start треба зняти, коли ap_ready=1
                if (ap_done)  done_seen = 1'b1; //app_done означає що ядро завершило прохід
                cycles = cycles + 1;
            end
            ap_start = 1'b0;
            if (!done_seen) begin
                $display("ERROR: timeout, no ap_done after %0d cycles", TIMEOUT);
                $finish;
            end
            @(posedge ap_clk);
            #1; // Такт щоб дані точно записалися
        end
    endtask

    // Тести
    integer total_errors = 0;

    task run_test(input [8*16-1:0] name);
        integer n, errors;
        begin
            for (n = 0; n < N_SAMPLES; n = n + 1)
                out_mem[n] = 32'hDEADBEEF;   // щоб незаписані комірки було видно

            $display("=== Test: %0s ===", name);
            ref_moving_max;
            run_dut;

            
            errors = 0;
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                if (out_mem[n] !== ref_mem[n]) begin
                    errors = errors + 1;
                end
            end
            $display("%0s: %0s (%0d errors)\n", name, errors ? "FAIL" : "PASS", errors);
            total_errors = total_errors + errors;
        end
    endtask

    
    integer      k;
    reg [31:0]   seed;

    initial begin
        $display("moving_max RTL testbench: N_SAMPLES=%0d, WINDOW=%0d\n", N_SAMPLES, LOOKBACK + 1);

        // скидання (ap_rst активний високим рівнем)
        repeat (5) @(posedge ap_clk);
        ap_rst = 1'b0;
        repeat (2) @(posedge ap_clk);

        // 1. Зростаюча послідовність
        for (k = 0; k < N_SAMPLES; k = k + 1) in_mem[k] = k;
        run_test("ascending");

        // 2. Спадна послідовність
        for (k = 0; k < N_SAMPLES; k = k + 1) in_mem[k] = N_SAMPLES - k;
        run_test("descending");

        // 3. Одиночний пік
        for (k = 0; k < N_SAMPLES; k = k + 1) in_mem[k] = 0;
        in_mem[N_SAMPLES / 2] = 100;
        run_test("single spike");

        // 4. Генератор (той самий, що в C++ тестбенчі)
        seed = 32'd12345;
        for (k = 0; k < N_SAMPLES; k = k + 1) begin
            seed = seed * 32'd1103515245 + 32'd12345;
            in_mem[k] = (seed >> 16) % 1000;
        end
        run_test("generator");

        // 5. Граничні значення int
        for (k = 0; k < N_SAMPLES; k = k + 1)
            case (k % 4)
                0: in_mem[k] = 32'h80000000;   // INT_MIN
                1: in_mem[k] = 32'h7FFFFFFF;   // INT_MAX
                2: in_mem[k] = -1;
                default: in_mem[k] = 0;
            endcase
        run_test("int extremes");

        if (total_errors) $display("Test FAILED: %0d errors", total_errors);
        else              $display("Test passed !");
        $finish;
    end

endmodule