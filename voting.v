module voting(clk,rst,a,b,c,key_val,vote_done,a_out,b_out,c_out,total,win);
input clk;
input rst;
input a,b,c;
input [3:0]key_val;
input vote_done;
output reg [6:0]a_out;
output reg [6:0]b_out;
output reg [6:0]c_out;
output reg [6:0]total;
output reg [1:0] win;
parameter [1:0]KEY=2'b00;
parameter [1:0]VOTE=2'b01;
parameter [1:0]RESULT=2'b10;

reg[1:0] state;

reg tie;

always @ (posedge clk or posedge rst)
begin

if(rst) state<=KEY;
else case(state)
  KEY: state <=  key_val==4'b1111 ? VOTE : KEY;
  VOTE: state <= vote_done ? RESULT : VOTE;
  RESULT:state <= tie ? VOTE : RESULT;
    endcase
end

always @ (posedge clk or posedge rst)
  begin
if(rst) begin
a_out<=7'h0;
b_out<=7'h0;
c_out<=7'h0;
total<=7'h0;
tie<=7'h0;
end
else case(state)
  KEY:  begin a_out<=7'h0;
	b_out<=7'h0;
	c_out<=7'h0;
	total<=7'h0;
	tie<=7'h0;  end
  VOTE: begin
        if(tie)begin 
            a_out<=7'h0;
				b_out<=7'h0;
				c_out<=7'h0;
				total<=7'h0;
				tie<=7'h0;
            end
        case(0)
        a:a_out<=a_out + 1;
        b:b_out<=b_out + 1;
        c:c_out<=c_out + 1;
        endcase
      end
  RESULT: begin  
            total<=a_out+b_out+c_out;
			 if(a_out > b_out && a_out >c_out) win<=2'b00;
			 else begin
						if(b_out > a_out && b_out >c_out) win<=2'b01;
						else win<=2'b10;
					end
          if((a_out==b_out && a_out>c_out) || (a_out==c_out && a_out>b_out) || (b_out==c_out && c_out>a_out)|| (a_out==c_out  && b_out==c_out ))begin 
          tie<=1'b1;win<=2'b11; end
          else tie <= 1'b0; end 
    endcase
end

endmodule
