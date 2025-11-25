// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vdut__Syms.h"


VL_ATTR_COLD void Vdut___024root__trace_init_sub__TOP__0(Vdut___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBit(c+70,"rst", false,-1);
    tracep->pushNamePrefix("top ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBit(c+70,"rst", false,-1);
    tracep->declBit(c+1,"PCSrc", false,-1);
    tracep->declBus(c+2,"ALU_result", false,-1, 31,0);
    tracep->declBus(c+3,"imm_ext", false,-1, 31,0);
    tracep->declBus(c+4,"instr", false,-1, 31,0);
    tracep->declBus(c+5,"pc_out4", false,-1, 31,0);
    tracep->declBus(c+6,"pc_out", false,-1, 31,0);
    tracep->declBus(c+7,"result_src", false,-1, 1,0);
    tracep->declBus(c+71,"result_final", false,-1, 31,0);
    tracep->declBit(c+8,"write_en", false,-1);
    tracep->declBus(c+9,"alu_control", false,-1, 3,0);
    tracep->declBit(c+10,"alu_srcA", false,-1);
    tracep->declBit(c+11,"alu_srcB", false,-1);
    tracep->declBit(c+12,"zero", false,-1);
    tracep->declBit(c+13,"alu_result_0", false,-1);
    tracep->declBit(c+14,"sign_ext_flag", false,-1);
    tracep->declBus(c+15,"r_out1", false,-1, 31,0);
    tracep->declBus(c+16,"r_out2", false,-1, 31,0);
    tracep->declBus(c+17,"type_control", false,-1, 1,0);
    tracep->declBit(c+18,"PCTargetSrc", false,-1);
    tracep->pushNamePrefix("decode ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBit(c+70,"rst", false,-1);
    tracep->declBus(c+4,"instr", false,-1, 31,0);
    tracep->declBus(c+71,"data_in", false,-1, 31,0);
    tracep->declBit(c+1,"PCSrc", false,-1);
    tracep->declBit(c+18,"PCTargetSrc", false,-1);
    tracep->declBus(c+7,"result_src", false,-1, 1,0);
    tracep->declBit(c+8,"mem_write", false,-1);
    tracep->declBus(c+9,"alu_control", false,-1, 3,0);
    tracep->declBit(c+10,"alu_srcA", false,-1);
    tracep->declBit(c+11,"alu_srcB", false,-1);
    tracep->declBit(c+12,"zero", false,-1);
    tracep->declBit(c+13,"alu_result_0", false,-1);
    tracep->declBit(c+14,"sign_ext_flag", false,-1);
    tracep->declBus(c+3,"imm_ext", false,-1, 31,0);
    tracep->declBus(c+15,"r_out1", false,-1, 31,0);
    tracep->declBus(c+16,"r_out2", false,-1, 31,0);
    tracep->declBus(c+17,"type_control", false,-1, 1,0);
    tracep->declBit(c+19,"write_en", false,-1);
    tracep->declBus(c+20,"imm_src", false,-1, 2,0);
    tracep->declBus(c+21,"a1", false,-1, 4,0);
    tracep->declBus(c+22,"a2", false,-1, 4,0);
    tracep->declBus(c+23,"a3", false,-1, 4,0);
    tracep->pushNamePrefix("control_unit ");
    tracep->declBus(c+4,"instr", false,-1, 31,0);
    tracep->declBit(c+12,"alu_zero", false,-1);
    tracep->declBit(c+13,"alu_result_0", false,-1);
    tracep->declBus(c+9,"ALUControl", false,-1, 3,0);
    tracep->declBit(c+11,"ALUSrcB", false,-1);
    tracep->declBit(c+10,"ALUSrcA", false,-1);
    tracep->declBit(c+8,"MemWrite", false,-1);
    tracep->declBit(c+19,"RegWrite", false,-1);
    tracep->declBus(c+7,"ResultSrc", false,-1, 1,0);
    tracep->declBus(c+20,"ImmSrc", false,-1, 2,0);
    tracep->declBus(c+17,"memSize", false,-1, 1,0);
    tracep->declBit(c+14,"memUnsigned", false,-1);
    tracep->declBit(c+1,"PCSrc", false,-1);
    tracep->declBit(c+18,"PCTargetSrc", false,-1);
    tracep->declBus(c+24,"opcode", false,-1, 6,0);
    tracep->declBus(c+25,"funct3", false,-1, 2,0);
    tracep->declBit(c+26,"funct7_5", false,-1);
    tracep->declBit(c+27,"Branch", false,-1);
    tracep->declBit(c+28,"Jump", false,-1);
    tracep->declBus(c+29,"branchType", false,-1, 2,0);
    tracep->declBus(c+30,"aluOp", false,-1, 1,0);
    tracep->declBit(c+31,"branch_taken", false,-1);
    tracep->pushNamePrefix("alu_dec ");
    tracep->declBus(c+30,"aluOp", false,-1, 1,0);
    tracep->declBus(c+25,"funct3", false,-1, 2,0);
    tracep->declBit(c+26,"funct7_5", false,-1);
    tracep->declBus(c+24,"opcode", false,-1, 6,0);
    tracep->declBus(c+9,"aluControl", false,-1, 3,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("branch_comp ");
    tracep->declBit(c+12,"zero", false,-1);
    tracep->declBit(c+13,"alu_result_0", false,-1);
    tracep->declBus(c+29,"branchType", false,-1, 2,0);
    tracep->declBit(c+27,"Branch", false,-1);
    tracep->declBit(c+31,"branch_taken", false,-1);
    tracep->popNamePrefix(2);
    tracep->pushNamePrefix("regfile ");
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBit(c+19,"write_en", false,-1);
    tracep->declBit(c+70,"rst", false,-1);
    tracep->declBus(c+21,"a1", false,-1, 4,0);
    tracep->declBus(c+22,"a2", false,-1, 4,0);
    tracep->declBus(c+23,"a3", false,-1, 4,0);
    tracep->declBus(c+71,"din", false,-1, 31,0);
    tracep->declBus(c+15,"rout1", false,-1, 31,0);
    tracep->declBus(c+16,"rout2", false,-1, 31,0);
    for (int i = 0; i < 32; ++i) {
        tracep->declBus(c+32+i*1,"register", true,(i+0), 31,0);
    }
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("sign_extend ");
    tracep->declBus(c+20,"immSrc", false,-1, 2,0);
    tracep->declBus(c+4,"instr", false,-1, 31,0);
    tracep->declBus(c+3,"imm_ext", false,-1, 31,0);
    tracep->popNamePrefix(2);
    tracep->pushNamePrefix("execute ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBus(c+6,"pc", false,-1, 31,0);
    tracep->declBus(c+5,"pc4", false,-1, 31,0);
    tracep->declBit(c+12,"zero", false,-1);
    tracep->declBus(c+9,"alu_control", false,-1, 3,0);
    tracep->declBit(c+10,"alu_srcA", false,-1);
    tracep->declBit(c+11,"alu_srcB", false,-1);
    tracep->declBit(c+14,"sign_ext_flag", false,-1);
    tracep->declBus(c+15,"r_out1", false,-1, 31,0);
    tracep->declBus(c+16,"r_out2", false,-1, 31,0);
    tracep->declBus(c+3,"imm_ext", false,-1, 31,0);
    tracep->declBit(c+8,"write_en", false,-1);
    tracep->declBus(c+17,"type_control", false,-1, 1,0);
    tracep->declBus(c+7,"result_src", false,-1, 1,0);
    tracep->declBus(c+71,"result", false,-1, 31,0);
    tracep->declBus(c+2,"ALU_out", false,-1, 31,0);
    tracep->declBus(c+64,"inA", false,-1, 31,0);
    tracep->declBus(c+65,"inB", false,-1, 31,0);
    tracep->declBus(c+72,"read_data", false,-1, 31,0);
    tracep->pushNamePrefix("alu ");
    tracep->declBus(c+73,"WIDTH", false,-1, 31,0);
    tracep->declBus(c+64,"inA", false,-1, 31,0);
    tracep->declBus(c+65,"inB", false,-1, 31,0);
    tracep->declBus(c+9,"alu_op", false,-1, 3,0);
    tracep->declBit(c+12,"zero", false,-1);
    tracep->declBus(c+2,"result", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("aluA ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBus(c+15,"in0", false,-1, 31,0);
    tracep->declBus(c+6,"in1", false,-1, 31,0);
    tracep->declBit(c+10,"sel", false,-1);
    tracep->declBus(c+64,"out", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("aluB ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBus(c+16,"in0", false,-1, 31,0);
    tracep->declBus(c+3,"in1", false,-1, 31,0);
    tracep->declBit(c+11,"sel", false,-1);
    tracep->declBus(c+65,"out", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("datamem ");
    tracep->declBus(c+74,"mem_size", false,-1, 31,0);
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBit(c+8,"write_en", false,-1);
    tracep->declBus(c+17,"type_control", false,-1, 1,0);
    tracep->declBus(c+2,"addr", false,-1, 31,0);
    tracep->declBus(c+16,"din", false,-1, 31,0);
    tracep->declBit(c+14,"sign_ext", false,-1);
    tracep->declBus(c+72,"dout", false,-1, 31,0);
    tracep->popNamePrefix(2);
    tracep->pushNamePrefix("fetch ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBit(c+70,"rst", false,-1);
    tracep->declBit(c+1,"PCSrc", false,-1);
    tracep->declBus(c+3,"ImmExt", false,-1, 31,0);
    tracep->declBit(c+18,"PCTargetSrc", false,-1);
    tracep->declBus(c+15,"r1_val", false,-1, 31,0);
    tracep->declBus(c+4,"Instr", false,-1, 31,0);
    tracep->declBus(c+5,"pc_out4", false,-1, 31,0);
    tracep->declBus(c+6,"pc_out", false,-1, 31,0);
    tracep->declBus(c+66,"PC_next", false,-1, 31,0);
    tracep->declBus(c+67,"PC_target", false,-1, 31,0);
    tracep->declBus(c+68,"PCTargetOp", false,-1, 31,0);
    tracep->pushNamePrefix("PC_imm ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBus(c+3,"in0", false,-1, 31,0);
    tracep->declBus(c+68,"in1", false,-1, 31,0);
    tracep->declBus(c+67,"out", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("PC_plus4 ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBus(c+6,"in0", false,-1, 31,0);
    tracep->declBus(c+75,"in1", false,-1, 31,0);
    tracep->declBus(c+5,"out", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("PC_reg ");
    tracep->declBus(c+73,"DATA_WIDTH", false,-1, 31,0);
    tracep->declBit(c+69,"clk", false,-1);
    tracep->declBit(c+70,"rst", false,-1);
    tracep->declBus(c+66,"pc_next", false,-1, 31,0);
    tracep->declBus(c+6,"pc_out", false,-1, 31,0);
    tracep->declBus(c+6,"PC", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("instrMem ");
    tracep->declBus(c+6,"addr", false,-1, 31,0);
    tracep->declBus(c+4,"instr", false,-1, 31,0);
    tracep->popNamePrefix(3);
}

VL_ATTR_COLD void Vdut___024root__trace_init_top(Vdut___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_init_top\n"); );
    // Body
    Vdut___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vdut___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vdut___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vdut___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vdut___024root__trace_register(Vdut___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&Vdut___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&Vdut___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&Vdut___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vdut___024root__trace_full_sub_0(Vdut___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vdut___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_full_top_0\n"); );
    // Init
    Vdut___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vdut___024root*>(voidSelf);
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vdut___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vdut___024root__trace_full_sub_0(Vdut___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump) 
                           | ((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch) 
                              & (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken)))));
    bufp->fullIData(oldp+2,(vlSelf->top__DOT__ALU_result),32);
    bufp->fullIData(oldp+3,(vlSelf->top__DOT__imm_ext),32);
    bufp->fullIData(oldp+4,(vlSelf->top__DOT__instr),32);
    bufp->fullIData(oldp+5,(((IData)(4U) + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC)),32);
    bufp->fullIData(oldp+6,(vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC),32);
    bufp->fullCData(oldp+7,(vlSelf->top__DOT__result_src),2);
    bufp->fullBit(oldp+8,(vlSelf->top__DOT__write_en));
    bufp->fullCData(oldp+9,(vlSelf->top__DOT__alu_control),4);
    bufp->fullBit(oldp+10,(vlSelf->top__DOT__alu_srcA));
    bufp->fullBit(oldp+11,(vlSelf->top__DOT__alu_srcB));
    bufp->fullBit(oldp+12,((1U & (~ (IData)((0U != vlSelf->top__DOT__ALU_result))))));
    bufp->fullBit(oldp+13,((1U & vlSelf->top__DOT__ALU_result)));
    bufp->fullBit(oldp+14,(vlSelf->top__DOT__sign_ext_flag));
    bufp->fullIData(oldp+15,(vlSelf->top__DOT__r_out1),32);
    bufp->fullIData(oldp+16,(vlSelf->top__DOT__r_out2),32);
    bufp->fullCData(oldp+17,(vlSelf->top__DOT__type_control),2);
    bufp->fullBit(oldp+18,(vlSelf->top__DOT__PCTargetSrc));
    bufp->fullBit(oldp+19,(vlSelf->top__DOT__decode__DOT__write_en));
    bufp->fullCData(oldp+20,(vlSelf->top__DOT__decode__DOT__imm_src),3);
    bufp->fullCData(oldp+21,((0x1fU & (vlSelf->top__DOT__instr 
                                       >> 0xfU))),5);
    bufp->fullCData(oldp+22,((0x1fU & (vlSelf->top__DOT__instr 
                                       >> 0x14U))),5);
    bufp->fullCData(oldp+23,((0x1fU & (vlSelf->top__DOT__instr 
                                       >> 7U))),5);
    bufp->fullCData(oldp+24,((0x7fU & vlSelf->top__DOT__instr)),7);
    bufp->fullCData(oldp+25,((7U & (vlSelf->top__DOT__instr 
                                    >> 0xcU))),3);
    bufp->fullBit(oldp+26,((1U & (vlSelf->top__DOT__instr 
                                  >> 0x1eU))));
    bufp->fullBit(oldp+27,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch));
    bufp->fullBit(oldp+28,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump));
    bufp->fullCData(oldp+29,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branchType),3);
    bufp->fullCData(oldp+30,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__aluOp),2);
    bufp->fullBit(oldp+31,(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken));
    bufp->fullIData(oldp+32,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[0]),32);
    bufp->fullIData(oldp+33,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[1]),32);
    bufp->fullIData(oldp+34,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[2]),32);
    bufp->fullIData(oldp+35,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[3]),32);
    bufp->fullIData(oldp+36,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[4]),32);
    bufp->fullIData(oldp+37,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[5]),32);
    bufp->fullIData(oldp+38,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[6]),32);
    bufp->fullIData(oldp+39,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[7]),32);
    bufp->fullIData(oldp+40,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[8]),32);
    bufp->fullIData(oldp+41,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[9]),32);
    bufp->fullIData(oldp+42,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[10]),32);
    bufp->fullIData(oldp+43,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[11]),32);
    bufp->fullIData(oldp+44,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[12]),32);
    bufp->fullIData(oldp+45,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[13]),32);
    bufp->fullIData(oldp+46,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[14]),32);
    bufp->fullIData(oldp+47,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[15]),32);
    bufp->fullIData(oldp+48,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[16]),32);
    bufp->fullIData(oldp+49,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[17]),32);
    bufp->fullIData(oldp+50,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[18]),32);
    bufp->fullIData(oldp+51,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[19]),32);
    bufp->fullIData(oldp+52,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[20]),32);
    bufp->fullIData(oldp+53,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[21]),32);
    bufp->fullIData(oldp+54,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[22]),32);
    bufp->fullIData(oldp+55,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[23]),32);
    bufp->fullIData(oldp+56,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[24]),32);
    bufp->fullIData(oldp+57,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[25]),32);
    bufp->fullIData(oldp+58,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[26]),32);
    bufp->fullIData(oldp+59,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[27]),32);
    bufp->fullIData(oldp+60,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[28]),32);
    bufp->fullIData(oldp+61,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[29]),32);
    bufp->fullIData(oldp+62,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[30]),32);
    bufp->fullIData(oldp+63,(vlSelf->top__DOT__decode__DOT__regfile__DOT__register[31]),32);
    bufp->fullIData(oldp+64,(vlSelf->top__DOT__execute__DOT__inA),32);
    bufp->fullIData(oldp+65,(vlSelf->top__DOT__execute__DOT__inB),32);
    bufp->fullIData(oldp+66,((((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Jump) 
                               | ((IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__Branch) 
                                  & (IData)(vlSelf->top__DOT__decode__DOT__control_unit__DOT__branch_taken)))
                               ? (vlSelf->top__DOT__imm_ext 
                                  + ((IData)(vlSelf->top__DOT__PCTargetSrc)
                                      ? vlSelf->top__DOT__r_out1
                                      : vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))
                               : ((IData)(4U) + vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))),32);
    bufp->fullIData(oldp+67,((vlSelf->top__DOT__imm_ext 
                              + ((IData)(vlSelf->top__DOT__PCTargetSrc)
                                  ? vlSelf->top__DOT__r_out1
                                  : vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC))),32);
    bufp->fullIData(oldp+68,(((IData)(vlSelf->top__DOT__PCTargetSrc)
                               ? vlSelf->top__DOT__r_out1
                               : vlSelf->top__DOT__fetch__DOT__PC_reg__DOT__PC)),32);
    bufp->fullBit(oldp+69,(vlSelf->clk));
    bufp->fullBit(oldp+70,(vlSelf->rst));
    bufp->fullIData(oldp+71,(((0U == (IData)(vlSelf->top__DOT__result_src))
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
                                          [(0x1ffU 
                                            & vlSelf->top__DOT__ALU_result)])
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
                                                  [
                                                  (0x1ffU 
                                                   & ((IData)(1U) 
                                                      + vlSelf->top__DOT__ALU_result))] 
                                                  << 8U) 
                                                 | vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                 [(0x1ffU 
                                                   & vlSelf->top__DOT__ALU_result)]))
                                           : ((2U == (IData)(vlSelf->top__DOT__type_control))
                                               ? ((
                                                   vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
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
    bufp->fullIData(oldp+72,(((0U == (IData)(vlSelf->top__DOT__type_control))
                               ? (((- (IData)(((IData)(vlSelf->top__DOT__sign_ext_flag) 
                                               & (vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                                  [
                                                  (0x1ffU 
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
                                       << 0x10U) | 
                                      ((vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                        [(0x1ffU & 
                                          ((IData)(1U) 
                                           + vlSelf->top__DOT__ALU_result))] 
                                        << 8U) | vlSelf->top__DOT__execute__DOT__datamem__DOT__memory
                                       [(0x1ffU & vlSelf->top__DOT__ALU_result)]))
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
    bufp->fullIData(oldp+73,(0x20U),32);
    bufp->fullIData(oldp+74,(0x200U),32);
    bufp->fullIData(oldp+75,(4U),32);
}
