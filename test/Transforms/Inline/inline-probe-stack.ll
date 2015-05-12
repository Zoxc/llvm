; RUN: opt %s -inline -S | FileCheck %s

define internal void @inner() "probe-stack" {
  ret void
}

define void @outer() {
  call void @inner()
  ret void
}
; CHECK: define void @outer() #0
; CHECK: attributes #0 = { "probe-stack" }
