// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vdut.h for the primary calling header

#ifndef VERILATED_VDUT___024ROOT_H_
#define VERILATED_VDUT___024ROOT_H_  // guard

#include "verilated.h"

class Vdut__Syms;

class Vdut___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    CData/*1:0*/ top__DOT__result_src;
    CData/*0:0*/ top__DOT__write_en;
    CData/*3:0*/ top__DOT__alu_control;
    CData/*0:0*/ top__DOT__alu_srcA;
    CData/*0:0*/ top__DOT__alu_srcB;
    CData/*0:0*/ top__DOT__sign_ext_flag;
    CData/*1:0*/ top__DOT__type_control;
    CData/*0:0*/ top__DOT__PCTargetSrc;
    CData/*0:0*/ top__DOT__decode__DOT__write_en;
    CData/*2:0*/ top__DOT__decode__DOT__imm_src;
    CData/*0:0*/ top__DOT__decode__DOT__control_unit__DOT__Branch;
    CData/*0:0*/ top__DOT__decode__DOT__control_unit__DOT__Jump;
    CData/*2:0*/ top__DOT__decode__DOT__control_unit__DOT__branchType;
    CData/*1:0*/ top__DOT__decode__DOT__control_unit__DOT__aluOp;
    CData/*0:0*/ top__DOT__decode__DOT__control_unit__DOT__branch_taken;
    CData/*7:0*/ __Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v0;
    CData/*0:0*/ __Vdlyvset__top__DOT__execute__DOT__datamem__DOT__memory__v0;
    CData/*7:0*/ __Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v1;
    CData/*0:0*/ __Vdlyvset__top__DOT__execute__DOT__datamem__DOT__memory__v1;
    CData/*7:0*/ __Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v2;
    CData/*7:0*/ __Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v3;
    CData/*0:0*/ __Vdlyvset__top__DOT__execute__DOT__datamem__DOT__memory__v3;
    CData/*7:0*/ __Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v4;
    CData/*7:0*/ __Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v5;
    CData/*7:0*/ __Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v6;
    CData/*0:0*/ __Vclklast__TOP__clk;
    CData/*0:0*/ __Vclklast__TOP__rst;
    SData/*8:0*/ __Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v0;
    SData/*8:0*/ __Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v1;
    SData/*8:0*/ __Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v2;
    SData/*8:0*/ __Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v3;
    SData/*8:0*/ __Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v4;
    SData/*8:0*/ __Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v5;
    SData/*8:0*/ __Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v6;
    IData/*31:0*/ top__DOT__ALU_result;
    IData/*31:0*/ top__DOT__imm_ext;
    IData/*31:0*/ top__DOT__instr;
    IData/*31:0*/ top__DOT__r_out1;
    IData/*31:0*/ top__DOT__r_out2;
    IData/*31:0*/ top__DOT__fetch__DOT__PC_next;
    IData/*31:0*/ top__DOT__fetch__DOT__PC_reg__DOT__PC;
    IData/*31:0*/ top__DOT__execute__DOT__inA;
    IData/*31:0*/ top__DOT__execute__DOT__inB;
    VlUnpacked<CData/*7:0*/, 4096> top__DOT__fetch__DOT__instrMem__DOT__instructions;
    VlUnpacked<IData/*31:0*/, 32> top__DOT__decode__DOT__regfile__DOT__register;
    VlUnpacked<CData/*7:0*/, 512> top__DOT__execute__DOT__datamem__DOT__memory;
    VlUnpacked<CData/*0:0*/, 2> __Vm_traceActivity;

    // INTERNAL VARIABLES
    Vdut__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vdut___024root(Vdut__Syms* symsp, const char* name);
    ~Vdut___024root();
    VL_UNCOPYABLE(Vdut___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
