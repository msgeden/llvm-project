; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

; This test used to cause an infinite loop in the load/store min/max bitcast
; transform.

define void @test(i32* %p, i32* %p2) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[V:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P2:%.*]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[V2]], [[V]]
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[CMP]], i32 [[V2]], i32 [[V]]
; CHECK-NEXT:    store i32 [[TMP1]], i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  %v = load i32, i32* %p, align 4
  %v2 = load i32, i32* %p2, align 4
  %cmp = icmp ult i32 %v2, %v
  %sel = select i1 %cmp, i32* %p2, i32* %p
  %p8 = bitcast i32* %p to i8*
  %sel8 = bitcast i32* %sel to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %p8, i8* align 4 %sel8, i64 4, i1 false)
  ret void
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #0

attributes #0 = { argmemonly nounwind willreturn }
