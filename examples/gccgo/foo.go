package main

import (
        //"os"
        "fmt"
)

func bar(int) int __asm__("bar")

func main() {
        n := 10
        fmt.Printf("foo.go: bar(%v) = %v", n, bar(n))
}
