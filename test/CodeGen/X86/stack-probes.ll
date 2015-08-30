; RUN: llc -mtriple=i386-pc-linux-gnu < %s -o - | FileCheck --check-prefix=X86-LINUX %s
; RUN: llc -mtriple=x86_64-pc-linux-gnu < %s -o - | FileCheck --check-prefix=X64-LINUX %s

declare void @use([40096 x i8]*)

; Ensure calls to __probestack occur for large stack frames
define void @test() "probe-stack" {
  %array = alloca [40096 x i8]
  call void @use([40096 x i8]* %array)
  ret void

; X86-LINUX-LABEL: test:
; X86-LINUX:       movl    $40108, %eax            # imm = 0x9CAC
; X86-LINUX-NEXT:  movl    %eax, %edx
; X86-LINUX-NEXT:  movl    %esp, %ecx
; X86-LINUX-LABEL: .LBB0_1
; X86-LINUX-NEXT:  orl     $0, (%ecx)
; X86-LINUX-NEXT:  subl    $4096, %ecx
; X86-LINUX-NEXT:  subl    $4096, %edx
; X86-LINUX-NEXT:  jae     .LBB0_1
; X86-LINUX:       subl    %eax, %esp
; X86-LINUX:       addl    $40108, %esp            # imm = 0x9CAC

; X64-LINUX-LABEL: test:
; X64-LINUX:       movl    $40104, %eax            # imm = 0x9CA8
; X64-LINUX-NEXT:  movq    %rax, %rdx
; X64-LINUX-NEXT:  movq    %rsp, %rcx
; X64-LINUX-LABEL: .LBB0_1
; X64-LINUX-NEXT:  orq     $0, (%rcx)
; X64-LINUX-NEXT:  subq    $4096, %rcx
; X64-LINUX-NEXT:  subq    $4096, %rdx
; X64-LINUX-NEXT:  jae     .LBB0_1
; X64-LINUX:       subq    %rax, %rsp
; X64-LINUX:       addq    $40104, %rsp            # imm = 0x9CA8

}

declare void @useFast([4096 x i8]*)

; Ensure the stack is probed for medium stack frames
define void @testFast() "probe-stack" {
  %array = alloca [4096 x i8]
  call void @useFast([4096 x i8]* %array)
  ret void

; X86-LINUX-LABEL: testFast:
; X86-LINUX:       orl     $0, -4096(%esp)
; X86-LINUX-NEXT:  subl    $4108, %esp             # imm = 0x100C

; X64-LINUX-LABEL: testFast:
; X64-LINUX:       orq     $0, -4096(%rsp)
; X64-LINUX-NEXT:  subq    $4104, %rsp             # imm = 0x1008

}
