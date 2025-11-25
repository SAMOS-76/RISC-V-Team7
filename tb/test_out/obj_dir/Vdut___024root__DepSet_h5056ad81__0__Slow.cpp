// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdut.h for the primary calling header

#include "verilated.h"

#include "Vdut___024root.h"

VL_ATTR_COLD void Vdut___024root___initial__TOP__0(Vdut___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root___initial__TOP__0\n"); );
    // Body
    VL_READMEM_N(true, 8, 4096, 0, std::string{"pdf.hex"}
                 ,  &(vlSelf->top__DOT__fetch__DOT__instrMem__DOT__instructions)
                 , 0, ~0ULL);
}

extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_h2b8877be_0;
extern const VlUnpacked<CData/*1:0*/, 1024> Vdut__ConstPool__TABLE_hf6daef67_0;
extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_hbad56271_0;
extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_h17877086_0;
extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_h45afa79b_0;
extern const VlUnpacked<CData/*1:0*/, 1024> Vdut__ConstPool__TABLE_h895a5c46_0;
extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_h76770590_0;
extern const VlUnpacked<CData/*2:0*/, 1024> Vdut__ConstPool__TABLE_he496b500_0;
extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_hff092405_0;
extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_hacf877fb_0;
extern const VlUnpacked<CData/*2:0*/, 1024> Vdut__ConstPool__TABLE_ha28f1d8b_0;
extern const VlUnpacked<CData/*1:0*/, 1024> Vdut__ConstPool__TABLE_h10877b4f_0;
extern const VlUnpacked<CData/*0:0*/, 1024> Vdut__ConstPool__TABLE_h087dd5e0_0;
extern const VlUnpacked<CData/*0:0*/, 64> Vdut__ConstPool__TABLE_h05c95355_0;

VL_ATTR_COLD void Vdut___024root___settle__TOP__0(Vdut___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root___settle__TOP__0\n"); );
    // Init
    SData/*9:0*/ __Vtableidx1;
    CData/*5:0*/ __Vtableidx2;
    // Body
    vlSelf->top__DOT__instr = ((vlSelf->top__DOT__fetch__DOT__instrMem__DOT__instructions
                                [(0xfffU & ((IData)(3U) 
                                            + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))] 
                                << 0x18U) | ((vlSelf->top__DOT__fetch__DOT__instrMem__DOT__instructions
                                              [(0xfffU 
                                                & ((IData)(2U) 
                                                   + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))] 
                                              << 0x10U) 
                                             | ((vlSelf->top__DOT__fetch__DOT__instrMem__DOT__instructions
                                                 [(0xfffU 
                                                   & ((IData)(1U) 
                                                      + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))] 
                                                 << 8U) 
                                                | vlSelf->top__DOT__fetch__DOT__instrMem__DOT__instructions
                                                [(0xfffU 
                                                  & vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC)])));
    vlSelf->top__DOT__r_out2 = ((0U == (0x1fU & (vlSelf->top__DOT__instr 
                                                 >> 0x14U)))
                                 ? 0U : vlSelf->top__DOT__decode__DOT__regfile__DOT__register
                                [(0x1fU & (vlSelf->top__DOT__instr 
                                           >> 0x14U))]);
    vlSelf->top__DOT__r_out1 = ((0U == (0x1fU & (vlSelf->top__DOT__instr 
                                                 >> 0xfU)))
                                 ? 0U : vlSelf->top__DOT__decode__DOT__regfile__DOT__register
                                [(0x1fU & (vlSelf->top__DOT__instr 
                                           >> 0xfU))]);
    __Vtableidx1 = ((0x380U & (vlSelf->top__DOT__instr 
                               >> 5U)) | (0x7fU & vlSelf->top__DOT__instr));
    vlSelf->top__DOT__decode__DOT__write_en = Vdut__ConstPool__TABLE_h2b8877be_0
        [__Vtableidx1];
    vlSelf->top__DOT__result_src = Vdut__ConstPool__TABLE_hf6daef67_0
        [__Vtableidx1];
    vlSelf->top__DOT__alu_srcA = Vdut__ConstPool__TABLE_hbad56271_0
        [__Vtableidx1];
    vlSelf->top__DOT__alu_srcB = Vdut__ConstPool__TABLE_h17877086_0
        [__Vtableidx1];
    vlSelf->top__DOT__write_en = Vdut__ConstPool__TABLE_h45afa79b_0
        [__Vtableidx1];
    vlSelf->top__DOT__type_control = Vdut__ConstPool__TABLE_h895a5c46_0
        [__Vtableidx1];
    vlSelf->top__DOT__sign_ext_flag = Vdut__ConstPool__TABLE_h76770590_0
        [__Vtableidx1];
    vlSelf->top__DOT__decode__DOT__imm_src = Vdut__ConstPool__TABLE_he496b500_0
        [__Vtableidx1];
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch 
        = Vdut__ConstPool__TABLE_hff092405_0[__Vtableidx1];
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump 
        = Vdut__ConstPool__TABLE_hacf877fb_0[__Vtableidx1];
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__branchType 
        = Vdut__ConstPool__TABLE_ha28f1d8b_0[__Vtableidx1];
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__aluOp 
        = Vdut__ConstPool__TABLE_h10877b4f_0[__Vtableidx1];
    vlSelf->top__DOT__PCTargetSrc = Vdut__ConstPool__TABLE_h087dd5e0_0
        [__Vtableidx1];
    vlSelf->top__DOT__alu_control = ((0U == (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__aluOp))
                                      ? 0U : ((1U == (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__aluOp))
                                               ? ((0x4000U 
                                                   & vlSelf->top__DOT__instr)
                                                   ? 
                                                  ((0x2000U 
                                                    & vlSelf->top__DOT__instr)
                                                    ? 3U
                                                    : 2U)
                                                   : 8U)
                                               : ((2U 
                                                   == (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__aluOp))
                                                   ? 
                                                  ((0x4000U 
                                                    & vlSelf->top__DOT__instr)
                                                    ? 
                                                   ((0x2000U 
                                                     & vlSelf->top__DOT__instr)
                                                     ? 
                                                    ((0x1000U 
                                                      & vlSelf->top__DOT__instr)
                                                      ? 7U
                                                      : 6U)
                                                     : 
                                                    ((0x1000U 
                                                      & vlSelf->top__DOT__instr)
                                                      ? 
                                                     ((0x40000000U 
                                                       & vlSelf->top__DOT__instr)
                                                       ? 0xdU
                                                       : 5U)
                                                      : 4U))
                                                    : 
                                                   ((0x2000U 
                                                     & vlSelf->top__DOT__instr)
                                                     ? 
                                                    ((0x1000U 
                                                      & vlSelf->top__DOT__instr)
                                                      ? 3U
                                                      : 2U)
                                                     : 
                                                    ((0x1000U 
                                                      & vlSelf->top__DOT__instr)
                                                      ? 1U
                                                      : 
                                                     ((IData)(
                                                              (0x40000033U 
                                                               == 
                                                               (0x4000007fU 
                                                                & vlSelf->top__DOT__instr)))
                                                       ? 8U
                                                       : 0U))))
                                                   : 0U)));
    vlSelf->top__DOT__execute__DOT__inA = ((IData)(vlSelf->top__DOT__alu_srcA)
                                            ? vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC
                                            : vlSelf->top__DOT__r_out1);
    vlSelf->top__DOT__imm_ext = ((4U & (IData)(vlSelf->top__DOT__decode__DOT__imm_src))
                                  ? ((2U & (IData)(vlSelf->top__DOT__decode__DOT__imm_src))
                                      ? 0U : ((1U & (IData)(vlSelf->top__DOT__decode__DOT__imm_src))
                                               ? 0U
                                               : ((
                                                   (- (IData)(
                                                              (vlSelf->top__DOT__instr 
                                                               >> 0x1fU))) 
                                                   << 0x15U) 
                                                  | ((0x100000U 
                                                      & (vlSelf->top__DOT__instr 
                                                         >> 0xbU)) 
                                                     | ((0xff000U 
                                                         & vlSelf->top__DOT__instr) 
                                                        | ((0x800U 
                                                            & (vlSelf->top__DOT__instr 
                                                               >> 9U)) 
                                                           | (0x7feU 
                                                              & (vlSelf->top__DOT__instr 
                                                                 >> 0x14U))))))))
                                  : ((2U & (IData)(vlSelf->top__DOT__decode__DOT__imm_src))
                                      ? ((1U & (IData)(vlSelf->top__DOT__decode__DOT__imm_src))
                                          ? (0xfffff000U 
                                             & vlSelf->top__DOT__instr)
                                          : (((- (IData)(
                                                         (vlSelf->top__DOT__instr 
                                                          >> 0x1fU))) 
                                              << 0xdU) 
                                             | ((0x1000U 
                                                 & (vlSelf->top__DOT__instr 
                                                    >> 0x13U)) 
                                                | ((0x800U 
                                                    & (vlSelf->top__DOT__instr 
                                                       << 4U)) 
                                                   | ((0x7e0U 
                                                       & (vlSelf->top__DOT__instr 
                                                          >> 0x14U)) 
                                                      | (0x1eU 
                                                         & (vlSelf->top__DOT__instr 
                                                            >> 7U)))))))
                                      : ((1U & (IData)(vlSelf->top__DOT__decode__DOT__imm_src))
                                          ? (((- (IData)(
                                                         (vlSelf->top__DOT__instr 
                                                          >> 0x1fU))) 
                                              << 0xcU) 
                                             | ((0xfe0U 
                                                 & (vlSelf->top__DOT__instr 
                                                    >> 0x14U)) 
                                                | (0x1fU 
                                                   & (vlSelf->top__DOT__instr 
                                                      >> 7U))))
                                          : (((- (IData)(
                                                         (vlSelf->top__DOT__instr 
                                                          >> 0x1fU))) 
                                              << 0xcU) 
                                             | (vlSelf->top__DOT__instr 
                                                >> 0x14U)))));
    vlSelf->top__DOT__execute__DOT__inB = ((IData)(vlSelf->top__DOT__alu_srcB)
                                            ? vlSelf->top__DOT__imm_ext
                                            : vlSelf->top__DOT__r_out2);
    vlSelf->top__DOT__ALU_result = ((8U & (IData)(vlSelf->top__DOT__alu_control))
                                     ? ((4U & (IData)(vlSelf->top__DOT__alu_control))
                                         ? ((2U & (IData)(vlSelf->top__DOT__alu_control))
                                             ? 0U : 
                                            ((1U & (IData)(vlSelf->top__DOT__alu_control))
                                              ? VL_SHIFTRS_III(32,32,5, vlSelf->top__DOT__execute__DOT__inA, 
                                                               (0x1fU 
                                                                & vlSelf->top__DOT__execute__DOT__inB))
                                              : 0U))
                                         : ((2U & (IData)(vlSelf->top__DOT__alu_control))
                                             ? 0U : 
                                            ((1U & (IData)(vlSelf->top__DOT__alu_control))
                                              ? 0U : 
                                             (vlSelf->top__DOT__execute__DOT__inA 
                                              - vlSelf->top__DOT__execute__DOT__inB))))
                                     : ((4U & (IData)(vlSelf->top__DOT__alu_control))
                                         ? ((2U & (IData)(vlSelf->top__DOT__alu_control))
                                             ? ((1U 
                                                 & (IData)(vlSelf->top__DOT__alu_control))
                                                 ? 
                                                (vlSelf->top__DOT__execute__DOT__inA 
                                                 & vlSelf->top__DOT__execute__DOT__inB)
                                                 : 
                                                (vlSelf->top__DOT__execute__DOT__inA 
                                                 | vlSelf->top__DOT__execute__DOT__inB))
                                             : ((1U 
                                                 & (IData)(vlSelf->top__DOT__alu_control))
                                                 ? 
                                                (vlSelf->top__DOT__execute__DOT__inA 
                                                 >> 
                                                 (0x1fU 
                                                  & vlSelf->top__DOT__execute__DOT__inB))
                                                 : 
                                                (vlSelf->top__DOT__execute__DOT__inA 
                                                 ^ vlSelf->top__DOT__execute__DOT__inB)))
                                         : ((2U & (IData)(vlSelf->top__DOT__alu_control))
                                             ? ((1U 
                                                 & (IData)(vlSelf->top__DOT__alu_control))
                                                 ? 
                                                ((vlSelf->top__DOT__execute__DOT__inA 
                                                  < vlSelf->top__DOT__execute__DOT__inB)
                                                  ? 1U
                                                  : 0U)
                                                 : 
                                                (VL_LTS_III(32, vlSelf->top__DOT__execute__DOT__inA, vlSelf->top__DOT__execute__DOT__inB)
                                                  ? 1U
                                                  : 0U))
                                             : ((1U 
                                                 & (IData)(vlSelf->top__DOT__alu_control))
                                                 ? 
                                                (vlSelf->top__DOT__execute__DOT__inA 
                                                 << 
                                                 (0x1fU 
                                                  & vlSelf->top__DOT__execute__DOT__inB))
                                                 : 
                                                (vlSelf->top__DOT__execute__DOT__inA 
                                                 + vlSelf->top__DOT__execute__DOT__inB)))));
    __Vtableidx2 = ((0x20U & ((~ (IData)((0U != vlSelf->top__DOT__ALU_result))) 
                              << 5U)) | ((0x10U & (vlSelf->top__DOT__ALU_result 
                                                   << 4U)) 
                                         | (((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branchType) 
                                             << 1U) 
                                            | (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch))));
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken 
        = Vdut__ConstPool__TABLE_h05c95355_0[__Vtableidx2];
    vlSelf->top__DOT__fetch__DOT__PC_next = (((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump) 
                                              | ((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch) 
                                                 & (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken)))
                                              ? (vlSelf->top__DOT__imm_ext 
                                                 + 
                                                 ((IData)(vlSelf->top__DOT__PCTargetSrc)
                                                   ? vlSelf->top__DOT__r_out1
                                                   : vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))
                                              : ((IData)(4U) 
                                                 + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC));
}

VL_ATTR_COLD void Vdut___024root___eval_initial(Vdut___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root___eval_initial\n"); );
    // Body
    Vdut___024root___initial__TOP__0(vlSelf);
    vlSelf->__Vclklast__TOP__clk = vlSelf->clk;
    vlSelf->__Vclklast__TOP__rst = vlSelf->rst;
}

VL_ATTR_COLD void Vdut___024root___eval_settle(Vdut___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root___eval_settle\n"); );
    // Body
    Vdut___024root___settle__TOP__0(vlSelf);
    vlSelf->__Vm_traceActivity[1U] = 1U;
    vlSelf->__Vm_traceActivity[0U] = 1U;
}

VL_ATTR_COLD void Vdut___024root___final(Vdut___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root___final\n"); );
}

VL_ATTR_COLD void Vdut___024root___ctor_var_reset(Vdut___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->rst = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__ALU_result = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__imm_ext = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__instr = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__result_src = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__write_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__alu_control = VL_RAND_RESET_I(4);
    vlSelf->top__DOT__alu_srcA = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__alu_srcB = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__sign_ext_flag = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__r_out1 = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__r_out2 = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__type_control = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__PCTargetSrc = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__fetch__DOT__PC_next = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC = VL_RAND_RESET_I(32);
    for (int __Vi0=0; __Vi0<4096; ++__Vi0) {
        vlSelf->top__DOT__fetch__DOT__instrMem__DOT__instructions[__Vi0] = VL_RAND_RESET_I(8);
    }
    vlSelf->top__DOT__decode__DOT__write_en = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__decode__DOT__imm_src = VL_RAND_RESET_I(3);
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump = VL_RAND_RESET_I(1);
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__branchType = VL_RAND_RESET_I(3);
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__aluOp = VL_RAND_RESET_I(2);
    vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken = VL_RAND_RESET_I(1);
    for (int __Vi0=0; __Vi0<32; ++__Vi0) {
        vlSelf->top__DOT__decode__DOT__regfile__DOT__register[__Vi0] = VL_RAND_RESET_I(32);
    }
    vlSelf->top__DOT__execute__DOT__inA = VL_RAND_RESET_I(32);
    vlSelf->top__DOT__execute__DOT__inB = VL_RAND_RESET_I(32);
    for (int __Vi0=0; __Vi0<512; ++__Vi0) {
        vlSelf->top__DOT__execute__DOT__datamem__DOT__memory[__Vi0] = VL_RAND_RESET_I(8);
    }
    vlSelf->__Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v0 = 0;
    vlSelf->__Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v0 = VL_RAND_RESET_I(8);
    vlSelf->__Vdlyvset__top__DOT__execute__DOT__datamem__DOT__memory__v0 = 0;
    vlSelf->__Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v1 = 0;
    vlSelf->__Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v1 = VL_RAND_RESET_I(8);
    vlSelf->__Vdlyvset__top__DOT__execute__DOT__datamem__DOT__memory__v1 = 0;
    vlSelf->__Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v2 = 0;
    vlSelf->__Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v2 = VL_RAND_RESET_I(8);
    vlSelf->__Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v3 = 0;
    vlSelf->__Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v3 = VL_RAND_RESET_I(8);
    vlSelf->__Vdlyvset__top__DOT__execute__DOT__datamem__DOT__memory__v3 = 0;
    vlSelf->__Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v4 = 0;
    vlSelf->__Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v4 = VL_RAND_RESET_I(8);
    vlSelf->__Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v5 = 0;
    vlSelf->__Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v5 = VL_RAND_RESET_I(8);
    vlSelf->__Vdlyvdim0__top__DOT__execute__DOT__datamem__DOT__memory__v6 = 0;
    vlSelf->__Vdlyvval__top__DOT__execute__DOT__datamem__DOT__memory__v6 = VL_RAND_RESET_I(8);
    for (int __Vi0=0; __Vi0<2; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }
}
