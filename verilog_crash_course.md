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

Erste Standardisierung 1995 durch die IEEE (Verilog 95). Neuere
Version IEEE Standard 1364–2001 (Verilog 2001).

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

* Donald E. Thomas, Philip R. Moorby, Hardware Description
Language, Kluwer Academic Publishers, 2002
* Blaine Readler, Verilog by example, Full Arc Press, 2011

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

## Synthesis tool: Yosys

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

## A few basic circuits in verilog

### Combinational circuits

### Sequential circuits

## Selected features in verilog

### Parameterized Hardware

### The preprocessor

### Yosys and Systemverilog