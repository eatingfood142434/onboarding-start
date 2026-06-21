`default_nettype none

module spi_peripheral (
    input  wire       clk, // clock
    input  wire       rst_n, // reset_n
    input wire [2:0] ui_in,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle, 
);
    wire raw_copi = ui_in[1];
    wire raw_ncs = ui_in[2];
    wire raw_sclk = ui_in[0];

    reg [1:0] sclk_sync;
    reg [1:0] copi_sync;
    reg [1:0] ncs_sync;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_sync <= 2'b00;
            copi_sync <= 2'b00;
            ncs_sync <= 2'b00;
        end
        else begin
            sclk_sync <= {sclk_sync[0], raw_sclk};
            copi_sync <= {copi_sync[0], raw_copi};
            ncs_sync <= {ncs_sync[0], raw_ncs};
        end
    end

    wire sclk_reg = sclk_sync[1];
    wire copi_reg = copi_sync[1];
    wire ncs_reg = ncs_sync[1];

    reg sclk_delayed;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sclk_delayed <= 1'b0;
        else sclk_delayed <= sclk_reg;
    end

    wire sclk_edge = sclk_reg & ~sclk_delayed;
    reg [15:0] shift_reg;
    reg [3:0] bit_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 16'h0000;
            bit_count <= 4'h0;
        end
        else if (ncs_reg) bit_count <= 4'h0;
        else if (sclk_edge) begin
            shift_reg <= {shift_reg[14:0], copi_reg};
            if (bit_count == 4'hF) bit_count <= 4'h0;
            else bit_count <= bit_count + 1;
        end
    end

    wire [15:0] rx_frame = {shift_reg[14:0], copi_reg};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_reg_out_7_0 <= 8'h00;
            en_reg_out_15_8 <= 8'h00;
            en_reg_pwm_7_0 <= 8'h00;
            en_reg_pwm_15_8 <= 8'h00;
            pwm_duty_cycle <= 8'h00;
        end
        else if (sclk_edge && !ncs_reg && bit_count == 4'hF) begin
            if (rx_frame[15]) begin
                case (rx_frame[14:8])
                    7'h00: en_reg_out_7_0 <= rx_frame[7:0];
                    7'h01: en_reg_out_15_8 <= rx_frame[7:0];
                    7'h02: en_reg_pwm_7_0 <= rx_frame[7:0];
                    7'h03: en_reg_pwm_15_8 <= rx_frame[7:0];
                    7'h04: pwm_duty_cycle <= rx_frame[7:0];
                    default: ; // invalid address
                endcase
            end
        end
    end

    
endmodule