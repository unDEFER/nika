@.malloc_err = private unnamed_addr constant [14 x i8] c"Malloc Error\0A\00"
@.test_str = private unnamed_addr constant [5 x i8] c"test\00"
@.debug_str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

%position = type { i32, i32 }

;@Begin      = constant i32 0
;@Identifier = constant i32 1
;@Integer    = constant i32 2
;@Float      = constant i32 3
;@Operator   = constant i32 4
;@Delimiter  = constant i32 5
;@Bracket    = constant i32 6
;@EndOfInput = constant i32 7
;@Blank      = constant i32 8
;@BadChar    = constant i32 9

%string = type { i32, i8* }

%array = type { i32, i32, ptr }
%lexer = type {i8*, %array, %position, %position, %string, i32}

declare {i8*, i64} @_1_8filename2_8filedata8filesize(i8* %filename)
declare i8* @malloc(i64) nounwind
declare i32 @printf(ptr noundef, ...) nounwind
declare i64 @write(i32, i8*, i64) nounwind
declare i32 @putchar(i32) nounwind
declare void @exit(i32) nounwind
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

;|lexer|(lexer)
declare %lexer @_1_5lexer1_5lexer(%lexer %lexer_in)
declare void @_1_5array2_5array9new_entry(%array* %array_ptr, i64 %entry_size, ptr %new_entry)

;@Expression = constant i32 0
;@Operator   = constant i32 1
;@Value      = constant i32 2
;@Var        = constant i32 3

;ast_node ~ {
;    type = ast_node_type,
;    <type> {
;        Expression:
;            num_calcs = u32,
;            calcs = ast_node[num_calcs],
;        Operator:
;            operator = string,
;            num_args = u32,
;            args = u32[num_args],
;        Value:
;            val = string,
;        Var:
;            name = string
;    }
;}

%AstNode = type {i32, i128, i128}
%AstExpression = type {i32, %array, i128}
%AstOperator   = type {i32, %string, i32, i32*}   
%AstValue      = type {i32, %string, i128}
%AstVar        = type {i32, %string, i128}

;|ast = ast_node|(lexer)
define %AstNode @_1_3ast1_5lexer(%lexer %lexer_in)
{
  %SizeOfNodePtr = getelementptr %AstNode, ptr null, i64 1
  %SizeOfNode = ptrtoint %AstNode* %SizeOfNodePtr to i64

  %lexptr = alloca %lexer
  store %lexer %lexer_in, ptr %lexptr

  ;ast.type = ast_node_type.Expression;
  %ast = alloca %AstExpression
  call void @llvm.memset.p0.i64(ptr %ast, i8 0, i64 %SizeOfNode, i1 false)

  br label %Next

Next:
  %lexerval = load %lexer, ptr %lexptr
  %lex = call %lexer @_1_5lexer1_5lexer(%lexer %lexerval)
  store %lexer %lex, ptr %lexptr

  ;lexer.lexem_type == lexem_type.Integer?
  %lexem_type = extractvalue %lexer %lex, 5
  %is_integer = icmp eq i32 %lexem_type, 2
  br i1 %is_integer, label %it_is_integer, label %_is_end
it_is_integer:
  ;value = ast_node;
  ;value.type = ast_node_type.Value;
  %astval1 = insertvalue %AstValue undef, i32 2, 0
  ;value.val = lexer.lexem;
  %lexem = extractvalue %lexer %lex, 4
  %astval2 = insertvalue %AstValue %astval1, %string %lexem, 1
  %astvalptr = alloca %AstValue
  store %AstValue %astval2, ptr %astvalptr
  ;ast.calcs ~= value;
  %calcs = getelementptr inbounds %AstExpression, ptr %ast, i32 0, i32 1
  call void @_1_5array2_5array9new_entry(%array* %calcs, i64 %SizeOfNode, ptr %astvalptr)

  ; ==> Next;
  br label %Next

_is_end:
  ;:lexer.lexem_type == lexem_type.EndOfInput?
  %is_end = icmp eq i32 %lexem_type, 7
  ;==> Out;
  br i1 %is_end, label %out, label %Next

out:
  %ret = load %AstNode, ptr %ast
  ret %AstNode %ret
}
