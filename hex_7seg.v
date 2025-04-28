module hex_7seg(
    input [6:0] n,      
    output reg [6:0] t, 
    output reg [6:0] o  
);

    reg [3:0] tens; 
    reg [3:0] ones; 

    always @(n) begin
                tens = n / 10;
                ones = n % 10;
     
        case(tens)
            4'd0: t = 7'b1000000; // 0
            4'd1: t = 7'b1111001; // 1
            4'd2: t = 7'b0100100; // 2
            4'd3: t = 7'b0110000; // 3
            4'd4: t = 7'b0011001; // 4
            4'd5: t = 7'b0010010; // 5
            4'd6: t = 7'b0000010; // 6
            4'd7: t = 7'b1111000; // 7
            4'd8: t = 7'b0000000; // 8
            4'd9: t = 7'b0010000; // 9
            default: t = 7'b1111111;
        endcase
        
        
        case(ones)
            4'd0: o = 7'b1000000; // 0
            4'd1: o = 7'b1111001; // 1
            4'd2: o = 7'b0100100; // 2
            4'd3: o = 7'b0110000; // 3
            4'd4: o = 7'b0011001; // 4
            4'd5: o = 7'b0010010; // 5
            4'd6: o = 7'b0000010; // 6
            4'd7: o = 7'b1111000; // 7
            4'd8: o = 7'b0000000; // 8
            4'd9: o = 7'b0010000; // 9
            default: o = 7'b1111111; 
        endcase
    end
endmodule
