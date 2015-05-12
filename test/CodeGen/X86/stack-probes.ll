; RUN: llc -mtriple=i386-pc-linux-gnu < %s -o - | FileCheck --check-prefix=X86-LINUX %s
; RUN: llc -mtriple=x86_64-pc-linux-gnu < %s -o - | FileCheck --check-prefix=X64-LINUX %s

declare void @use([40096 x i8]*)

; Ensure calls to __probestack occur for large stack frames
define void @test() "probe-stack" {
  %array = alloca [40096 x i8], align 16
  call void @use([40096 x i8]* %array)
  ret void

; X86-LINUX-LABEL: test:
; X86-LINUX:       movl $4096, %edx # imm = 0x1000
; X86-LINUX:       movl $40124, %eax # imm = 0x9CBC
; X86-LINUX-NEXT:  calll __probestack
; X86-LINUX-NEXT:  subl %eax, %esp

; X64-LINUX-LABEL: test:
; X64-LINUX:       movl $4096, %edx # imm = 0x1000
; X64-LINUX:       movl $40104, %eax # imm = 0x9CA8
; X64-LINUX-NEXT:  callq __probestack
; X64-LINUX-NEXT:  subq %rax, %rsp
	
}
