# cross-lang-serialization
A tool/framework/description of a possible (de)serialization of data for different programming languages.

The idea would be to make data integrity a part of the serialization too.

For this project we will use the the following naming convention (similar to Rust, Zig, Nim etc.):

|Type name|Called in this project|
|-|-|
|String|`str`|
|Int 8, 16, 32, 64|`i8`, `i16`, `i32`, `i64`|
|UInt 8, 16, 32, 64|`u8`, `u16`, `u32`, `u64`|
|Float 32, 64|`f32`, `f64`|
|Boolean|`bool`|

What sould be definitly possible is to use an array for a key or a value for maps too.

Goals:
[ ] base type arrays (`str`, `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`, `f32`, `f64`, `bool`)
[ ] base type maps (similar to arrays, but for key and value)
[ ] array in key and/or value in maps

The structure for an serilizated array is something like this:
- MAGIC bytes
- timestamp of the version which was used for serilization
- SHA256 hash of the meta data
- length of the metadata (8 bytes = 64bits number, u64)
- metadata such as datatype `T`, length `l` of the array as u64 (not the amount of bytes needed for the data!!) and the SHA256 of the data itself
- an array with the type `T` and length `l`
