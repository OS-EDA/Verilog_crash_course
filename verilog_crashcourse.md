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