---
title: "Verilog Crashcourse"
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

# Verilog crashcourse

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

* This course is a translated, modified and 'markdownized' version of a Verilog crashcourse from Steffen Reith.

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

## A few basic circuits in verilog

### Combinational circuits

### Sequential circuits

## Selected features in verilog

### Parameterized Hardware

### The preprocessor

### Yosys and Systemverilog