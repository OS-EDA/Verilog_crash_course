---
title: "Verilog crash course"
author: "Steffen Reith, Thorsten Knoll"
aspectratio: 169
theme: "AnnArbor"
colortheme: "crane"
fonttheme: "professionalfonts"
fontsize: 10pt
urlcolor: red
linkstyle: bold
titlegraphic: pics/hsrm_logo.png
logo:
date:
section-titles: true
toc: true
---

# Verilog crash course

## Introduction

Verilog was initially developed as a simulation language in 1983/1984, bought up by Cadence and freely released in 1990.

The first standardization took place in 1995 by the IEEE (Verilog 95). A newer version is IEEE Standard 1364-2001 (Verilog 2001).

* Syntax comparable to C (VHDL was started on ADA / Pascal) with compact code
* Spread in North America and Japan (less in Europe)
* Can also be used as the language for netlists
* Support from open source tools
* The majority of the ASICs are developed in Verilog.
* Less expressive than VHDL (curse and blessing)

###
The proximity to C and Java may lead to confusion. In Verilog, too, lines that describe a combinatorial circuit can also be replaced.

** Verilog is a hardware description language (HDL)**

This crash course is limited to a subset of synthesible language constructs in Verilog.

The aim of this selection is not commercial tools, but open-source development tools such as OpenRoad [^1] or Toolchains for FPGAS, i.e. we also use some language constructs from Systemverilog, which are supported by the Yosys synthesis tool.

[^1]: [https://theopenroadproject.org/](https://theopenroadproject.org/)

###

##### Literature

* Donald E. Thomas, Philip R. Moorby, The Verilog Hardware Description Language, Kluwer Academic Publishers, 2002, ISBN 978-1475775891 
* Blaine Readler, Verilog by example, Full Arc Press, 2011, ISBN 978-0983497301

### Contributions, mentions and license

* This course is a translated, modified and 'markdownized' version of a Verilog crash course from Steffen Reith, original in german language.

    [https://github.com/SteffenReith](https://github.com/SteffenReith)

* The initial rework (translate, modify and markdownize) was done by:

    [https://github.com/ThorKn](https://github.com/ThorKn)

* The build of the PDF slides is done with pandoc:

    [https://pandoc.org/](https://pandoc.org/)

* Pandoc is wrapped within this project:

    [https://github.com/alexeygumirov/pandoc-beamer-how-to](https://github.com/alexeygumirov/pandoc-beamer-how-to)

* License:

    GPLv3

### Synthesis tool: Yosys

One should also deal with the peculiarities of the synthesis tool. The well-known open source synthesis tool Yosys writes about this

> Yosys is a framework for VerilogRTLsynthesis. It currently has extensive Verilog-2005 support and provides a basic set of synthesis algorithms for various application do mains. Selected features and typical applications:

#####
- Process almost any synthesizable Verilog-2005 design
- Converting Verilog to BLIF / EDIF/ BTOR / SMT-LIB /simple RTL Verilog / etc.
- ...

## Verilog elements

### Structure of a verilog module

```Verilog
module module_name (port_list);
// Definition of the interface
Port declaration
Parameter declaration

// Description of the circuit
Variables declaration
Assignmente
Module instanciations

always-blocks

endmodule
```

Port list and port declaration can be brought together in modern verilog.

// introduces a comment.

### Example: A linear shiftregister
::: columns

:::: column

```Verilog
module LSFR (

input  wire   load,
input  wire   loadIt,
input  wire   enable,
output wire   newBit,
input  wire   clk,
input  wire   reset);

wire       [17:0]   fsRegN;
reg        [17:0]   fsReg;
wire                taps_0, taps_1;
reg                 genBit;

assign taps_0 = fsReg[0];
assign taps_1 = fsReg[11];

always @(*) begin
  genBit = (taps_0 ^ taps_1);
  if(loadIt) begin
    genBit = load;
  end
end
```
::::

:::: column

```Verilog
assign newBit = fsReg[0];
assign fsRegN = {genBit,fsReg[17 : 1]};

always @(posedge clk) begin
  if(reset) begin
    fsReg <= 18'h0;
  end else begin
    if(enable) begin
      fsReg <= fsRegN;
    end
  end
end

endmodule
```
::::

:::

**input** and **output** define the directions of the ports. 

### Constants and Operators

There are four values ​​for a constant / signal:

* 0 or 1
* X or x (unknown)
* Z or Z (high impedance)

One can specify the width of constants:

* Hexadepimal constant with 32 bit: 32'hDEADBEEF
* Binary constant with 4 bit: 4'b1011
* For better readability you can also use underscores: 12'B1010_1111_0001

To specify the number base use

* b (binary)
* h (hexadecimal),
* o (octal)
* d (decimal)

The default is decimal (d) and the bit width is optional, i.e. 4711 is a permissible (decimal) constant.

###
There is an array notation:

* wire [7:0] serDat;
* reg [0:32] shiftReg;
* Arrays can be sliced to Bits:
    * serDat[3 : 0] (low-nibble) 
    * serDat[7] (MSB).
* {serDat[7:6], serDat[1:0]} notes the concatenation.
* Bits can be replicated and converted into an array, i.e {8{serData[7 : 4]}} contains eight copies of the high-nibble from serDat and has a width of 32.

Arithmetic operations, relations, equivalences and negation:

* a + b, a - b, a * b, a / b und a % b
* a > b, a <= b, und a >= b
* a == b und a != b,
* !(a = b)

###
** Attention: ** If x or z do occur, the simulator determines false in a comparison. If you want to avoid this, the operators === and !== exist. So the following applies:

::: columns

:::: column
#####
```Verilog
if (4'b110z === 4'b110z)
// not taken
then_statement;
```

::::

:::: column
#####
```Verilog
if (4'b110z == 4'b110z)
// not taken
then_statement;
```

::::

:::

Boolean operations exist as usual:

**bitwise operators:** & (AND), | (OR, ~ (NOT), ^ (XOR) und auch ~^ (XNOR)

**logic operators:** && (AND), || (OR) und ! (NOT)

**Shiftoperations:** a << b (shift a for b positions to the left) und a >> b (shift a for b positions to the right). A negative number b is not permitted, empty spots are filled with 0.

### Parameters (old style)
In order to be able to adapt designs easier, Verilog offers the use of parameters.

```Verilog
module mux (
  in1, in2,
  sel,
  out);
 
  parameter WIDTH = 8;  // Number of bits 

  input  [WIDTH - 1 : 0] in1, in2;
  input sel;
  output [WIDTH - 1 : 0] out;
  
  assign out = sel ? in1 : in2;

endmodule
```

### Instances and structural descriptions
If you describe a circuit through its (internal) structure or if a partial circuit is to be reused, an instance is generated and wired.

::: columns

:::: column
```Verilog
module xor2 (
  input  wire a,
  input  wire b,
  output wire e);
  assign e = a ^ b;
endmodule
```
::::

:::: column
```Verilog
module xor3 (
  input  wire a,
  input  wire b,
  input  wire c,
  output wire e);
  
  wire tmp;
  xor2 xor2_1 // Instance 1
    (
      .a(a),
      .b(b),
      .e(tmp)
    );
  xor2 xor2_2 // Instance 2
    (
      .a(c),
      .b(tmp),
      .e(e)
    );
    
endmodule
```
::::

:::

### Code for sequential circuits
A flip-flop takes over the input of the rising or falling edges of the clock. For this, the block entry is used with the *@-symbol* and *always* blocks:

```Verilog
module FF (input  clk,
           input  rst,
           input  d,
           output q);
  reg q;

  always @ ( posedge clk or 
             posedge reset)
    begin
      if ( rst )
        q <= 1'b0;
      else
        q <= d;
     end 
endmodule
```
The list of signals after the @-symbol means sensitivity list. The reset is synchronized when you remove *or posedge reset*.

## Simple circuits: Combinational

###
Combinational circuits correspond to pure boolean functions and therefore do not contain the key word *reg*. No memory (flip-flops) gets generated and assignments are done with *assign*.

```Verilog
module mux4to1 (in1, in2, in3, in4, sel, out);

  parameter WIDTH = 8; 

  input [WIDTH - 1 : 0] in1, in2, in3, in4;
  input [1:0] sel;
  output [WIDTH - 1 : 0] out;

  assign out = (sel == 2'b00) ? in1 :
               (sel == 2'b01) ? in2 :
               (sel == 2'b10) ? in3 :
               in4;
endmodule
```

### Priority encoder
Analog zur VHDL-Version formulieren beschreiben wir den Prioritätsencoder wie folgt:

```Verilog
module prienc (input  wire [4 : 1] req, 
               output wire [2 : 0] idx);

   assign idx = (req[4] == 1'b1) ? 3'b100 :
                (req[3] == 1'b1) ? 3'b011 :
                (req[2] == 1'b1) ? 3'b010 :
                (req[1] == 1'b1) ? 3'b001 :
                3'b000;

endmodule
```

### Priority encoder (alternative version)
Für einen Prioritätsencoder kann man das *don't care*-Feature von Verilog verwenden.

```Verilog
module prienc (input  [4:1] req,
               output reg [2:0] idx);

  always @(*) begin
    casez (req) // casez erlaubt don't-care
       4'b1???: idx = 3'b100; // Auch: idx = 4;
       4'b01??: idx = 3'b011;
       4'b001?: idx = 3'b010;
       4'b0001: idx = 3'b001;
       default: idx = 3'b000;
    endcase
  end

endmodule
```

## Simple circuits: Sequential

### Synchronous design
Im Gegenteil zu kombinatorischen Schaltkreisen verwenden sequentielle Schaltkreise internen Speicher, d.h. die Ausgabe hängt nicht nur von der Eingabe ab.

Bei der synchronen Methode werden alle Speicherelemente durch einen globalen Takt kontrolliert / synchronisiert. Alle Berechnungen werden an der steigenden (und/oder) fallenden Flanke des Taktes vorgenommen.

Das synchrone Design ermöglicht den Entwurf, Test und die Synthese von großen Schaltkreisen mit marktüblichen Tools. Aus diesem Grund ist es empfehlenswert dieses Designprinzip zu erinnerlichen!

Weiterhin sollte keine (kombinatorische) Logik im Taktpfad sein, da dies zu Problemen mit der Laufzeit der Clocksignale führen kann!

### Synchronous circuits
Die Struktur von synchronen Schaltkreisen ist idealisiert wie folgt aufgebaut:

**TODO: Picture here**

### A binary counter
Entsprechend dem synchronen Design kann ein frei laufender Binärzähler (free running binary counter) realisiert werden:

```Verilog
module freecnt (value, clk, reset);

  parameter WIDTH = 8;

  input  wire clk;
  input  wire reset;
  output wire [WIDTH - 1 : 0] value;

  wire [WIDTH - 1 : 0] valN;
  reg  [WIDTH - 1 : 0] val;

  always @(posedge clk) begin

   if (reset) begin // Synchron reset
     val <= {WIDTH{1'b0}};
   end else begin
     val <= valN;
   end

  end

  assign valN = val + 1; // Nextstate logic
  assign value = val; // Output logic
endmodule
```

### Synthesis result of the binary counter

**TODO: Picture here**

An dieser Stelle kann man genau sehen, dass das Ergebnis dem Schaubild des synchronen Designs folgt.

*RTL_REG_SYNC* entspricht dem Stateregister und *RTL_ADD* entspricht der Next State Logic.

### Some remarks
Bisher verwenden wir drei Zuweisungsoperatoren:

* assign signal0 = value,
* signal2 <= value und
* signal1 = value

Die *assign*-Anweisung ist als continuous assignment bekannt und entspricht (grob) einer immer aktiven Drahtverbindung. Sie wird für Signale vom Typ *wire* verwendet und ist für *reg* (Register) nicht zulässig.

Der Operator <= heißt non-blocking assignment. Diese Zuweisung wird für synthetisierte Register verwendet, d.h. in *always*-Blöcken mit *posedge clk* in der Sensitivity-Liste.

Die Variante = heißt blocking assignment und wird für kombinatorische *always*-Blöcke verwendet. Achtung: Für Signale vom Typ *wire* nicht zulässig! Also Typ reg verwenden

### A modulo counter
Entsprechend dem synchronen Design kann ein frei laufender Modulo Binärzähler (free running modulo binary counter) realisiert werden:

::: columns

:::: column

```Verilog
module modcnt (value, clk, reset, sync);

  parameter WIDTH  = 10,
            MODULO = 800,
            hsMin  = 656,
            hsMax  = 751;

  input  wire clk;
  input  wire reset;
  output wire [WIDTH - 1 : 0] value;
  output wire sync;

  wire [WIDTH - 1 : 0] valN;
  reg  [WIDTH - 1 : 0] val;
```
::::

:::: column

```Verilog
  always @(posedge clk) begin
   
    if (reset) begin // Synchron reset
      val <= {WIDTH{1'b0}};
    end else begin
      val <= valN;
    end
  
  end

  // Nextstate logic
  assign valN = (val < MODULO) ? val + 1 : 0;

  // Output logic
  assign value = val;
  assign sync = ((val >= hsMin) && (val <= hsMax)) ? 1 : 0;

endmodule
```

::::

:::

### Synthesis result of the modulo counter

In diesem Fall sind Next State Logic und Output Logic natürlich deutlich komplizierter:

**TODO: Picture here**

### A register file
RISC-V Prozessoren besitzen ein Registerfile mit einem besonderen Zero-Register. Lesen liefert immer eine 0 und Schreiboperationen werden ignoriert.

```Verilog
module regfile (input clk,
                input [4:0] writeAdr, input [31 : 0] dataIn,
                input wrEn,
                input [4:0] readAdrA, output reg [31:0] dataOutA,
                input [4:0] readAdrB, output reg [31:0] dataOutB);

  reg [31 : 0] memory [1 : 31];

  always @(posedge clk) begin

    if ((wrEn) && (writeAdr != 0)) begin

      memory[writeAdr] <= dataIn;

    end

    dataOutA <= (readAdrA == 0) ? 0 : memory[readAdrA];
    dataOutB <= (readAdrB == 0) ? 0 : memory[readAdrB];

  end

endmodule
```

### Synthesis result of the register file
Das Syntheseergebnis ist dann schon etwas unübersichtlicher:

**TODO: Picture here**

## Selected feature: Parameterized counter
Die neueren Varianten von Verilog bieten eine verbesserte Version des Parameter-Features:

::: columns
:::: column
```Verilog
module cnt
  #(parameter N = 8,
    parameter DOWN = 0)

   (input clk,
    input resetN,
    input enable,
    output reg [N-1:0] out);

    always @ (posedge clk) begin
    
     if (!resetN) begin // Synchron
       out <= 0;
     end else begin
     if (enable)
       if (DOWN)
        out <= out - 1;
      else
        out <= out + 1;
     else
       out <= out;
     end
     
    end

endmodule
```
::::

:::: column
``` Verilog
module doubleSum
  #(parameter N = 8)
   (input clk,
    input resetN,
    input enable,
    output [N  :  0] sum);

  wire [N - 1  :  0] val0;
  wire [N - 1  :  0] val1;

  // Counter 0
  cnt #(.N(N), .DOWN(0)) c0 (.clk(clk),
                             .resetN(resetN),
                             .enable(enable),
                             .out(val0));

  // Counter 1
  cnt #(.N(N), .DOWN(1)) c1 (.clk(clk),
                             .resetN(resetN),
                             .enable(enable),
                             .out(val1));

  assign sum = val0 + val1;

endmodule
```
::::
:::

### Synthesis result of the parameterized counter

**TODO: Picture here**

### An alternative version
Verilog bietet weiterhin eine (ältere) Möglichkeit für die Parametrisierung eines Designs:

::: columns
:::: column
```Verilog
module double
  #(parameter N = 8)
  (input clk,
   input resetN,
   input enable,
   output [N : 0] sum);

  wire [N - 1 : 0] val0;
  wire [N - 1 : 0] val1;

  // Counter 0
  defparam c0.N = N;
  defparam c0.DOWN = 0;
  cnt c0 (.clk(clk),
          .resetN(resetN),
          .enable(enable),
          .out(val0));
```
::::

:::: column
``` Verilog
  // Counter 1
  defparam c1.N = N;
  defparam c1.DOWN = 1;
  cnt c1 (.clk(clk),
          .resetN(resetN),
          .enable(enable),
          .out(val1));

  assign sum = val0 + val1;

endmodule
```
::::
:::

Diese Variante führt zum gleichen Syntheseergebnis.

## Selected feature: Preprocessor
Verilog kennt einen Präprozessor (vgl. C/C++) mit \`define, \`include und \`ifdef. Dabei definiert ein *parameter* eine Konstante und \`define eine Textsubstitution.

```Verilog
`define SHIFT_RIGHT
module defineDemo (input clk, s_in,
                   output s_out);
  
  reg [3:0] regs;

  always @(posedge clk) begin // Next State Logic im always - Block
    `ifdef SHIFT_RIGHT
      regs <= {s_in, regs[3:1]};
    `else
      regs <= {regs[2:0], s_in};
    `endif
  end

  `ifdef SHIFT_RIGHT
    assign s_out = regs[0];
  `else
    assign s_out = regs[3];
  `endif

endmodule
```

### Two results of the synthesis
Durch die bedingte Synthese erhält man zwei unterschiedliche Schieberegister:

**TODO: Picture here**

### Modularisation
Vergleichbar mit dem Include-Mechanismus von C/C++ bietet Verilog die Möglichkeit einer primitiven Modularisierung mit `include.

Dabei ist das Tick-Symbol \` wieder der Marker für einen Präprozessor-Befehl, vergleichbar mit # bei C/C++.

Mit \`include headers_def.h können z.B. Konfigurationseinstellungen aus der Datei headers_def.h inkludiert werden. Da ein reiner Textersatz durchgeführt wird, ist die Dateiendung im Prinzip beliebig. Sinnvollerweise verwendet man .h analog zu C.

Sollte ein \`define vor einem \`include angeordnet sein, so wird der Textersatz auch im inkludierten Headerfile durchgeführt, d.h. ein \`define gilt global ab der Definition. Damit können aber vergleichbar mit C unbeabsichtige Ersetzungen passieren.

## Selected feature: Yosys and Systemverilog
Das Open-Source Synthesetool yosys stellt einige ausgewählte Erweiterungen aus SystemVerilog zur Verfügung.

* Besonders interessant ist der logic-Datentyp, der Zuweisungen und reg und wire deutlich vereinfacht. Mit logic signed deklariert man vorzeichenbehaftete Zahlen.
* Für sequentielle Logik wurde der spezielle Block always_ff eingeführt. Für Zuweisungen werden ausschließlich non-blocking Assignments (<=) verwendet.
* Für kombinatorische Logik ersetzt always_comb das Konstrukt always @(*). In always_comb-Blöcken werden nur blocking Assignments (=) verwendet.

### Another counter
Nun soll der free-running counter neu implementiert werden:

```Verilog
module freecnt2

  #(parameter WIDTH = 8)
  (input  logic clk,
   input  logic reset,
   output logic [WIDTH - 1 : 0] value);

  logic [WIDTH - 1 : 0] valN;
  logic [WIDTH - 1 : 0] val;

  always_ff @(posedge clk) begin

    if (reset) begin // Synchron reset
      val <= {WIDTH{1'b0}};
    end else begin
      val <= valN;
    end

  end

  always_comb begin

    valN  = val + 1; // Nextstate logic
    value = val; // Output logic

  end
endmodule
```

### Blocking and Non-blocking assignments in always_ff
Vorsicht mit falschen Zuweisungen in always_ff:

::: columns
:::: column
```Verilog
module demoOk (input clk, 
               input d, 
               output q1, 
               output q2, 
               output q3);

  always_ff @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
    q3 <= q2;
  end

endmodule
```

**TODO: picture**
::::

:::: column
``` Verilog
module demoWrong (input clk, 
                  input d, 
                  output q1, 
                  output q2, 
                  output q3);

  always_ff @(posedge clk) begin
    q1 = d;
    q2 = q1;
    q3 = q2;
  end

endmodule
```

**TODO: picture**
::::
:::