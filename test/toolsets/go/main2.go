package main

import (
        "os"
        "fmt"
        "toolset_go_package"
)

func main() {
        fmt.Fprintf(os.Stdout, "Hello, Go! (%d)\n", foo.Foo2(foo.Foo(2)))
}
