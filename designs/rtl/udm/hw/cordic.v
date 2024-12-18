
module cos_CORDIC(
  input clock,
  output reg [31:0] cosine,
  input [31:0] angle,
  input start,
  output reg ready,
  input rst);

  reg signed [31:0] x [0:15];
  reg signed [31:0] y [0:15];
  reg [32:0] z [0:15];
  reg used [0:15];
  wire signed [15:0] atan_table [0:15];
 
  assign atan_table[00] = 'hc910;
  assign atan_table[01] = 'h76b2;
  assign atan_table[02] = 'h3eb7;
  assign atan_table[03] = 'h1fd6;
  assign atan_table[04] = 'h0ffb;
  assign atan_table[05] = 'h07ff;
  assign atan_table[06] = 'h0400;
  assign atan_table[07] = 'h0200;
  assign atan_table[08] = 'h0100;
  assign atan_table[09] = 'h0080;
  assign atan_table[10] = 'h0040;
  assign atan_table[11] = 'h0020;
  assign atan_table[12] = 'h0010;
  assign atan_table[13] = 'h0008;
  assign atan_table[14] = 'h0004;
  assign atan_table[15] = 'h0002;

  
 always @(posedge clock)
  begin
  if (rst)
  begin
    used[0] <= 0;
  end
  if (start)
  begin
    x[0] <= 65536;  
    y[0] <= 0;
    z[0] <= angle;
    used[0] <= 1;
  end
  else
  begin
    x[0] <= 0;  
    y[0] <= 0;
    z[0] <= 0;
    used[0] <= 0;
  end
  end
  genvar i;

  for (i=0; i < 15; i=i+1)
  begin: xyz
    wire z_sign;
    wire signed [31:0] x_shr, y_shr;

    assign x_shr = x[i] >>> i;
    assign y_shr = y[i] >>> i;

    assign z_sign = (z[i][32] || z[i] == 0);

    always @(posedge clock)
    begin
        if (rst)
        begin
          used[i+1] <= 0;
        end
        else
        begin
          x[i+1] <= z_sign ? x[i] + y_shr : x[i] - y_shr;
          y[i+1] <= z_sign ? y[i] - x_shr : y[i] + x_shr;
          z[i+1] <= z_sign ? z[i] + atan_table[i] : z[i] - atan_table[i];
          used[i+1] <= used[i];
        end
    end
  end

  always @(posedge clock)
  begin
    if (rst)
      ready <= 0;
    if (used[15])
    begin
      cosine <= x[15];
      ready <= 1;
    end
    else
    begin
        ready <= 0;
    end
  end

endmodule
