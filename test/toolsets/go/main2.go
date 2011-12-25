package main

import (
        "os"
        "fmt"
        "toolset-go-package"
)

func main() {
        fmt.Fprintf(os.Stdout, "Hello, Go! (%d)\n", foo.Foo2(foo.Foo(2)))
}
