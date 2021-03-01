//===- SORA.cpp - Example code from "Writing an LLVM Pass" ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements two versions of the LLVM "Hello World" pass described
// in docs/WritingAnLLVMPass.html
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/Statistic.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Pass.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/DIBuilder.h"
#include "llvm/Support/raw_ostream.h"

#include <iostream>
#include <sstream>
#include <string>
#include <fstream>

using namespace llvm;

#define DEBUG_TYPE "sora"

STATISTIC(TotalVariableCounter, "Counts all local variables");

namespace {
std::string getHomePath(){
    std::string Path(getenv("HOME"));
    return Path;
}
class SORAVariableCounter : public ModulePass {
public:
    static char ID; // Pass identification, replacement for typeid
    std::ofstream file;
    SORAVariableCounter() : ModulePass(ID) {}
    bool runOnModule(Module &M) override {
        std::string ModuleStr=M.getName().str();
        std::size_t LastIndex=ModuleStr.rfind("/");
        std::string FilePath=getHomePath()+"/LLVM/Files/count" + ModuleStr.substr(LastIndex+1) +".tsv";
        file.open(FilePath);
        outs() << "Stats for" << M.getName() << "\n";
        file << "Stats for" << M.getName().str() << "\n";
        outs() << "Function" << "\t" << "Variable" << "\t" << "Address" << "\t" << "Argument" << "\n";
        file << "Function" << "\t" << "Variable" << "\t" << "Address" << "\t" << "Argument" << "\n";
        for (Function &F:M){
            int ArgCount=0;
            int LocalVarCount=0;
            int StackAddressCount=0;
            if (F.empty())
                continue;
            ArgCount=F.arg_size();
            for (auto I = inst_begin(F); I!=inst_end(F);++I){
                Instruction* Inst=&*I;
                if (AllocaInst* Alloca = dyn_cast<AllocaInst>(Inst)) {
                    LocalVarCount++;
                    Type* Type=Alloca->getAllocatedType();
                    if (isa<ArrayType>(Type))
                        StackAddressCount+=Type->getArrayNumElements();
                    else
                        StackAddressCount++;
                }
            }
            outs() << F.getName() << "\t" << LocalVarCount << "\t" << StackAddressCount << "\t" << ArgCount << "\n";
            file << F.getName().str() << "\t" << LocalVarCount << "\t" << StackAddressCount << "\t" << ArgCount << "\n";
        }
        file.close();
        return false;
    }
};
}

char SORAVariableCounter::ID = 0;
static RegisterPass<SORAVariableCounter> X("sora-counter", "Pass that counts the number of variables and addresses for a function");

namespace {
struct SORACCModifier : public FunctionPass {
    static char ID; // Pass identification, replacement for typeid
    SORACCModifier() : FunctionPass(ID) {}
    
    bool runOnFunction(Function &F) override {
        
//        Instruction &Entry=F.getEntryBlock().front();
//        Function* Sip=F.getParent()->getFunction("siphash24");
//        Value* Address;
//        Value* Size;
//        std::vector<Value*> ArgsVector;
//        Argument* arg1;
//        ArgsVector.push_back(Address);
//        ArgsVector.push_back(Size);
//        ArrayRef<Value*> Args(ArgsVector);
//
//        Instruction *SipCall = CallInst::Create(Sip->getFunctionType(),Sip);
//        outs() << "Sip Call:" << *SipCall << "\n";
//        Entry.getParent()->getInstList().insert(Entry.getIterator(), SipCall);
        bool hasCall=false;
        for (auto I = inst_begin(F); I!=inst_end(F);++I){
            Instruction* Inst=&*I;
            if (CallInst* Call = dyn_cast<CallInst>(Inst)) {
                hasCall=true;
                break;
            }
        }
        if (hasCall)
            F.setCallingConv(CallingConv::PreserveMost);
        outs() << F.getName() << "\n";
        return false;
    }
    
    // We don't modify the program, so we preserve all analyses.
    void getAnalysisUsage(AnalysisUsage &AU) const override {
        AU.setPreservesAll();
    }
};
}

char SORACCModifier::ID = 0;
static RegisterPass<SORACCModifier>
Y("sora-modifier", "Pass that replaces calling convention attribute of functions with preserve_most");

//static llvm::RegisterStandardPasses Z(
//    llvm::PassManagerBuilder::EP_EarlyAsPossible,
//    [](const llvm::PassManagerBuilder &Builder,
//       llvm::legacy::PassManagerBase &PM) { PM.add(new SORACCModifier()); });
