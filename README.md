# The NIKA programming language

NIKA is programming language aiming to have the same code for CPU and GPU,
for CUDA and OpenCL.

## Other the NIKA language highlights

1) **Variable name = it's type.** In essence, this means that any identifier
in a program can be used both as a type and as a value. This gives rise to
two related operators: "~" and "=".

The first means: "declare a type with a default value". An identifier
declared in this way does not take up any space in memory until it is
assigned to another variable with the equal sign "=" and can be used as
a constant. Moreover, such identifiers can be declared, including inside
structures.

"=" is a normal assignment, with the only difference being that it can
be both a declaration of a variable and a change in its value.

2) **Function name = its input and output variables.** Those, for example,
call `|scaled_down_image|(image)` means that the input of the function
is an image, and at the output we get a reduced image in the
`scaled_down_image` variable. If you need to place the result in another
variable, then the call looks like this:
`|scaled_down_image => other_var|(image)`.

3) **No keywords.** All control structures are given by not alphabet
characters. Together with 1 and 2, this means that any identifier in the
program is a variable, which greatly simplifies the language parser.

4) **The language is completely templated.** Despite the fact that all types
are initially explicitly defined, it should be possible to both initialize
structures with a different type, and call a function with other types,
which will cause the structure/type to be recompiled with new types.

5) **Pointers.** Unlike many other languages, any identifier means a
dereferenced entity. `&id` in a variable declaration and onward means passing
by reference, `%id` means references held by the garbage collector.
`*id` - explicit pass by value. However, the language manual insists on not
using these control characters and leaving the care of explicitly declaring
them to the compiler.

6) **Automatic data serialization.** Because of point 5, the same structure
can easily be recompiled into a pointless structure and thus serialized.
If we are talking about cyclic structures, then relative addressing will
be used.

7) **Tags.** In addition to the names of incoming/outgoing variables,
functions can have tags. And some of them will be passed transitively to
the calling function declaration. For example, `read` tag will indicate
that the function is reading something from disk. `alloc` tag is
allocating memory, and `free` is freeing it.

## Current status

The language development started at 8th June 2023.

I'm writing it on itself NIKA (`nika` folder), and manually translating
it to LLMV IR (`llvm` folder).

Now it has almost ready lexer and the example prints all numbers from
`example.nika` file.
