%string = type { i32, i8* }

@.open_err = private unnamed_addr constant [12 x i8] c"Open Error\0A\00"
@.read_err = private unnamed_addr constant [12 x i8] c"Read Error\0A\00"
@.malloc_err = private unnamed_addr constant [14 x i8] c"Malloc Error\0A\00"
@.close_err = private unnamed_addr constant [13 x i8] c"Close Error\0A\00"
@.debug_str = private unnamed_addr constant [6 x i8] c"%llX\0A\00"

declare i32 @open(i8*, i32) nounwind
declare i64 @lseek(i32, i64, i32) nounwind
declare i8* @malloc(i64) nounwind
declare i8* @realloc(ptr, i64) nounwind
declare i64 @read(i32, i8*, i64) nounwind
declare i32 @close(i32) nounwind

declare i32 @printf(ptr noundef, ...) nounwind
declare void @exit(i32) nounwind

%array = type { i32, i32, ptr }

declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)

;array|(array, new_entry = array.entry)
define void @_1_5array2_5array9new_entry(%array* %array_ptr, i64 %entry_size, ptr %new_entry)
{
  ;array.len >= array.capacity ?
  %array_val = load %array, ptr %array_ptr
  %len = extractvalue %array %array_val, 0
  %capacity = extractvalue %array %array_val, 1

  %capacity_not_enough = icmp uge i32 %len, %capacity
  br i1 %capacity_not_enough, label %extend_capacity, label %add_entry

extend_capacity:
  ;array.capacity += 256;
  %new_capacity = add i32 256, %capacity
  %array_val2 = insertvalue %array %array_val, i32 %new_capacity, 1
  ;size = array.capacity * array.entry.size;
  %new_capacity64 = zext i32 %new_capacity to i64
  %new_size = mul i64 %entry_size, %new_capacity64
  ;|&array.entries|(ptr = &aray.entries, size; #realloc);
  %entries = extractvalue %array %array_val2, 2
  %new_entries = call i8* @realloc(ptr %entries, i64 %new_size)
  %ptr = ptrtoint ptr %new_entries to i64
  %is_ok = icmp ugt i64 %ptr, 0
  br i1 %is_ok, label %ok2, label %err2

err2:
  %nn = call i32 (ptr, ...) @printf(ptr noundef @.malloc_err)
  call void @exit(i32 1)
  unreachable

ok2:
  %array_val3 = insertvalue %array %array_val2, ptr %new_entries, 2
  store %array %array_val3, ptr %array_ptr
  br label %add_entry

add_entry:
  ;array.entries[array.len] = new_entry;
  %array_val4 = load %array, ptr %array_ptr
  %len2 = extractvalue %array %array_val4, 0
  %entries2 = extractvalue %array %array_val4, 2
  %len64 = zext i32 %len2 to i64
  %offset = mul i64 %len64, %entry_size
  %new_entry_ptr = getelementptr i8, ptr %entries2, i64 %offset
  call void @llvm.memcpy.p0.p0.i64(ptr %new_entry_ptr, ptr %new_entry, i64 %entry_size, i1 false)

  ;array.len += 1
  %lenp1 = add i32 1, %len2
  %array_val5 = insertvalue %array %array_val4, i32 %lenp1, 0
  store %array %array_val5, ptr %array_ptr

  ret void
}

define {i8*, i64} @_1_8filename2_8filedata8filesize(i8* %filename) {
  
  %1 = call i32 @open(i8* %filename, i32 0)
  %2 = icmp ugt i32 %1, 0
  br i1 %2, label %ok1, label %err1

err1:
  %3 = call i32 (ptr, ...) @printf(ptr noundef @.open_err)
  call void @exit(i32 1)
  unreachable

ok1:
  %size = call i64 @lseek(i32 %1, i64 0, i32 2)
  %4 = call i64 @lseek(i32 %1, i64 0, i32 0)
  %filedata = call i8* @malloc(i64 %size)
  %filedataptr = ptrtoint ptr %filedata to i64
  %5 = icmp ugt i64 %filedataptr, 0
  br i1 %5, label %ok2, label %err2

err2:
  %6 = call i32 (ptr, ...) @printf(ptr noundef @.malloc_err)
  call void @exit(i32 1)
  unreachable

ok2:
  %rsize = call i64 @read(i32 %1, i8* %filedata, i64 %size)
  %7 = icmp eq i64 %rsize, %size
  br i1 %7, label %ok3, label %err3

err3:
  %8 = call i32 (ptr, ...) @printf(ptr noundef @.malloc_err)
  call void @exit(i32 1)
  unreachable

ok3:
  %9 = call i32 @close(i32 %1)
  %10 = icmp eq i32 %9, 0
  br i1 %10, label %ok4, label %err4

err4:
  %11 = call i32 (ptr, ...) @printf(ptr noundef @.close_err)
  call void @exit(i32 1)
  unreachable

ok4:
  %ret1 = insertvalue {i8*, i64} undef, i8* %filedata, 0
  %ret2 = insertvalue {i8*, i64} %ret1, i64 %size, 1
  ret {i8*, i64} %ret2
}
