package main

import (
        //"os"
        "fmt"
)

func foo(int) int __asm__("foo")

func main() {
        n := 10
        fmt.Printf("foo.go: foo(%v) = %v", n, foo(n))
}
