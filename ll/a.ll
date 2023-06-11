; Declare the string constant as a global constant.
@.newline = private unnamed_addr constant [2 x i8] c"\0A\00"
@.filename = private unnamed_addr constant [13 x i8] c"example.nika\00"
@.debug_str = private unnamed_addr constant [6 x i8] c"%llX\0A\00"

; External declaration of the puts function
declare i32 @printf(ptr noundef, ...) nounwind
declare i64 @write(i32, i8*, i64) nounwind
declare i32 @putchar(i32) nounwind

%string = type { i32, i8* }
%position = type { i32, i32 }
%array = type { i32, i32, ptr }
%lexer = type {i8*, %array, %position, %position, %string, i32}
declare %lexer @_1_5lexer1_8filename(i8* %filename)
declare %AstNode @_1_3ast1_5lexer(%lexer %lexer_in)

%AstNode = type {i32, i128, i128}
%AstExpression = type {i32, %array, i128}
%AstOperator   = type {i32, %string, i32, i32*}   
%AstValue      = type {i32, %string, i128}
%AstVar        = type {i32, %string, i128}

; Definition of main function
define i32 @main() {
  %lex = call %lexer @_1_5lexer1_8filename(i8* @.filename)
  %ast = call %AstNode @_1_3ast1_5lexer(%lexer %lex)
  %astptr = alloca %AstNode
  store %AstNode %ast, ptr %astptr
  %astexpr = load %AstExpression, ptr %astptr

  %num = extractvalue %AstExpression %astexpr, 1, 0
  %values = extractvalue %AstExpression %astexpr, 1, 2

  %i = alloca i32
  store i32 0, ptr %i
  br label %Loop

Loop:
  %ival = load i32, ptr %i
  %is_end = icmp uge i32 %ival, %num
  br i1 %is_end, label %out, label %good

good:
  %astnode = getelementptr %AstNode, ptr %values, i32 %ival
  %astval = load %AstValue, ptr %astnode
  %stringval = extractvalue %AstValue %astval, 1

  %strlen = extractvalue %string %stringval, 0
  %strptr = extractvalue %string %stringval, 1

  %len64 = zext i32 %strlen to i64

  call i64 @write(i32 1, i8* %strptr, i64 %len64)
  call i64 @write(i32 1, i8* @.newline, i64 1)

  %ivalp1 = add i32 1, %ival
  store i32 %ivalp1, ptr %i

  br label %Loop

out:

  ret i32 0
}
