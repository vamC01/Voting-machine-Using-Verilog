module top_module (
    input wire clkin,
    input wire rst,
	 input wire a,
	 input wire b,
	 input wire c,
	 input wire [3:0] key_val,
	 input wire vote_done,
    output wire [7:0] LCD_DATA,
    output wire LCD_RW,
    output wire LCD_EN,
    output wire LCD_RS,
    output wire LCD_ON,
    output wire LCD_BLON,
	 output reg [6:0]a_t,
	 output reg [6:0]b_t,
 	 output reg [6:0]c_t
);


wire [1:0] output_from_verilog;
wire [7:0] tt;
wire [6:0] hrs;
wire [6:0] min;
wire [6:0] s;
// Instantiate your Verilog logic
voting xx(
	.clk(clk),
	.rst(rst),
	.a(a),
	.b(b),
	.c(c),
	.key_val(key_val),
	.vote_done(vote_done),
	.a_out(hrs),
	.b_out(min),
	.c_out(s),
	.total(tt),
	.win(output_from_verilog)
	);
	
	

// Instantiate your VHDL LCD controller
lcd_controller u_lcd (
    .Clk50Mhz(clkin),
    .reset(clk),
    .my_output(output_from_verilog),   // <<< Connect here
	 .total_votes(tt),
    .LCD_DATA(LCD_DATA),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_RS(LCD_RS),
    .LCD_ON(LCD_ON),
    .LCD_BLON(LCD_BLON)
);

	reg clk;
	 reg [24:0] counter;
    initial begin
    counter = 0;
    clk = 0;
     end
    always @(posedge clkin) begin
    if (counter == 0) begin
        counter <= 24999999; 
        clk <= ~clk;
    end else begin
        counter <= counter -1;
    end
end


    wire [6:0] H1_wire;
    wire [6:0] H0_wire;
    wire [6:0] M1_wire;
    wire [6:0] M0_wire;
	 wire [6:0] S1_wire;
    wire [6:0] S0_wire;
	 

    hex_7seg h(hrs, H1_wire, H0_wire);
    hex_7seg m(min, M1_wire, M0_wire);
	 hex_7seg dd(s, S1_wire, S0_wire);
   
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_t <= 7'b1111111;
            b_t <= 7'b1111111;
            c_t <= 7'b1111111;
           
        end else begin
            a_t <= H0_wire;
           
            b_t <= M0_wire;
         
            c_t <= S0_wire;
           
				
        end
    end
	 

endmodule
