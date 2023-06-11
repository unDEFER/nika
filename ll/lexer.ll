@.malloc_err = private unnamed_addr constant [14 x i8] c"Malloc Error\0A\00"
@.test_str = private unnamed_addr constant [5 x i8] c"test\00"
@.debug_str = private unnamed_addr constant [6 x i8] c"%llX\0A\00"

%position = type { i32, i32 }

@Begin      = constant i32 0
@Identifier = constant i32 1
@Integer    = constant i32 2
@Float      = constant i32 3
@Operator   = constant i32 4
@Delimiter  = constant i32 5
@Bracket    = constant i32 6
@EndOfInput = constant i32 7
@Blank      = constant i32 8
@BadChar    = constant i32 9

@MAX_LINES = constant i64 16384

%string = type { i32, i8* }

%array = type { i32, i32, ptr }
%lexer = type {i8*, %array, %position, %position, %string, i32}

declare {i8*, i64} @_1_8filename2_8filedata8filesize(i8* %filename)
declare i8* @malloc(i64) nounwind
declare i32 @printf(ptr noundef, ...) nounwind
declare i64 @write(i32, i8*, i64) nounwind
declare i32 @putchar(i32) nounwind
declare void @exit(i32) nounwind
declare void @_1_5array2_5array9new_entry(%array* %array_ptr, i64 %entry_size, ptr %new_entry)
declare void @llvm.memset.p0.i32(ptr, i8, i32, i1)


define %lexer @_1_5lexer1_8filename(i8* %filename)
{
  %1 = call {i8*, i64} @_1_8filename2_8filedata8filesize(i8* %filename)
  %2 = extractvalue {i8*, i64} %1, 0
  %3 = extractvalue {i8*, i64} %1, 1
  
  %SizeOfStringPtr = getelementptr %string, ptr null, i64 1
  %SizeOfString = ptrtoint %string* %SizeOfStringPtr to i64

  %lineptr = alloca %string
  %lines = alloca %array
  call void @llvm.memset.p0.i32(ptr %lines, i8 0, i32 16, i1 false)
  %startline = alloca i32
  store i64 0, ptr %startline

  %i = alloca i64
  store i64 0, ptr %i
  br label %beg
beg:
  %4 = load i64, ptr %i
  %5 = icmp uge i64 %4, %3
  br i1 %5, label %exit, label %loop

loop:
  %filedatachrptr = getelementptr i8, ptr %2, i64 %4
  %filedatachr = load i8, ptr %filedatachrptr
  %6 = icmp eq i8 %filedatachr, 10
  br i1 %6, label %newline, label %otherchr

newline:
  ;line = filedata[start_line..i];
  %startlineval = load i32, ptr %startline
  %filedatastartptr = getelementptr i8, ptr %2, i32 %startlineval
  %i32 = trunc i64 %4 to i32
  %len = sub i32 %i32, %startlineval
  %line1 = insertvalue %string undef, i32 %len, 0
  %line2 = insertvalue %string %line1, i8* %filedatastartptr, 1
  store %string %line2, ptr %lineptr

  ;lines ~= line;
  call void @_1_5array2_5array9new_entry(%array* %lines, i64 %SizeOfString, ptr %lineptr)

  ;start_line = i+1;
  %ip1 = add i64 1, %4
  store i64 %ip1, ptr %startline

  br label %otherchr;

otherchr:
  %in = add i64 1, %4
  store i64 %in, ptr %i
  br label %beg

exit:
  %startlineval2 = load i32, ptr %startline
  %startline64 = zext i32 %startlineval2 to i64
  %7 = icmp ugt i64 %3, %startline64
  br i1 %7, label %lastline, label %skiplastline

lastline:
  %filedatastartptr2 = getelementptr i8, ptr %2, i32 %startlineval2
  %i232 = trunc i64 %3 to i32
  %len2 = sub i32 %i232, %startlineval2
  %line21 = insertvalue %string undef, i32 %len2, 0
  %line22 = insertvalue %string %line21, i8* %filedatastartptr2, 1
  store %string %line22, ptr %lineptr
  
  ;lines ~= line;
  call void @_1_5array2_5array9new_entry(%array* %lines, i64 %SizeOfString, ptr %lineptr)
  br label %skiplastline

skiplastline:

  %lines_val = load %array, ptr %lines
  %ret1 = insertvalue %lexer undef, i8* %filename, 0
  %ret3 = insertvalue %lexer %ret1, %array %lines_val, 1
  %ret4 = insertvalue %lexer %ret3, %position {i32 0, i32 0}, 2
  %ret5 = insertvalue %lexer %ret4, %position {i32 0, i32 0}, 3
  %ret6 = insertvalue %lexer %ret5, %string {i32 0, ptr null}, 4
  %ret7 = insertvalue %lexer %ret6, i32 0, 5
  ret %lexer %ret7
}

;|is_eof|(lexer, current_pos)
define i1 @_1_6is_eof2_5lexer_11current_pos(%lexer %lexer_in, %position %current_pos) alwaysinline
{
  ;current_pos.line >= lexer.lines.len;
  %line = extractvalue %position %current_pos, 0
  %lines = extractvalue %lexer %lexer_in, 1
  %num_lines = extractvalue %array %lines, 0
  %ret = icmp uge i32 %line, %num_lines
  ret i1 %ret
}

;|current_char|(lexer, current_pos);
define i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos) alwaysinline
{
  ;|is_eof|(lexer, current_pos) ? {
  %is_eof = call i1 @_1_6is_eof2_5lexer_11current_pos(%lexer %lexer_in, %position %current_pos)
  br i1 %is_eof, label %eof_br, label %not_eof_br

eof_br:
  ;current_char = '\x04';
  ret i8 4

not_eof_br:
  ;current_char = lexer.lines[current_pos.line][current_pos.pos];
  %line = extractvalue %position %current_pos, 0
  %pos = extractvalue %position %current_pos, 1

  %lines = extractvalue %lexer %lexer_in, 1, 2
  %lines_ptr = getelementptr %string, ptr %lines, i32 %line
  %lines_str = load %string, ptr %lines_ptr
  %lines_str_ptr = extractvalue %string %lines_str, 1
  %current_char_ptr = getelementptr i8, ptr %lines_str_ptr, i32 %pos
  %current_char = load i8, ptr %current_char_ptr

  ret i8 %current_char
}

;|is_digit|(current_char)
define i1 @_1_8is_digit_1_12current_char(i8 %current_char) alwaysinline
{
    ;is_digit = current_char >= '0' && current_char <= '9';
    %1 = icmp uge i8 %current_char, 48
    %2 = icmp ule i8 %current_char, 57
    %is_digit = and i1 %1, %2

    ret i1 %is_digit
}

;|next_line|(current_pos)
define %position @_1_9next_line_1_11current_pos(%position %current_pos) alwaysinline
{
  ;next_line.line = current_pos.line + 1;
  ;next_line.pos = 0;
  %line = extractvalue %position %current_pos, 0
  %linep1 = add i32 1, %line

  %ret1 = insertvalue %position undef, i32 %linep1, 0
  %ret2 = insertvalue %position %ret1, i32 0, 1
  ret %position %ret2
}

;|next_pos => current_pos|(current_pos)
define %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos) alwaysinline
{
  ;current_pos.pos >= lexer.lines[current_pos.line].len?

  %line = extractvalue %position %current_pos, 0
  %pos = extractvalue %position %current_pos, 1

  %lines = extractvalue %lexer %lexer_in, 1, 2
  %lines_ptr = getelementptr %string, ptr %lines, i32 %line
  %lines_str = load %string, ptr %lines_ptr
  %lines_str_len = extractvalue %string %lines_str, 0

  %is_eol = icmp uge i32 %pos, %lines_str_len
  br i1 %is_eol, label %eol, label %not_eol
eol:
  ;|next_pos => current_pos|(lexer, current_pos)
  %next_pos = call %position @_1_9next_line_1_11current_pos(%position %current_pos)
  ret %position %next_pos

not_eol:
  ;next_pos.pos++;
  %posp1 = add i32 1, %pos

  %ret1 = insertvalue %position undef, i32 %line, 0
  %ret2 = insertvalue %position %ret1, i32 %posp1, 1
  ret %position %ret2
}

;|is_alpha|(current_char)
define i1 @_1_8is_alpha1_12current_char(i8 %current_char) alwaysinline
{
  ;is_alpha = current_char >= 'A' && current_char <= 'Z' ||
  %1 = icmp uge i8 %current_char, 65
  br i1 %1, label %Zcmp, label %acmp
Zcmp:
  %2 = icmp ule i8 %current_char, 90
  br i1 %2, label %yes, label %acmp
  ;current_char >= 'a' && current_char <= 'z' || current_char == '_';
acmp:
  %3 = icmp uge i8 %current_char, 97
  br i1 %3, label %zcmp, label %_cmp
zcmp:
  %4 = icmp ule i8 %current_char, 122
  br i1 %4, label %yes, label %_cmp
_cmp:
  %5 = icmp eq i8 %current_char, 95
  br i1 %5, label %yes, label %sharpcmp
sharpcmp:
  %6 = icmp eq i8 %current_char, 35
  br i1 %6, label %yes, label %no
yes:
  ret i1 true
no:
  ret i1 false
}

;|is_alphanum|(current_char)
define i1 @_1_11is_alphanum1_12current_char(i8 %current_char) alwaysinline
{
  ;is_alphanum = is_alpha(current_char) || is_digit(current_char); 
  %is_alpha = call i1 @_1_8is_alpha1_12current_char(i8 %current_char)
  br i1 %is_alpha, label %yes, label %_is_digit

_is_digit:
  %is_digit = call i1 @_1_8is_digit_1_12current_char(i8 %current_char)
  br i1 %is_digit, label %yes, label %no

yes:
  ret i1 true
no:
  ret i1 false
}

;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr)
define void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 %skip_chr)
{
  ;current_char == skip_chr ?
  %current_char_val = load i8, ptr %current_char
  %is_skip_chr = icmp eq i8 %current_char_val, %skip_chr
  br i1 %is_skip_chr, label %next_chr, label %out

next_chr:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val = load %position, ptr %current_pos
  %next_pos = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val)
  store %position %next_pos, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char_new = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos)
  store i8 %current_char_new, ptr %current_char
  br label %out

out:
  ret void
}

;|lexer|(lexer, current_pos, lexem_type)
define void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_ptr, %position %current_pos, i32 %lexem_type)
{
  ;lexer.start = lexer.end;
  %lexer_val = load %lexer, ptr %lexer_ptr
  %lexer_start = extractvalue %lexer %lexer_val, 3
  %lexer_val1 = insertvalue %lexer %lexer_val, %position %lexer_start, 2
  
  ;lexer.end = current_pos;
  %lexer_val2 = insertvalue %lexer %lexer_val1, %position %current_pos, 3

  ;lexer.lexem = lexer.lines[current_pos.line][lexer.start.pos..lexer.end.pos];
  %line = extractvalue %position %current_pos, 0
  %start_pos = extractvalue %position %lexer_start, 1
  %end_pos = extractvalue %position %current_pos, 1
  %len = sub i32 %end_pos, %start_pos

  %lines = extractvalue %lexer %lexer_val2, 1, 2
  %lines_ptr = getelementptr %string, ptr %lines, i32 %line
  %lines_str = load %string, ptr %lines_ptr
  %lines_str_ptr = extractvalue %string %lines_str, 1
  %start_pos_ptr = getelementptr i8, ptr %lines_str_ptr, i32 %start_pos

  %lexem1 = insertvalue %string undef, i32 %len, 0
  %lexem2 = insertvalue %string %lexem1, i8* %start_pos_ptr, 1

  %lexer_val3 = insertvalue %lexer %lexer_val2, %string %lexem2, 4

  ;lexer.lexem_type = lexem_type;
  %lexer_val4 = insertvalue %lexer %lexer_val3, i32 %lexem_type, 5
  store %lexer %lexer_val4, ptr %lexer_ptr
  ret void
}

;|lexer|(lexer)
define %lexer @_1_5lexer1_5lexer(%lexer %lexer_in)
{
  %lexer_out = alloca %lexer
  store %lexer %lexer_in, ptr %lexer_out

  ; currect_pos = lexer.end;
  %current_pos_val = extractvalue %lexer %lexer_in, 3
  %current_pos = alloca %position
  store %position %current_pos_val, ptr %current_pos

  %current_pos_vvv = load %position, ptr %current_pos
  %current_char = alloca i8
  ;|current_char|(lexer, current_pos);
  %current_char_v1 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_vvv)
  store i8 %current_char_v1, ptr %current_char
  br label %NextChar

NextChar:
  ;|is_digit|(current_char)?
  %current_char_v = load i8, ptr %current_char
  %is_digit = call i1 @_1_8is_digit_1_12current_char(i8 %current_char_v)
  br i1 %is_digit, label %NextDigit, label %_is_alpha

NextDigit:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val2 = load %position, ptr %current_pos
  %next_pos = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val2)
  store %position %next_pos, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char2 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos)

  ;current_char == '.'?
  %is_dot = icmp eq i8 %current_char2, 46
  br i1 %is_dot, label %NextDigit2, label %not_dot
NextDigit2:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val3 = load %position, ptr %current_pos
  %next_pos3 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val3)
  store %position %next_pos3, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char3 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos3)

  %is_digit2 = call i1 @_1_8is_digit_1_12current_char(i8 %current_char3)
  br i1 %is_digit2, label %NextDigit2, label %endofdigits

endofdigits:
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %next_pos3, i32 3)
  br label %out;

not_dot:
  ;|is_digit|(current_char)?
  %is_digit3 = call i1 @_1_8is_digit_1_12current_char(i8 %current_char2)
  ;==> NextDigit;
  br i1 %is_digit3, label %NextDigit, label %endofdigits2

endofdigits2:
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Integer);
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %next_pos, i32 2)
  br label %out;

_is_alpha:
  %is_alpha = call i1 @_1_8is_alpha1_12current_char(i8 %current_char_v)
  br i1 %is_alpha, label %NextAlphaNum, label %_pm_opers

NextAlphaNum:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val4 = load %position, ptr %current_pos
  %next_pos4 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val4)
  store %position %next_pos4, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char4 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos4)

  ;|is_alphanum|(current_char)?
  %is_alphanum = call i1 @_1_11is_alphanum1_12current_char(i8 %current_char4)
  ;==> NextAlphaNum;
  br i1 %is_alphanum, label %NextAlphaNum, label %not_alphanum

not_alphanum:
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Identifier);
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %next_pos4, i32 1)
  br label %out;

_pm_opers:
  ;: current_char == '+' || current_char == '-' || current_char == '*'
  %is_plus = icmp eq i8 %current_char_v, 43
  br i1 %is_plus, label %is_pm_opers, label %_is_minus
_is_minus:
  %is_minus = icmp eq i8 %current_char_v, 45
  br i1 %is_minus, label %is_pm_opers, label %_is_mult
_is_mult:
  %is_mult = icmp eq i8 %current_char_v, 42
  br i1 %is_mult, label %is_pm_opers, label %_is_greater
_is_greater:
  ;     || current_char == '>'  ?
  %is_greater = icmp eq i8 %current_char_v, 62
  br i1 %is_greater, label %is_pm_opers, label %_is_div
is_pm_opers:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val5 = load %position, ptr %current_pos
  %next_pos5 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val5)
  store %position %next_pos5, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char5 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos5)

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '=')
  store i8 %current_char5, ptr %current_char
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 61)

  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %next_pos5, i32 4)
  br label %out;

_is_div:
;: current_char == '/' ?
  %is_div = icmp eq i8 %current_char_v, 47
  br i1 %is_div, label %it_is_div, label %_is_less

it_is_div:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val6 = load %position, ptr %current_pos
  %next_pos6 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val6)
  store %position %next_pos6, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char6 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos6)
  store i8 %current_char6, ptr %current_char

  ;current_char == '=' ?
  %is_eq = icmp eq i8 %current_char6, 61
  br i1 %is_eq, label %it_is_eq, label %_is_line_comment
it_is_eq:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val7 = load %position, ptr %current_pos
  %next_pos7 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val7)
  store %position %next_pos7, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char7 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos7)
  store i8 %current_char7, ptr %current_char
  br label %_is_line_comment

_is_line_comment:
  ;current_char == '/' ?
  %current_char_v8 = load i8, ptr %current_char
  %is_line_comment = icmp eq i8 %current_char_v8, 47
  br i1 %is_line_comment, label %next_line, label %_is_comment
next_line:
  ;|next_line => current_pos|(current_pos);
  %current_pos_val8 = load %position, ptr %current_pos
  %next_line8 = call %position @_1_9next_line_1_11current_pos(%position %current_pos_val8)
  store %position %next_line8, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char8 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_line8)
  store i8 %current_char8, ptr %current_char
  br label %NextChar
  ;==> NextChar;

_is_comment:
  ;current_char == '*' ?
  %current_char_v88 = load i8, ptr %current_char
  %is_asterisk = icmp eq i8 %current_char_v88, 42
  br i1 %is_asterisk, label %SeekAsterisk, label %ret_oper
SeekAsterisk:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val9 = load %position, ptr %current_pos
  %next_pos9 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val9)
  store %position %next_pos9, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char9 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos9)
  store i8 %current_char9, ptr %current_char

  ;current_char == '*' ?
  %is_asterisk2 = icmp eq i8 %current_char9, 42
  br i1 %is_asterisk2, label %it_is_asterisk, label %SeekAsterisk

it_is_asterisk:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val10 = load %position, ptr %current_pos
  %next_pos10 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val10)
  store %position %next_pos10, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char10 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos10)
  store i8 %current_char10, ptr %current_char

  ;current_char == '/' ?
  %is_slash = icmp eq i8 %current_char10, 47
  br i1 %is_slash, label %end_of_comment, label %SeekAsterisk

end_of_comment:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val11 = load %position, ptr %current_pos
  %next_pos11 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11)
  store %position %next_pos11, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11)
  store i8 %current_char11, ptr %current_char

  ;==> NextChar;
  br label %NextChar

ret_oper:
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos11 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos11, i32 4)
  br label %out;

_is_less:
  ;current_char == '<' ?
  %is_less = icmp eq i8 %current_char_v, 60
  br i1 %is_less, label %it_is_less, label %_is_equal

it_is_less:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_ = load %position, ptr %current_pos
  %next_pos11_ = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_)
  store %position %next_pos11_, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_ = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_)
  store i8 %current_char11_, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '=')
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 61)
  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '=')
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 61)
  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '=')
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 61)
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos12 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos12, i32 4)
  br label %out;

_is_equal:
  ;: current_char == '=' ?
  %is_equal = icmp eq i8 %current_char_v, 61
  br i1 %is_equal, label %it_is_equal, label %_is_dot

it_is_equal:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_1 = load %position, ptr %current_pos
  %next_pos11_1 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_1)
  store %position %next_pos11_1, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_1 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_1)
  store i8 %current_char11_1, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '=')
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 61)
  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '>')
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 62)
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos13 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos13, i32 4)
  br label %out;

_is_dot:
  ;: current_char == '.' ?
  %is_dot2 = icmp eq i8 %current_char_v, 46
  br i1 %is_dot2, label %it_is_dot, label %_is_and

it_is_dot:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_2 = load %position, ptr %current_pos
  %next_pos11_2 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_2)
  store %position %next_pos11_2, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_2 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_2)
  store i8 %current_char11_2, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '.');
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 46)
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos14 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos14, i32 4)
  br label %out;

_is_and:
  ;: current_char == '&' ?
  %is_and = icmp eq i8 %current_char_v, 38
  br i1 %is_and, label %it_is_and, label %_is_or

it_is_and:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_3 = load %position, ptr %current_pos
  %next_pos11_3 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_3)
  store %position %next_pos11_3, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_3 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_3)
  store i8 %current_char11_3, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '&');
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 38)
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos15 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos15, i32 4)
  br label %out;

_is_or:
  ;: current_char == '|' ?
  %is_or = icmp eq i8 %current_char_v, 124
  br i1 %is_or, label %it_is_or, label %_is_caret

it_is_or:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_4 = load %position, ptr %current_pos
  %next_pos11_4 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_4)
  store %position %next_pos11_4, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_4 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_4)
  store i8 %current_char11_4, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '|');
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 124)
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos16 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos16, i32 4)
  br label %out;

_is_caret:
  ;: current_char == '^' ?
  %is_caret = icmp eq i8 %current_char_v, 94
  br i1 %is_caret, label %it_is_caret, label %_is_question

it_is_caret:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_5 = load %position, ptr %current_pos
  %next_pos11_5 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_5)
  store %position %next_pos11_5, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_5 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_5)
  store i8 %current_char11_5, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '^');
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 94)
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos17 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos17, i32 4)
  br label %out;

_is_question:
  ;: current_char == '?' || current_char == ':' || current_char == '~' ?
  %is_question = icmp eq i8 %current_char_v, 63
  br i1 %is_question, label %it_is_question, label %_is_colon
_is_colon:
  %is_colon = icmp eq i8 %current_char_v, 58
  br i1 %is_colon, label %it_is_question, label %_is_tilda
_is_tilda:
  %is_tilda = icmp eq i8 %current_char_v, 126
  br i1 %is_tilda, label %it_is_question, label %_is_comma
_is_comma:
  %is_comma = icmp eq i8 %current_char_v, 44
  br i1 %is_comma, label %it_is_question, label %_is_semicolon
_is_semicolon:
  %is_semicolon = icmp eq i8 %current_char_v, 59
  br i1 %is_semicolon, label %it_is_question, label %_is_bracket

it_is_question:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_6 = load %position, ptr %current_pos
  %next_pos11_6 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_6)
  store %position %next_pos11_6, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_6 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_6)
  store i8 %current_char11_6, ptr %current_char

  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Operator);
  %current_pos18 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos18, i32 4)
  br label %out;

_is_bracket:
  ;: current_char == '(' || current_char == ')' ?
  %is_bracket = icmp eq i8 %current_char_v, 40
  br i1 %is_bracket, label %it_is_bracket, label %_is_cl_bracket
_is_cl_bracket:
  %is_cl_bracket = icmp eq i8 %current_char_v, 41
  br i1 %is_cl_bracket, label %it_is_bracket, label %_is_sq_bracket

it_is_bracket:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_7 = load %position, ptr %current_pos
  %next_pos11_7 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_7)
  store %position %next_pos11_7, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_7 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_7)
  store i8 %current_char11_7, ptr %current_char

  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Bracket);
  %current_pos19 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos19, i32 4)
  br label %out;

_is_sq_bracket:
  ;: current_char == '[' ?
  %is_sq_bracket = icmp eq i8 %current_char_v, 91
  br i1 %is_sq_bracket, label %it_is_sq_bracket, label %_is_clsq_bracket

it_is_sq_bracket:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_8 = load %position, ptr %current_pos
  %next_pos11_8 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_8)
  store %position %next_pos11_8, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_8 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_8)
  store i8 %current_char11_8, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = '[');
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 91)
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Bracket);
  %current_pos20 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos20, i32 4)
  br label %out;

_is_clsq_bracket:
  ;: current_char == ']' ?
  %is_clsq_bracket = icmp eq i8 %current_char_v, 93
  br i1 %is_clsq_bracket, label %it_is_clsq_bracket, label %_is_brace

it_is_clsq_bracket:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_9 = load %position, ptr %current_pos
  %next_pos11_9 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_9)
  store %position %next_pos11_9, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_9 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_9)
  store i8 %current_char11_9, ptr %current_char

  ;|current_pos, current_char|(lexer, current_pos, current_char, skip_chr = ']');
  call void @_2_11current_pos12current_char4_5lexer11current_pos12current_char8skip_chr(
  %lexer %lexer_in, %position* %current_pos, i8* %current_char, i8 93)

  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Bracket);
  %current_pos21 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos21, i32 4)
  br label %out;

_is_brace:
  ;: current_char == '{' || current_char == '}' ?
  %is_brace = icmp eq i8 %current_char_v, 123
  br i1 %is_brace, label %it_is_brace, label %_is_cl_brace
_is_cl_brace:
  %is_cl_brace = icmp eq i8 %current_char_v, 125
  br i1 %is_cl_brace, label %it_is_brace, label %_is_space

it_is_brace:
  ;|next_pos => current_pos|(lexer, current_pos);
  %current_pos_val11_10 = load %position, ptr %current_pos
  %next_pos11_10 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val11_10)
  store %position %next_pos11_10, ptr %current_pos

  ;|current_char|(lexer, current_pos);
  %current_char11_10 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos11_10)
  store i8 %current_char11_10, ptr %current_char

  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Bracket);
  %current_pos22 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos22, i32 4)
  br label %out;

_is_space:
  ;: current_char == ' ' ?
  %is_space = icmp eq i8 %current_char_v, 32
  br i1 %is_space, label %NextSpace, label %_is_eol
_is_eol:
  ;: current_char == '\n' ?
  %is_eol = icmp eq i8 %current_char_v, 10
  br i1 %is_eol, label %NextSpace, label %_is_eof

NextSpace:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val23 = load %position, ptr %current_pos
  %next_pos23 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val23)
  store %position %next_pos23, ptr %current_pos
  ;|current_char|(lexer, current_pos);
  %current_char23 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos23)
  store i8 %current_char23, ptr %current_char

  ;current_char == ' ' ?
  %is_space2 = icmp eq i8 %current_char23, 32
  br i1 %is_space2, label %NextSpace, label %_is_eol2
_is_eol2:
  ;: current_char == '\n' ?
  %is_eol2 = icmp eq i8 %current_char23, 10
  br i1 %is_eol2, label %NextSpace, label %not_space

not_space:
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.Blank);
  %current_pos23_ = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos23_, i32 8)
  br label %NextChar

_is_eof:
  ;: current_char == '\x04' ?
  %is_eof = icmp eq i8 %current_char_v, 4
  br i1 %is_eof, label %it_is_eof, label %else
it_is_eof:
  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.EndOfInput);
  %current_pos23 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos23, i32 7)
  br label %out;

else:
  ;|next_pos => current_pos|(current_pos);
  %current_pos_val24 = load %position, ptr %current_pos
  %next_pos24 = call %position @_1_8next_pos_2_5lexer11current_pos(%lexer %lexer_in, %position %current_pos_val24)
  store %position %next_pos24, ptr %current_pos
  ;|current_char|(lexer, current_pos);
  %current_char24 = call i8 @_1_12current_char2_5lexer11current_pos(%lexer %lexer_in, %position %next_pos24)
  store i8 %current_char24, ptr %current_char

  ;|lexer|(lexer, current_pos, lexem_type = lexem_type.BadChar);
  %current_pos24 = load %position, ptr %current_pos
  call void @_1_5lexer3_5lexer11current_pos10lexem_type(%lexer* %lexer_out, %position %current_pos24, i32 9)
  br label %out;

out:
  %ret = load %lexer, ptr %lexer_out
  ret %lexer %ret
}
