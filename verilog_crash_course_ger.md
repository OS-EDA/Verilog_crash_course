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

Verilog wurde 1983/1984 zunächst als Simulationssprache
entwickelt, von Cadence aufgekauft und 1990 frei gegeben.

Die erste Standardisierung erfolgte 1995 durch die IEEE (Verilog 95). Eine neuere
Version ist IEEE Standard 1364–2001 (Verilog 2001).

* Syntax vergleichbar mit C (VHDL ist an ADA / Pascal
angeleht) mit kompakten Code
* Verbreitet in Nordamerika und Japan ( weniger in Europa)
* Kann auch als Sprache von Netzlisten verwendet werden
* Unterstützung durch Open-Source-Tools
* Die Mehrheit der ASICs wird in Verilog entwickelt.
* Weniger ausdruckstark als VHDL (Fluch und Segen)

###
Die Nähe zu C und Java führt evtl. zu Verwechselungen! Auch in
Verilog können z.B. Zeilen, die eine kombinatorische Schaltung
beschreiben vertauscht werden.

**Verilog ist eine Hardwarebeschreibungssprache!**

In diesem Abschnitt legen wir auf auf einen Subset von
synthetisierbaren Sprachkonstrukten fest.

Ziel unserer Auswahl sind nicht kommerzielle Tools, sondern
offene Entwicklungswerkzeuge wie OpenRoad[^1] oder Toolchains
für bekannte FPGAs, d.h. wir verwenden auch einige
Sprachkonstrukte von SystemVerilog, die durch das
Synthesewerkzeug yosys unterstützt werden.

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

Man sollte sich auch mit den Eigenheiten des Synthesetools
beschäftigen! Das bekannte Open-Source-Synthesetool yosys
schreibt dazu

> Yosys is a framework for VerilogRTLsynthesis. It currently has extensive Verilog-2005 support and provides a ba-
sic set of synthesis algorithms for various application do mains. Selected features and typical applications:

#####
- Process almost any synthesizable Verilog-2005 design
- Converting Verilog to BLIF / EDIF/ BTOR / SMT-LIB /simple RTL Verilog / etc.
- ...

## Verilog elements

### Structure of a verilog module


```Verilog
module module_name (port_list);
// Definition der Schnittstelle
Port-Deklaration
Parameter-Deklaration

// Beschreibung des Schaltkreises
Variablen-Deklaration
Zuweisungen
Modul-Instanzierungen

always-Bloecke

endmodule
```

In modernem Verilog können Portliste und Portdeklaration
zusammengezogen werden.
// leitet einen Kommentar ein.

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

Dabei geben **input** und **output**  die **Richtung des Ports** an. 

### Constants and Operators

Es gibt vier Werte für eine Konstante / Signal: 

* 0 oder 1 
* X bzw. x (unbekannt) 
* Z bzw. z (hochohmig)

Man kann die Breite von Konstanten angeben:

* Hexadezimalkonstante mit 32 Bit: 32'hDEADBEEF
* Binärkonstante mit 4 Bit: 4'b1011
* Zur besseren Lesbarkeit kann man auch den Underscore verwenden: 12'b1010_1111_0001

Zur Spezifikation der Zahlenbasis sind 

* b (binär)
* h (hexadezimal),
* o (oktal) 
* d (dezimal) zulässig.

Der Default ist dezimal (d) und die Bitbreite ist optional, d.h. 4711
ist eine zulässige (dezimal) Konstante.

###

Passend zu den Konstanten existiert eine Array-Schreibweise:

* wire [7:0] serDat;
* reg [0:32] shiftReg;
* Einzelne Bits können gesliced werden:
    * serDat[3 : 0] (low-nibble) 
    * serDat[7] (MSB).
* {serDat[7:6], serDat[1:0]} notiert die Konkatenation.
* Bits können repliziert und in ein Array umgewandelt werden, d.h. {8{serData[7 : 4]}} enthält acht Kopien des high-nibble von serDat und hat eine Breite von 32.

Weiterhin existieren die üblichen arithmetischen Operationen,
Ordnungsrelationen, Äquivalenzen und Negation:

* a + b, a - b, a * b, a / b und a % b
* a > b, a <= b, und a >= b
* a == b und a != b,
* !(a = b)

###

**Achtung:** Kommen x oder z vor, so ermittelt der Simulator bei einem Vergleich false. Will man dies vermeiden, so existieren die Operatoren === und !==. Also gilt:

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

Es existieren auch boolesche Operationen wie gewohnt:

**bitweise Operatoren:** & (UND), | (ODER, ~ (NICHT), ^ (XOR) und auch ~^ (XNOR)

**logische Operatoren:** && (UND), || (ODER) und ! (NICHT)

**Schiebeoperation:** a << b (schiebe a um b Stellen nach links) und a >> b (verschiebe a um b Positionen nach
rechts). Eine negative Anzahl b ist nicht zulässig, leere Stellen werden mit 0 aufgefüllt.

### Parameters (old style)
Um Designs leichter anpassen zu können, bietet Verilog die Verwendung von Parametern an.

```Verilog
module mux (
  in1, in2,
  sel,
  out);
 
  parameter WIDTH = 8;  // Anzahl der Bits
 
  input  [WIDTH - 1 : 0] in1, in2;
  input sel;
  output [WIDTH - 1 : 0] out;
  
  assign out = sel ? in1 : in2;

endmodule
```

### Instances and structural descriptions
Beschreibt man einen Schaltkreis durch seine (interne) Struktur oder soll ein Teilschaltkreis wiederverwendet werden, dann wird eine Instanz erzeugt und verdrahtet.

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
  xor2 xor2_1 // Instanz 1
    (
      .a(a),
      .b(b),
      .e(tmp)
    );
  xor2 xor2_2 // Instanz 2
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
Wie besprochen übernimmt ein Flipflop die Eingabe an den steigenden oder fallenden Flanken des Taktes. Dafür wird die Ereignissteuerung mit dem @-Symbol und always-Blöcken verwendet:

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
Die Signalliste hinter dem @ heißt Sensitivity-List. Der reset wird synchron, wenn man or posedge reset entfernt.

## Simple circuits: Combinational

###
Kombinatorische Schaltkreise entsprechen reinen booleschen Funktionen und enthalten demzufolge nicht das Schlüsselwort *reg*. Es wird kein Speicher (Flipflops) erzeugt und Zuweisungen geschehen mit *assign*.

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