; ModuleID = 'dot_avx512.c'
source_filename = "dot_avx512.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree nosync nounwind readonly uwtable
define dso_local float @dot_avx512(ptr noundef readonly %0, ptr noundef readonly %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = icmp ult i64 %2, 64
  br i1 %4, label %38, label %5

5:                                                ; preds = %3, %5
  %6 = phi i64 [ %32, %5 ], [ 64, %3 ]
  %7 = phi <16 x float> [ %16, %5 ], [ zeroinitializer, %3 ]
  %8 = phi <16 x float> [ %21, %5 ], [ zeroinitializer, %3 ]
  %9 = phi <16 x float> [ %26, %5 ], [ zeroinitializer, %3 ]
  %10 = phi <16 x float> [ %31, %5 ], [ zeroinitializer, %3 ]
  %11 = phi i64 [ %6, %5 ], [ 0, %3 ]
  %12 = getelementptr inbounds float, ptr %0, i64 %11
  %13 = load <16 x float>, ptr %12, align 1, !tbaa !5
  %14 = getelementptr inbounds float, ptr %1, i64 %11
  %15 = load <16 x float>, ptr %14, align 1, !tbaa !5
  %16 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %13, <16 x float> %15, <16 x float> %7)
  %17 = getelementptr inbounds float, ptr %12, i64 16
  %18 = load <16 x float>, ptr %17, align 1, !tbaa !5
  %19 = getelementptr inbounds float, ptr %14, i64 16
  %20 = load <16 x float>, ptr %19, align 1, !tbaa !5
  %21 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %18, <16 x float> %20, <16 x float> %8)
  %22 = getelementptr inbounds float, ptr %12, i64 32
  %23 = load <16 x float>, ptr %22, align 1, !tbaa !5
  %24 = getelementptr inbounds float, ptr %14, i64 32
  %25 = load <16 x float>, ptr %24, align 1, !tbaa !5
  %26 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %23, <16 x float> %25, <16 x float> %9)
  %27 = getelementptr inbounds float, ptr %12, i64 48
  %28 = load <16 x float>, ptr %27, align 1, !tbaa !5
  %29 = getelementptr inbounds float, ptr %14, i64 48
  %30 = load <16 x float>, ptr %29, align 1, !tbaa !5
  %31 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %28, <16 x float> %30, <16 x float> %10)
  %32 = add nuw i64 %6, 64
  %33 = icmp ugt i64 %32, %2
  br i1 %33, label %34, label %5, !llvm.loop !8

34:                                               ; preds = %5
  %35 = fadd <16 x float> %21, %16
  %36 = fadd <16 x float> %31, %26
  %37 = fadd <16 x float> %36, %35
  br label %38

38:                                               ; preds = %34, %3
  %39 = phi i64 [ 0, %3 ], [ %6, %34 ]
  %40 = phi <16 x float> [ zeroinitializer, %3 ], [ %37, %34 ]
  %41 = or i64 %39, 16
  %42 = icmp ugt i64 %41, %2
  br i1 %42, label %54, label %43

43:                                               ; preds = %38, %43
  %44 = phi i64 [ %52, %43 ], [ %41, %38 ]
  %45 = phi <16 x float> [ %51, %43 ], [ %40, %38 ]
  %46 = phi i64 [ %44, %43 ], [ %39, %38 ]
  %47 = getelementptr inbounds float, ptr %0, i64 %46
  %48 = load <16 x float>, ptr %47, align 1, !tbaa !5
  %49 = getelementptr inbounds float, ptr %1, i64 %46
  %50 = load <16 x float>, ptr %49, align 1, !tbaa !5
  %51 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %48, <16 x float> %50, <16 x float> %45)
  %52 = add i64 %44, 16
  %53 = icmp ugt i64 %52, %2
  br i1 %53, label %54, label %43, !llvm.loop !10

54:                                               ; preds = %43, %38
  %55 = phi i64 [ %39, %38 ], [ %44, %43 ]
  %56 = phi <16 x float> [ %40, %38 ], [ %51, %43 ]
  %57 = icmp eq i64 %55, %2
  br i1 %57, label %70, label %58

58:                                               ; preds = %54
  %59 = sub i64 %2, %55
  %60 = trunc i64 %59 to i32
  %61 = shl nsw i32 -1, %60
  %62 = trunc i32 %61 to i16
  %63 = xor i16 %62, -1
  %64 = getelementptr inbounds float, ptr %0, i64 %55
  %65 = bitcast i16 %63 to <16 x i1>
  %66 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr %64, i32 1, <16 x i1> %65, <16 x float> zeroinitializer)
  %67 = getelementptr inbounds float, ptr %1, i64 %55
  %68 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr %67, i32 1, <16 x i1> %65, <16 x float> zeroinitializer)
  %69 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %66, <16 x float> %68, <16 x float> %56)
  br label %70

70:                                               ; preds = %58, %54
  %71 = phi <16 x float> [ %69, %58 ], [ %56, %54 ]
  %72 = tail call reassoc float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %71)
  ret float %72
}

; Function Attrs: argmemonly nofree nosync nounwind uwtable
define dso_local void @gemv_avx512(ptr noundef %0, ptr noundef %1, ptr nocapture noundef writeonly %2, i64 noundef %3, i64 noundef %4) local_unnamed_addr #1 {
  %6 = icmp eq i64 %3, 0
  br i1 %6, label %148, label %7

7:                                                ; preds = %5
  %8 = icmp ult i64 %4, 64
  br i1 %8, label %9, label %149

9:                                                ; preds = %7
  %10 = icmp ult i64 %4, 16
  br i1 %10, label %11, label %113

11:                                               ; preds = %9
  %12 = icmp eq i64 %4, 0
  %13 = trunc i64 %4 to i32
  %14 = shl nsw i32 -1, %13
  %15 = trunc i32 %14 to i16
  %16 = xor i16 %15, -1
  %17 = bitcast i16 %16 to <16 x i1>
  br i1 %12, label %18, label %102

18:                                               ; preds = %11
  %19 = tail call reassoc float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> zeroinitializer)
  %20 = icmp ult i64 %3, 8
  br i1 %20, label %95, label %21

21:                                               ; preds = %18
  %22 = icmp ult i64 %3, 64
  br i1 %22, label %83, label %23

23:                                               ; preds = %21
  %24 = and i64 %3, -64
  %25 = insertelement <16 x float> poison, float %19, i64 0
  %26 = shufflevector <16 x float> %25, <16 x float> poison, <16 x i32> zeroinitializer
  %27 = insertelement <16 x float> poison, float %19, i64 0
  %28 = shufflevector <16 x float> %27, <16 x float> poison, <16 x i32> zeroinitializer
  %29 = insertelement <16 x float> poison, float %19, i64 0
  %30 = shufflevector <16 x float> %29, <16 x float> poison, <16 x i32> zeroinitializer
  %31 = insertelement <16 x float> poison, float %19, i64 0
  %32 = shufflevector <16 x float> %31, <16 x float> poison, <16 x i32> zeroinitializer
  %33 = add i64 %24, -64
  %34 = lshr exact i64 %33, 6
  %35 = add nuw nsw i64 %34, 1
  %36 = and i64 %35, 3
  %37 = icmp ult i64 %33, 192
  br i1 %37, label %65, label %38

38:                                               ; preds = %23
  %39 = and i64 %35, 576460752303423484
  br label %40

40:                                               ; preds = %40, %38
  %41 = phi i64 [ 0, %38 ], [ %62, %40 ]
  %42 = phi i64 [ 0, %38 ], [ %63, %40 ]
  %43 = getelementptr inbounds float, ptr %2, i64 %41
  store <16 x float> %26, ptr %43, align 4, !tbaa !11
  %44 = getelementptr inbounds float, ptr %43, i64 16
  store <16 x float> %28, ptr %44, align 4, !tbaa !11
  %45 = getelementptr inbounds float, ptr %43, i64 32
  store <16 x float> %30, ptr %45, align 4, !tbaa !11
  %46 = getelementptr inbounds float, ptr %43, i64 48
  store <16 x float> %32, ptr %46, align 4, !tbaa !11
  %47 = or i64 %41, 64
  %48 = getelementptr inbounds float, ptr %2, i64 %47
  store <16 x float> %26, ptr %48, align 4, !tbaa !11
  %49 = getelementptr inbounds float, ptr %48, i64 16
  store <16 x float> %28, ptr %49, align 4, !tbaa !11
  %50 = getelementptr inbounds float, ptr %48, i64 32
  store <16 x float> %30, ptr %50, align 4, !tbaa !11
  %51 = getelementptr inbounds float, ptr %48, i64 48
  store <16 x float> %32, ptr %51, align 4, !tbaa !11
  %52 = or i64 %41, 128
  %53 = getelementptr inbounds float, ptr %2, i64 %52
  store <16 x float> %26, ptr %53, align 4, !tbaa !11
  %54 = getelementptr inbounds float, ptr %53, i64 16
  store <16 x float> %28, ptr %54, align 4, !tbaa !11
  %55 = getelementptr inbounds float, ptr %53, i64 32
  store <16 x float> %30, ptr %55, align 4, !tbaa !11
  %56 = getelementptr inbounds float, ptr %53, i64 48
  store <16 x float> %32, ptr %56, align 4, !tbaa !11
  %57 = or i64 %41, 192
  %58 = getelementptr inbounds float, ptr %2, i64 %57
  store <16 x float> %26, ptr %58, align 4, !tbaa !11
  %59 = getelementptr inbounds float, ptr %58, i64 16
  store <16 x float> %28, ptr %59, align 4, !tbaa !11
  %60 = getelementptr inbounds float, ptr %58, i64 32
  store <16 x float> %30, ptr %60, align 4, !tbaa !11
  %61 = getelementptr inbounds float, ptr %58, i64 48
  store <16 x float> %32, ptr %61, align 4, !tbaa !11
  %62 = add nuw i64 %41, 256
  %63 = add i64 %42, 4
  %64 = icmp eq i64 %63, %39
  br i1 %64, label %65, label %40, !llvm.loop !13

65:                                               ; preds = %40, %23
  %66 = phi i64 [ 0, %23 ], [ %62, %40 ]
  %67 = icmp eq i64 %36, 0
  br i1 %67, label %78, label %68

68:                                               ; preds = %65, %68
  %69 = phi i64 [ %75, %68 ], [ %66, %65 ]
  %70 = phi i64 [ %76, %68 ], [ 0, %65 ]
  %71 = getelementptr inbounds float, ptr %2, i64 %69
  store <16 x float> %26, ptr %71, align 4, !tbaa !11
  %72 = getelementptr inbounds float, ptr %71, i64 16
  store <16 x float> %28, ptr %72, align 4, !tbaa !11
  %73 = getelementptr inbounds float, ptr %71, i64 32
  store <16 x float> %30, ptr %73, align 4, !tbaa !11
  %74 = getelementptr inbounds float, ptr %71, i64 48
  store <16 x float> %32, ptr %74, align 4, !tbaa !11
  %75 = add nuw i64 %69, 64
  %76 = add i64 %70, 1
  %77 = icmp eq i64 %76, %36
  br i1 %77, label %78, label %68, !llvm.loop !15

78:                                               ; preds = %68, %65
  %79 = icmp eq i64 %24, %3
  br i1 %79, label %148, label %80

80:                                               ; preds = %78
  %81 = and i64 %3, 56
  %82 = icmp eq i64 %81, 0
  br i1 %82, label %95, label %83

83:                                               ; preds = %21, %80
  %84 = phi i64 [ %24, %80 ], [ 0, %21 ]
  %85 = and i64 %3, -8
  %86 = insertelement <8 x float> poison, float %19, i64 0
  %87 = shufflevector <8 x float> %86, <8 x float> poison, <8 x i32> zeroinitializer
  br label %88

88:                                               ; preds = %88, %83
  %89 = phi i64 [ %84, %83 ], [ %91, %88 ]
  %90 = getelementptr inbounds float, ptr %2, i64 %89
  store <8 x float> %87, ptr %90, align 4, !tbaa !11
  %91 = add nuw i64 %89, 8
  %92 = icmp eq i64 %91, %85
  br i1 %92, label %93, label %88, !llvm.loop !17

93:                                               ; preds = %88
  %94 = icmp eq i64 %85, %3
  br i1 %94, label %148, label %95

95:                                               ; preds = %18, %80, %93
  %96 = phi i64 [ 0, %18 ], [ %24, %80 ], [ %85, %93 ]
  br label %97

97:                                               ; preds = %95, %97
  %98 = phi i64 [ %100, %97 ], [ %96, %95 ]
  %99 = getelementptr inbounds float, ptr %2, i64 %98
  store float %19, ptr %99, align 4, !tbaa !11
  %100 = add nuw i64 %98, 1
  %101 = icmp eq i64 %100, %3
  br i1 %101, label %148, label %97, !llvm.loop !19

102:                                              ; preds = %11, %102
  %103 = phi i64 [ %111, %102 ], [ 0, %11 ]
  %104 = mul i64 %103, %4
  %105 = getelementptr inbounds float, ptr %0, i64 %104
  %106 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr %105, i32 1, <16 x i1> %17, <16 x float> zeroinitializer)
  %107 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr %1, i32 1, <16 x i1> %17, <16 x float> zeroinitializer)
  %108 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %106, <16 x float> %107, <16 x float> zeroinitializer)
  %109 = tail call reassoc float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %108)
  %110 = getelementptr inbounds float, ptr %2, i64 %103
  store float %109, ptr %110, align 4, !tbaa !11
  %111 = add nuw i64 %103, 1
  %112 = icmp eq i64 %111, %3
  br i1 %112, label %148, label %102, !llvm.loop !20

113:                                              ; preds = %9, %140
  %114 = phi i64 [ %144, %140 ], [ 0, %9 ]
  %115 = mul i64 %114, %4
  %116 = getelementptr inbounds float, ptr %0, i64 %115
  br label %117

117:                                              ; preds = %113, %117
  %118 = phi i64 [ %126, %117 ], [ 16, %113 ]
  %119 = phi <16 x float> [ %125, %117 ], [ zeroinitializer, %113 ]
  %120 = phi i64 [ %118, %117 ], [ 0, %113 ]
  %121 = getelementptr inbounds float, ptr %116, i64 %120
  %122 = load <16 x float>, ptr %121, align 1, !tbaa !5
  %123 = getelementptr inbounds float, ptr %1, i64 %120
  %124 = load <16 x float>, ptr %123, align 1, !tbaa !5
  %125 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %122, <16 x float> %124, <16 x float> %119)
  %126 = add nuw i64 %118, 16
  %127 = icmp ugt i64 %126, %4
  br i1 %127, label %146, label %117, !llvm.loop !10

128:                                              ; preds = %146
  %129 = sub i64 %4, %118
  %130 = trunc i64 %129 to i32
  %131 = shl nsw i32 -1, %130
  %132 = trunc i32 %131 to i16
  %133 = xor i16 %132, -1
  %134 = getelementptr inbounds float, ptr %116, i64 %118
  %135 = bitcast i16 %133 to <16 x i1>
  %136 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr nonnull %134, i32 1, <16 x i1> %135, <16 x float> zeroinitializer)
  %137 = getelementptr inbounds float, ptr %1, i64 %118
  %138 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr nonnull %137, i32 1, <16 x i1> %135, <16 x float> zeroinitializer)
  %139 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %136, <16 x float> %138, <16 x float> %125)
  br label %140

140:                                              ; preds = %128, %146
  %141 = phi <16 x float> [ %139, %128 ], [ %125, %146 ]
  %142 = tail call reassoc float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %141)
  %143 = getelementptr inbounds float, ptr %2, i64 %114
  store float %142, ptr %143, align 4, !tbaa !11
  %144 = add nuw i64 %114, 1
  %145 = icmp eq i64 %144, %3
  br i1 %145, label %148, label %113, !llvm.loop !20

146:                                              ; preds = %117
  %147 = icmp eq i64 %118, %4
  br i1 %147, label %140, label %128

148:                                              ; preds = %215, %140, %102, %97, %78, %93, %5
  ret void

149:                                              ; preds = %7, %215
  %150 = phi i64 [ %219, %215 ], [ 0, %7 ]
  %151 = mul i64 %150, %4
  %152 = getelementptr inbounds float, ptr %0, i64 %151
  br label %153

153:                                              ; preds = %149, %153
  %154 = phi i64 [ %180, %153 ], [ 64, %149 ]
  %155 = phi <16 x float> [ %164, %153 ], [ zeroinitializer, %149 ]
  %156 = phi <16 x float> [ %169, %153 ], [ zeroinitializer, %149 ]
  %157 = phi <16 x float> [ %174, %153 ], [ zeroinitializer, %149 ]
  %158 = phi <16 x float> [ %179, %153 ], [ zeroinitializer, %149 ]
  %159 = phi i64 [ %154, %153 ], [ 0, %149 ]
  %160 = getelementptr inbounds float, ptr %152, i64 %159
  %161 = load <16 x float>, ptr %160, align 1, !tbaa !5
  %162 = getelementptr inbounds float, ptr %1, i64 %159
  %163 = load <16 x float>, ptr %162, align 1, !tbaa !5
  %164 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %161, <16 x float> %163, <16 x float> %155)
  %165 = getelementptr inbounds float, ptr %160, i64 16
  %166 = load <16 x float>, ptr %165, align 1, !tbaa !5
  %167 = getelementptr inbounds float, ptr %162, i64 16
  %168 = load <16 x float>, ptr %167, align 1, !tbaa !5
  %169 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %166, <16 x float> %168, <16 x float> %156)
  %170 = getelementptr inbounds float, ptr %160, i64 32
  %171 = load <16 x float>, ptr %170, align 1, !tbaa !5
  %172 = getelementptr inbounds float, ptr %162, i64 32
  %173 = load <16 x float>, ptr %172, align 1, !tbaa !5
  %174 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %171, <16 x float> %173, <16 x float> %157)
  %175 = getelementptr inbounds float, ptr %160, i64 48
  %176 = load <16 x float>, ptr %175, align 1, !tbaa !5
  %177 = getelementptr inbounds float, ptr %162, i64 48
  %178 = load <16 x float>, ptr %177, align 1, !tbaa !5
  %179 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %176, <16 x float> %178, <16 x float> %158)
  %180 = add nuw i64 %154, 64
  %181 = icmp ugt i64 %180, %4
  br i1 %181, label %182, label %153, !llvm.loop !8

182:                                              ; preds = %153
  %183 = fadd <16 x float> %164, %169
  %184 = fadd <16 x float> %174, %179
  %185 = fadd <16 x float> %183, %184
  %186 = or i64 %154, 16
  %187 = icmp ugt i64 %186, %4
  br i1 %187, label %199, label %188

188:                                              ; preds = %182, %188
  %189 = phi i64 [ %197, %188 ], [ %186, %182 ]
  %190 = phi <16 x float> [ %196, %188 ], [ %185, %182 ]
  %191 = phi i64 [ %189, %188 ], [ %154, %182 ]
  %192 = getelementptr inbounds float, ptr %152, i64 %191
  %193 = load <16 x float>, ptr %192, align 1, !tbaa !5
  %194 = getelementptr inbounds float, ptr %1, i64 %191
  %195 = load <16 x float>, ptr %194, align 1, !tbaa !5
  %196 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %193, <16 x float> %195, <16 x float> %190)
  %197 = add i64 %189, 16
  %198 = icmp ugt i64 %197, %4
  br i1 %198, label %199, label %188, !llvm.loop !10

199:                                              ; preds = %188, %182
  %200 = phi i64 [ %154, %182 ], [ %189, %188 ]
  %201 = phi <16 x float> [ %185, %182 ], [ %196, %188 ]
  %202 = icmp eq i64 %200, %4
  br i1 %202, label %215, label %203

203:                                              ; preds = %199
  %204 = sub i64 %4, %200
  %205 = trunc i64 %204 to i32
  %206 = shl nsw i32 -1, %205
  %207 = trunc i32 %206 to i16
  %208 = xor i16 %207, -1
  %209 = getelementptr inbounds float, ptr %152, i64 %200
  %210 = bitcast i16 %208 to <16 x i1>
  %211 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr %209, i32 1, <16 x i1> %210, <16 x float> zeroinitializer)
  %212 = getelementptr inbounds float, ptr %1, i64 %200
  %213 = tail call <16 x float> @llvm.masked.load.v16f32.p0(ptr %212, i32 1, <16 x i1> %210, <16 x float> zeroinitializer)
  %214 = tail call <16 x float> @llvm.fma.v16f32(<16 x float> %211, <16 x float> %213, <16 x float> %201)
  br label %215

215:                                              ; preds = %199, %203
  %216 = phi <16 x float> [ %214, %203 ], [ %201, %199 ]
  %217 = tail call reassoc float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %216)
  %218 = getelementptr inbounds float, ptr %2, i64 %150
  store float %217, ptr %218, align 4, !tbaa !11
  %219 = add nuw i64 %150, 1
  %220 = icmp eq i64 %219, %3
  br i1 %220, label %148, label %149, !llvm.loop !20
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind readnone speculatable willreturn
declare <16 x float> @llvm.fma.v16f32(<16 x float>, <16 x float>, <16 x float>) #2

; Function Attrs: argmemonly mustprogress nocallback nofree nosync nounwind readonly willreturn
declare <16 x float> @llvm.masked.load.v16f32.p0(ptr, i32 immarg, <16 x i1>, <16 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind readnone willreturn
declare float @llvm.vector.reduce.fadd.v16f32(float, <16 x float>) #4

attributes #0 = { argmemonly nofree nosync nounwind readonly uwtable "frame-pointer"="none" "min-legal-vector-width"="512" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #1 = { argmemonly nofree nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="512" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { argmemonly mustprogress nocallback nofree nosync nounwind readonly willreturn }
attributes #4 = { mustprogress nocallback nofree nosync nounwind readnone willreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Ubuntu clang version 15.0.7"}
!5 = !{!6, !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
!10 = distinct !{!10, !9}
!11 = !{!12, !12, i64 0}
!12 = !{!"float", !6, i64 0}
!13 = distinct !{!13, !9, !14}
!14 = !{!"llvm.loop.isvectorized", i32 1}
!15 = distinct !{!15, !16}
!16 = !{!"llvm.loop.unroll.disable"}
!17 = distinct !{!17, !9, !14, !18}
!18 = !{!"llvm.loop.unroll.runtime.disable"}
!19 = distinct !{!19, !9, !18, !14}
!20 = distinct !{!20, !9}
