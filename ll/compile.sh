#!/bin/bash
llc -O3 -opaque-pointers -relocation-model=pic system.ll
llc -O3 -opaque-pointers -relocation-model=pic lexer.ll
llc -O3 -opaque-pointers -relocation-model=pic ast.ll
llc -O3 -opaque-pointers -relocation-model=pic a.ll
gcc -o test system.s lexer.s ast.s a.s
