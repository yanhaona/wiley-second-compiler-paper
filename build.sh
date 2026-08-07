#!/bin/bash
xelatex -interaction=nonstopmode main
bibtex main
xelatex -interaction=nonstopmode main
xelatex -interaction=nonstopmode main
