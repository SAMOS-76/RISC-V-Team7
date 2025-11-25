// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdut.h for the primary calling header

#include "verilated.h"

#include "Vdut__Syms.h"
#include "Vdut___024unit.h"

void Vdut___024unit___ctor_var_reset(Vdut___024unit* vlSelf);

Vdut___024unit::Vdut___024unit(Vdut__Syms* symsp, const char* name)
    : VerilatedModule{name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vdut___024unit___ctor_var_reset(this);
}

void Vdut___024unit::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

Vdut___024unit::~Vdut___024unit() {
}
