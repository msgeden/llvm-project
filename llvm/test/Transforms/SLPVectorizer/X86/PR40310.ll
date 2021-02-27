; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer -S -mtriple=x86_64-unknown-linux-gnu -mcpu=skylake < %s | FileCheck %s

define void @mainTest(i32 %param, i32 * %vals, i32 %len) {
; CHECK-LABEL: @mainTest(
; CHECK-NEXT:  bci_15.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <2 x i32> <i32 31, i32 undef>, i32 [[PARAM:%.*]], i32 1
; CHECK-NEXT:    br label [[BCI_15:%.*]]
; CHECK:       bci_15:
; CHECK-NEXT:    [[TMP1:%.*]] = phi <2 x i32> [ [[TMP7:%.*]], [[BCI_15]] ], [ [[TMP0]], [[BCI_15_PREHEADER:%.*]] ]
; CHECK-NEXT:    [[SHUFFLE:%.*]] = shufflevector <2 x i32> [[TMP1]], <2 x i32> undef, <16 x i32> <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1>
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <16 x i32> [[SHUFFLE]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <16 x i32> [[SHUFFLE]], i32 15
; CHECK-NEXT:    store atomic i32 [[TMP3]], i32* [[VALS:%.*]] unordered, align 4
; CHECK-NEXT:    [[TMP4:%.*]] = add <16 x i32> [[SHUFFLE]], <i32 15, i32 14, i32 13, i32 12, i32 11, i32 10, i32 9, i32 8, i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 -1>
; CHECK-NEXT:    [[TMP5:%.*]] = call i32 @llvm.experimental.vector.reduce.and.v16i32(<16 x i32> [[TMP4]])
; CHECK-NEXT:    [[OP_EXTRA:%.*]] = and i32 [[TMP5]], [[TMP2]]
; CHECK-NEXT:    [[V44:%.*]] = add i32 [[TMP2]], 16
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <2 x i32> undef, i32 [[V44]], i32 0
; CHECK-NEXT:    [[TMP7]] = insertelement <2 x i32> [[TMP6]], i32 [[OP_EXTRA]], i32 1
; CHECK-NEXT:    br i1 true, label [[BCI_15]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
bci_15.preheader:
  br label %bci_15

bci_15:                                       ; preds = %bci_15.preheader, %bci_15
  %local_0_ = phi i32 [ %v43, %bci_15 ], [ %param, %bci_15.preheader ]
  %local_4_ = phi i32 [ %v44, %bci_15 ], [ 31, %bci_15.preheader ]
  %v12 = add i32 %local_0_, -1
  store atomic i32 %local_0_, i32 * %vals unordered, align 4
  %v13 = add i32 %local_4_, 1
  %v14 = and i32 %local_4_, %v12
  %v15 = add i32 %local_4_, 2
  %v16 = and i32 %v13, %v14
  %v17 = add i32 %local_4_, 3
  %v18 = and i32 %v15, %v16
  %v19 = add i32 %local_4_, 4
  %v20 = and i32 %v17, %v18
  %v21 = add i32 %local_4_, 5
  %v22 = and i32 %v19, %v20
  %v23 = add i32 %local_4_, 6
  %v24 = and i32 %v21, %v22
  %v25 = add i32 %local_4_, 7
  %v26 = and i32 %v23, %v24
  %v27 = add i32 %local_4_, 8
  %v28 = and i32 %v25, %v26
  %v29 = add i32 %local_4_, 9
  %v30 = and i32 %v27, %v28
  %v31 = add i32 %local_4_, 10
  %v32 = and i32 %v29, %v30
  %v33 = add i32 %local_4_, 11
  %v34 = and i32 %v31, %v32
  %v35 = add i32 %local_4_, 12
  %v36 = and i32 %v33, %v34
  %v37 = add i32 %local_4_, 13
  %v38 = and i32 %v35, %v36
  %v39 = add i32 %local_4_, 14
  %v40 = and i32 %v37, %v38
  %v41 = add i32 %local_4_, 15
  %v42 = and i32 %v39, %v40
  %v43 = and i32 %v41, %v42
  %v44 = add i32 %local_4_, 16
  br i1 true, label %bci_15, label %loopexit

loopexit:
  ret void
}
