// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vdut.h for the primary calling header

#ifndef VERILATED_VDUT___024UNIT_H_
#define VERILATED_VDUT___024UNIT_H_  // guard

#include "verilated.h"

class Vdut__Syms;

class Vdut___024unit final : public VerilatedModule {
  public:

    // INTERNAL VARIABLES
    Vdut__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vdut___024unit(Vdut__Syms* symsp, const char* name);
    ~Vdut___024unit();
    VL_UNCOPYABLE(Vdut___024unit);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
