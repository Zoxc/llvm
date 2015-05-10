; RUN: llc -mtriple=i386-pc-linux-gnu < %s -o - | FileCheck --check-prefix=X86-Linux %s
; RUN: llc -mtriple=x86_64-pc-linux-gnu < %s -o - | FileCheck --check-prefix=X64-Linux %s

declare void @use([40096 x i8]*)

; Ensure calls to __probestack occur for large stack frames
define void @test() "probe-stack" {
  %array = alloca [40096 x i8], align 16
  call void @use([40096 x i8]* %array)
  ret void

; X86-Linux-LABEL: test:
; X86-Linux:       movl $40124, %eax # imm = 0x9CBC
; X86-Linux-NEXT:  calll __probestack
; X86-Linux-NEXT:  subl %eax, %esp

; X64-Linux-LABEL: test:
; X64-Linux:       movl $40104, %eax # imm = 0x9CA8
; X64-Linux-NEXT:  callq __probestack
; X64-Linux-NEXT:  subq %rax, %rsp
	
}
