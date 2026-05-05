%option yylineno
%option noyywrap
%option debug
%option stack
%option prefix="mpp"
%option outfile="mpp.flex.cc"

%{
#include "Statement.hh"
#include "mpp.bison.hh"

// MPP (MetaHDL Preprocessor) lexer - UNIMPLEMENTED
// The grammar is defined in mpp.y but this lexer has no token rules.
// All .mhdl files are processed by VPP first; MPP-specific directives
// (`define with args, `foreach, `elsif, arithmetic functions) bypass
// VPP and would need to be tokenized here. This pass is not yet active.

%}


%%


%%
