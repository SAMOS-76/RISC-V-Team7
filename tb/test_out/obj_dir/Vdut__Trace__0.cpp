// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vdut__Syms.h"


void Vdut___024root__trace_chg_sub_0(Vdut___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vdut___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_chg_top_0\n"); );
    // Init
    Vdut___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vdut___024root*>(voidSelf);
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vdut___024root__trace_chg_sub_0((&vlSymsp->TOP), bufp);
}

void Vdut___024root__trace_chg_sub_0(Vdut___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_chg_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        bufp->chgBit(oldp+0,(((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump) 
                              | ((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch) 
                                 & (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken)))));
        bufp->chgIData(oldp+1,(vlSelf->top__DOT__ALU_result),32);
        bufp->chgIData(oldp+2,(vlSelf->top__DOT__imm_ext),32);
        bufp->chgIData(oldp+3,(vlSelf->top__DOT__instr),32);
        bufp->chgIData(oldp+4,(((IData)(4U) + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC)),32);
        bufp->chgIData(oldp+5,(vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC),32);
        bufp->chgCData(oldp+6,(vlSelf->top__DOT__result_src),2);
        bufp->chgBit(oldp+7,(vlSelf->top__DOT__write_en));
        bufp->chgCData(oldp+8,(vlSelf->top__DOT__alu_control),4);
        bufp->chgBit(oldp+9,(vlSelf->top__DOT__alu_srcA));
        bufp->chgBit(oldp+10,(vlSelf->top__DOT__alu_srcB));
        bufp->chgBit(oldp+11,((1U & (~ (IData)((0U 
                                                != vlSelf->top__DOT__ALU_result))))));
        bufp->chgBit(oldp+12,((1U & vlSelf->top__DOT__ALU_result)));
        bufp->chgBit(oldp+13,(vlSelf->top__DOT__sign_ext_flag));
        bufp->chgIData(oldp+14,(vlSelf->top__DOT__r_out1),32);
        bufp->chgIData(oldp+15,(vlSelf->top__DOT__r_out2),32);
        bufp->chgCData(oldp+16,(vlSelf->top__DOT__type_control),2);
        bufp->chgBit(oldp+17,(vlSelf->top__DOT__PCTargetSrc));
        bufp->chgBit(oldp+18,(vlSelf->top__DOT__decode__DOT__write_en));
        bufp->chgCData(oldp+19,(vlSelf->top__DOT__decode__DOT__imm_src),3);
        bufp->chgCData(oldp+20,((0x1fU & (vlSelf->top__DOT__instr 
                                          >> 0xfU))),5);
        bufp->chgCData(oldp+21,((0x1fU & (vlSelf->top__DOT__instr 
                                          >> 0x14U))),5);
        bufp->chgCData(oldp+22,((0x1fU & (vlSelf->top__DOT__instr 
                                          >> 7U))),5);
        bufp->chgCData(oldp+23,((0x7fU & vlSelf->top__DOT__instr)),7);
        bufp->chgCData(oldp+24,((7U & (vlSelf->top__DOT__instr 
                                       >> 0xcU))),3);
        bufp->chgBit(oldp+25,((1U & (vlSelf->top__DOT__instr 
                                     >> 0x1eU))));
        bufp->chgBit(oldp+26,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch));
        bufp->chgBit(oldp+27,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump));
        bufp->chgCData(oldp+28,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branchType),3);
        bufp->chgCData(oldp+29,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__aluOp),2);
        bufp->chgBit(oldp+30,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken));
        bufp->chgIData(oldp+31,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[0]),32);
        bufp->chgIData(oldp+32,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[1]),32);
        bufp->chgIData(oldp+33,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[2]),32);
        bufp->chgIData(oldp+34,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[3]),32);
        bufp->chgIData(oldp+35,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[4]),32);
        bufp->chgIData(oldp+36,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[5]),32);
        bufp->chgIData(oldp+37,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[6]),32);
        bufp->chgIData(oldp+38,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[7]),32);
        bufp->chgIData(oldp+39,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[8]),32);
        bufp->chgIData(oldp+40,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[9]),32);
        bufp->chgIData(oldp+41,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[10]),32);
        bufp->chgIData(oldp+42,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[11]),32);
        bufp->chgIData(oldp+43,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[12]),32);
        bufp->chgIData(oldp+44,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[13]),32);
        bufp->chgIData(oldp+45,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[14]),32);
        bufp->chgIData(oldp+46,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[15]),32);
        bufp->chgIData(oldp+47,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[16]),32);
        bufp->chgIData(oldp+48,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[17]),32);
        bufp->chgIData(oldp+49,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[18]),32);
        bufp->chgIData(oldp+50,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[19]),32);
        bufp->chgIData(oldp+51,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[20]),32);
        bufp->chgIData(oldp+52,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[21]),32);
        bufp->chgIData(oldp+53,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[22]),32);
        bufp->chgIData(oldp+54,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[23]),32);
        bufp->chgIData(oldp+55,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[24]),32);
        bufp->chgIData(oldp+56,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[25]),32);
        bufp->chgIData(oldp+57,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[26]),32);
        bufp->chgIData(oldp+58,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[27]),32);
        bufp->chgIData(oldp+59,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[28]),32);
        bufp->chgIData(oldp+60,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[29]),32);
        bufp->chgIData(oldp+61,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[30]),32);
        bufp->chgIData(oldp+62,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[31]),32);
        bufp->chgIData(oldp+63,(vlSelf->top__DOT__execute__DOT__inA),32);
        bufp->chgIData(oldp+64,(vlSelf->top__DOT__execute__DOT__inB),32);
        bufp->chgIData(oldp+65,((((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump) 
                                  | ((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch) 
                                     & (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken)))
                                  ? (vlSelf->top__DOT__imm_ext 
                                     + ((IData)(vlSelf->top__DOT__PCTargetSrc)
                                         ? vlSelf->top__DOT__r_out1
                                         : vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))
                                  : ((IData)(4U) + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))),32);
        bufp->chgIData(oldp+66,((vlSelf->top__DOT__imm_ext 
                                 + ((IData)(vlSelf->top__DOT__PCTargetSrc)
                                     ? vlSelf->top__DOT__r_out1
                                     : vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))),32);
        bufp->chgIData(oldp+67,(((IData)(vlSelf->top__DOT__PCTargetSrc)
                                  ? vlSelf->top__DOT__r_out1
                                  : vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC)),32);
    }
    bufp->chgBit(oldp+68,(vlSelf->clk));
    bufp->chgBit(oldp+69,(vlSelf->rst));
    bufp->chgIData(oldp+70,(((0U == (IData)(vlSelf->top__DOT__result_src))
                              ? vlSelf->top__DOT__ALU_result
                              : ((1U == (IData)(vlSelf->top__DOT__result_src))
                                  ? ((0U == (IData)(vlSelf->top__DOT__type_control))
                                      ? (((- (IData)(
                                                     ((IData)(vlSelf->top__DOT__sign_ext_flag) 
                                                      & (vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                         [
                                                         (0x1ffU 
                                                          & vlSelf->top__DOT__ALU_result)] 
                                                         >> 7U)))) 
                                          << 8U) | 
                                         vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                         [(0x1ffU & vlSelf->top__DOT__ALU_result)])
                                      : ((1U == (IData)(vlSelf->top__DOT__type_control))
                                          ? (((- (IData)(
                                                         ((IData)(vlSelf->top__DOT__sign_ext_flag) 
                                                          & (vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                             [
                                                             (0x1ffU 
                                                              & ((IData)(1U) 
                                                                 + vlSelf->top__DOT__ALU_result))] 
                                                             >> 7U)))) 
                                              << 0x10U) 
                                             | ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                 [(0x1ffU 
                                                   & ((IData)(1U) 
                                                      + vlSelf->top__DOT__ALU_result))] 
                                                 << 8U) 
                                                | vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                [(0x1ffU 
                                                  & vlSelf->top__DOT__ALU_result)]))
                                          : ((2U == (IData)(vlSelf->top__DOT__type_control))
                                              ? ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                  [
                                                  (0x1ffU 
                                                   & ((IData)(3U) 
                                                      + vlSelf->top__DOT__ALU_result))] 
                                                  << 0x18U) 
                                                 | ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                     [
                                                     (0x1ffU 
                                                      & ((IData)(2U) 
                                                         + vlSelf->top__DOT__ALU_result))] 
                                                     << 0x10U) 
                                                    | ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                        [
                                                        (0x1ffU 
                                                         & ((IData)(1U) 
                                                            + vlSelf->top__DOT__ALU_result))] 
                                                        << 8U) 
                                                       | vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                       [
                                                       (0x1ffU 
                                                        & vlSelf->top__DOT__ALU_result)])))
                                              : 0U)))
                                  : ((2U == (IData)(vlSelf->top__DOT__result_src))
                                      ? ((IData)(4U) 
                                         + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC)
                                      : vlSelf->top__DOT__ALU_result)))),32);
    bufp->chgIData(oldp+71,(((0U == (IData)(vlSelf->top__DOT__type_control))
                              ? (((- (IData)(((IData)(vlSelf->top__DOT__sign_ext_flag) 
                                              & (vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                 [(0x1ffU 
                                                   & vlSelf->top__DOT__ALU_result)] 
                                                 >> 7U)))) 
                                  << 8U) | vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                 [(0x1ffU & vlSelf->top__DOT__ALU_result)])
                              : ((1U == (IData)(vlSelf->top__DOT__type_control))
                                  ? (((- (IData)(((IData)(vlSelf->top__DOT__sign_ext_flag) 
                                                  & (vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                     [
                                                     (0x1ffU 
                                                      & ((IData)(1U) 
                                                         + vlSelf->top__DOT__ALU_result))] 
                                                     >> 7U)))) 
                                      << 0x10U) | (
                                                   (vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                    [
                                                    (0x1ffU 
                                                     & ((IData)(1U) 
                                                        + vlSelf->top__DOT__ALU_result))] 
                                                    << 8U) 
                                                   | vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                   [
                                                   (0x1ffU 
                                                    & vlSelf->top__DOT__ALU_result)]))
                                  : ((2U == (IData)(vlSelf->top__DOT__type_control))
                                      ? ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                          [(0x1ffU 
                                            & ((IData)(3U) 
                                               + vlSelf->top__DOT__ALU_result))] 
                                          << 0x18U) 
                                         | ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                             [(0x1ffU 
                                               & ((IData)(2U) 
                                                  + vlSelf->top__DOT__ALU_result))] 
                                             << 0x10U) 
                                            | ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                [(0x1ffU 
                                                  & ((IData)(1U) 
                                                     + vlSelf->top__DOT__ALU_result))] 
                                                << 8U) 
                                               | vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                               [(0x1ffU 
                                                 & vlSelf->top__DOT__ALU_result)])))
                                      : 0U)))),32);
}

void Vdut___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_cleanup\n"); );
    // Init
    Vdut___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vdut___024root*>(voidSelf);
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
