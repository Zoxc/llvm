; RUN: llc < %s -mtriple=i686-pc-win32 | FileCheck %s -check-prefix=WIN
; RUN: llc < %s -mtriple=x86_64-pc-win32 | FileCheck %s -check-prefix=WIN
; RUN: llc < %s -mtriple=i686-pc-mingw32 | FileCheck %s -check-prefix=WIN
; RUN: llc < %s -mtriple=x86_64-pc-mingw32 | FileCheck %s -check-prefix=WIN
; RUN: llc < %s -mtriple=i386-pc-linux | FileCheck %s -check-prefix=LINUX
; RUN: llc < %s -mtriple=x86_64-pc-win32-macho | FileCheck %s -check-prefix=LINUX

; Windows and mingw require a prologue helper routine if more than 4096 bytes area
; allocated on the stack.  Windows uses __chkstk and mingw uses __alloca.  __alloca
; and the 32-bit version of __chkstk will probe the stack and adjust the stack pointer.
; The 64-bit version of __chkstk is only responsible for probing the stack.  The 64-bit
; prologue is responsible for adjusting the stack pointer.

; Stack allocation >= 4096 bytes will require call to __chkstk in the Windows ABI.
define i32 @main4k() nounwind {
entry:
; WIN: or{{.}}     $0, {{.*}}
; LINUX-NOT: or{{[ql]}}     $0, {{.*}}
  %array4096 = alloca [4096 x i8], align 16       ; <[4096 x i8]*> [#uses=0]
  ret i32 0
}

; Make sure we don't call __chkstk or __alloca when we have less than a 4096 stack
; allocation.
define i32 @main128() nounwind {
entry:
; WIN-NOT: or{{.}}     $0, {{.*}}
; LINUX-NOT: or{{.}}     $0, {{.*}}
  %array128 = alloca [128 x i8], align 16         ; <[128 x i8]*> [#uses=0]
  ret i32 0
}

; Make sure we don't call __chkstk or __alloca on non-Windows even if the
; caller has the Win64 calling convention.
define x86_64_win64cc i32 @main4k_win64() nounwind {
entry:
; WIN: or{{.}}     $0, {{.*}}
; LINUX-NOT: or{{.}}     $0, {{.*}}
  %array4096 = alloca [4096 x i8], align 16       ; <[4096 x i8]*> [#uses=0]
  ret i32 0
}
