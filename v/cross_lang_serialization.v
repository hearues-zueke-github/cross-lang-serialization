import crypto.sha256
import os
import time

import rand
import rand.seed
import rand.pcg32

const (
	// TODO: move this constant into another file, and read from it
	magic_timestamp = '20250408130000'
	magic_version = '0.1v\0\0\0\0'

	map_type_name_to_type_nr = {
		'u8': 0x01,
		'u16': 0x02,
		'u32': 0x03,
		'u64': 0x04,
		'i8': 0x05,
		'i16': 0x06,
		'i32': 0x07,
		'i64': 0x08,
		'f32': 0x09,
		'f64': 0x0A,
	}

	map_type_nr_to_type_name = {
		u8(0x01): 'u8',
		0x02: 'u16',
		0x03: 'u32',
		0x04: 'u64',
		0x05: 'i8',
		0x06: 'i16',
		0x07: 'i32',
		0x08: 'i64',
		0x09: 'f32',
		0x0A: 'f64',
	}

	map_type_name_to_amount_bytes_per_type = {
		'u8': i32(1),
		'u16': 2,
		'u32': 4,
		'u64': 8,
		'i8': 1,
		'i16': 2,
		'i32': 4,
		'i64': 8,
		'f32': 4,
		'f64': 8,
	}

	empty_dt := time.Time{}
)

struct CrossLangSerialization {
mut:
	map_str_to_arr_u8 map[string][]u8
	map_str_to_arr_u16 map[string][]u16
	map_str_to_arr_u32 map[string][]u32
	map_str_to_arr_u64 map[string][]u64
	map_str_to_arr_i8 map[string][]i8
	map_str_to_arr_i16 map[string][]i16
	map_str_to_arr_i32 map[string][]i32
	map_str_to_arr_i64 map[string][]i64
	map_str_to_arr_f32 map[string][]f32
	map_str_to_arr_f64 map[string][]f64
	dt time.Time
	dt_load time.Time
}

fn CrossLangSerialization.new() CrossLangSerialization {
	return CrossLangSerialization{
		dt: time.now()
	}
}

fn (cross_lang_serialization &CrossLangSerialization) print_data() {
	println('map_str_to_arr_u8: ')
	for key in cross_lang_serialization.map_str_to_arr_u8.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_u8[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_u16: ')
	for key in cross_lang_serialization.map_str_to_arr_u16.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_u16[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_u32: ')
	for key in cross_lang_serialization.map_str_to_arr_u32.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_u32[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_u64: ')
	for key in cross_lang_serialization.map_str_to_arr_u64.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_u64[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_i8: ')
	for key in cross_lang_serialization.map_str_to_arr_i8.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_i8[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_i16: ')
	for key in cross_lang_serialization.map_str_to_arr_i16.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_i16[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_i32: ')
	for key in cross_lang_serialization.map_str_to_arr_i32.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_i32[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_i64: ')
	for key in cross_lang_serialization.map_str_to_arr_i64.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_i64[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_f32: ')
	for key in cross_lang_serialization.map_str_to_arr_f32.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_f32[key])
		println('- "${key}": ${arr}')
	}

	println('map_str_to_arr_f64: ')
	for key in cross_lang_serialization.map_str_to_arr_f64.keys() {
		arr := &(cross_lang_serialization.map_str_to_arr_f64[key])
		println('- "${key}": ${arr}')
	}
}

fn (cross_lang_serialization &CrossLangSerialization) save_data_to_file(file_path string)! {
	println('Write data to file "${file_path}"')
	mut f := os.open_file(file_path, 'wb')!

	mut h := sha256.new()
	
	bytes_magic_timestamp := magic_timestamp.bytes()
	h.write(bytes_magic_timestamp)!
	bytes_magic_version := magic_version.bytes()
	h.write(bytes_magic_version)!

	mut dt := time.Time{}

	if cross_lang_serialization.dt_load == empty_dt {
		dt = cross_lang_serialization.dt
	} else {
		dt = cross_lang_serialization.dt_load
	}

	str_timestamp := '${dt.year:04}${dt.month:02}${dt.day:02}${dt.hour:02}${dt.minute:02}${dt.second:02}${dt.nanosecond / 1000:06}'
	bytes_timestamp := str_timestamp.bytes()
	h.write(bytes_timestamp)!

	arr_key_u8 := cross_lang_serialization.map_str_to_arr_u8.keys().sorted()
	arr_key_u16 := cross_lang_serialization.map_str_to_arr_u16.keys().sorted()
	arr_key_u32 := cross_lang_serialization.map_str_to_arr_u32.keys().sorted()
	arr_key_u64 := cross_lang_serialization.map_str_to_arr_u64.keys().sorted()
	arr_key_i8 := cross_lang_serialization.map_str_to_arr_i8.keys().sorted()
	arr_key_i16 := cross_lang_serialization.map_str_to_arr_i16.keys().sorted()
	arr_key_i32 := cross_lang_serialization.map_str_to_arr_i32.keys().sorted()
	arr_key_i64 := cross_lang_serialization.map_str_to_arr_i64.keys().sorted()
	arr_key_f32 := cross_lang_serialization.map_str_to_arr_f32.keys().sorted()
	arr_key_f64 := cross_lang_serialization.map_str_to_arr_f64.keys().sorted()
	
	amount_elements := (
		arr_key_u8.len + arr_key_u16.len + arr_key_u32.len + arr_key_u64.len +
		arr_key_i8.len + arr_key_i16.len + arr_key_i32.len + arr_key_i64.len +
		arr_key_f32.len + arr_key_f64.len
	)

	mut curr_pos := 0
	mut arr_content_length := []int{len: amount_elements}
	
	for i, key in arr_key_u8 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_u8[key].len * 1
	}
	curr_pos += arr_key_u8.len

	for i, key in arr_key_u16 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_u16[key].len * 2
	}
	curr_pos += arr_key_u16.len

	for i, key in arr_key_u32 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_u32[key].len * 4
	}
	curr_pos += arr_key_u32.len

	for i, key in arr_key_u64 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_u64[key].len * 8
	}
	curr_pos += arr_key_u64.len

	for i, key in arr_key_i8 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_i8[key].len * 1
	}
	curr_pos += arr_key_i8.len

	for i, key in arr_key_i16 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_i16[key].len * 2
	}
	curr_pos += arr_key_i16.len

	for i, key in arr_key_i32 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_i32[key].len * 4
	}
	curr_pos += arr_key_i32.len

	for i, key in arr_key_i64 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_i64[key].len * 8
	}
	curr_pos += arr_key_i64.len


	for i, key in arr_key_f32 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_f32[key].len * 4
	}
	curr_pos += arr_key_f32.len

	for i, key in arr_key_f64 {
		arr_content_length[curr_pos + i] = 32 + 2 + key.len + 1 + 4 + cross_lang_serialization.map_str_to_arr_f64[key].len * 8
	}
	curr_pos += arr_key_f64.len


	println('Write amount_elements as bytes to file')
	ptr_u8_amount_elements := unsafe { &u8(&amount_elements) }
	mut bytes_amount_elements := []u8{len: 4}
	for i in 0..4 {
		bytes_amount_elements[i] = unsafe { ptr_u8_amount_elements[i] }
	}
	h.write(bytes_amount_elements)!

	println('Write arr_content_length as bytes to file')
	ptr_u8_arr_content_length := unsafe { &u8(&arr_content_length[0]) }
	len_bytes_arr_content_length := 4 * arr_content_length.len
	mut bytes_arr_content_length := []u8{len: len_bytes_arr_content_length}
	for i in 0..len_bytes_arr_content_length {
		bytes_arr_content_length[i] = unsafe { ptr_u8_arr_content_length[i] }
	}
	h.write(bytes_arr_content_length)!
	
	bytes_hash_main_metadata_calc := h.sum([]u8{})

	f.write(bytes_hash_main_metadata_calc)!
	f.write(bytes_magic_timestamp)!
	f.write(bytes_magic_version)!
	f.write(bytes_timestamp)!
	f.write(bytes_amount_elements)!
	f.write(bytes_arr_content_length)!

	cross_lang_serialization.save_map_type_arr_data_to_file[u8](mut f, 'u8', arr_key_u8, cross_lang_serialization.map_str_to_arr_u8)!
	cross_lang_serialization.save_map_type_arr_data_to_file[u16](mut f, 'u16', arr_key_u16, cross_lang_serialization.map_str_to_arr_u16)!
	cross_lang_serialization.save_map_type_arr_data_to_file[u32](mut f, 'u32', arr_key_u32, cross_lang_serialization.map_str_to_arr_u32)!
	cross_lang_serialization.save_map_type_arr_data_to_file[u64](mut f, 'u64', arr_key_u64, cross_lang_serialization.map_str_to_arr_u64)!
	cross_lang_serialization.save_map_type_arr_data_to_file[i8](mut f, 'i8', arr_key_i8, cross_lang_serialization.map_str_to_arr_i8)!
	cross_lang_serialization.save_map_type_arr_data_to_file[i16](mut f, 'i16', arr_key_i16, cross_lang_serialization.map_str_to_arr_i16)!
	cross_lang_serialization.save_map_type_arr_data_to_file[i32](mut f, 'i32', arr_key_i32, cross_lang_serialization.map_str_to_arr_i32)!
	cross_lang_serialization.save_map_type_arr_data_to_file[i64](mut f, 'i64', arr_key_i64, cross_lang_serialization.map_str_to_arr_i64)!
	cross_lang_serialization.save_map_type_arr_data_to_file[f32](mut f, 'f32', arr_key_f32, cross_lang_serialization.map_str_to_arr_f32)!
	cross_lang_serialization.save_map_type_arr_data_to_file[f64](mut f, 'f64', arr_key_f64, cross_lang_serialization.map_str_to_arr_f64)!

	f.close()
}

fn (cross_lang_serialization &CrossLangSerialization) save_map_type_arr_data_to_file[T](mut f &os.File, type_name string, arr_key []string, map_str_to_arr_type map[string][]T)! {
	for i, key in arr_key {
		mut h := sha256.new()
	
		len_key := u16(key.len)
		ptr_u8_len_key := unsafe { &u8(&len_key) }
		mut bytes_len_key := []u8{len: 2}
		for j in 0..2 {
			bytes_len_key[j] = unsafe { ptr_u8_len_key[j] }
		}

		bytes_key := key.bytes()

		type_nr := map_type_name_to_type_nr[type_name]
		amount_bytes_per_type := map_type_name_to_amount_bytes_per_type[type_name]

		bytes_type_nr := [u8(type_nr)]

		arr := map_str_to_arr_type[key]
		
		amount_elements_arr := arr.len
		ptr_u8_amount_elements_arr := unsafe { &u8(&amount_elements_arr) }
		mut bytes_amount_elements_arr := []u8{len: 4}
		for j in 0..4 {
			bytes_amount_elements_arr[j] = unsafe { ptr_u8_amount_elements_arr[j] }
		}

		ptr_u8_arr := unsafe { &u8(&arr[0]) }
		len_bytes_arr := amount_elements_arr * amount_bytes_per_type
		mut bytes_arr := []u8{len: len_bytes_arr}
		for j in 0..len_bytes_arr {
			bytes_arr[j] = unsafe { ptr_u8_arr[j] }
		}

		h.write(bytes_len_key)!
		h.write(bytes_key)!
		h.write(bytes_type_nr)!
		h.write(bytes_amount_elements_arr)!
		h.write(bytes_arr)!

		bytes_hash_metadata := h.sum([]u8{})

		f.write(bytes_hash_metadata)!
		f.write(bytes_len_key)!
		f.write(bytes_key)!
		f.write(bytes_type_nr)!
		f.write(bytes_amount_elements_arr)!
		f.write(bytes_arr)!
	}
}

fn (mut cross_lang_serialization CrossLangSerialization) load_data_from_file(file_path string)! {
	mut f := os.open_file(file_path, 'rb')!

	mut curr_pos := u64(0)

	bytes_hash_main_metadata := f.read_bytes_at(32, curr_pos)
	curr_pos += 32
	bytes_magic_timestamp := f.read_bytes_at(14, curr_pos)
	curr_pos += 14
	bytes_magic_version := f.read_bytes_at(8, curr_pos)
	curr_pos += 8
	bytes_timestamp := f.read_bytes_at(20, curr_pos)
	curr_pos += 20

	str_timestamp := bytes_timestamp.bytestr()
	cross_lang_serialization.dt_load = time.Time{
		year: str_timestamp[0..4].int(),
		month: str_timestamp[4..6].int(),
		day: str_timestamp[6..8].int(),
		hour: str_timestamp[8..10].int(),
		minute: str_timestamp[10..12].int(),
		second: str_timestamp[12..14].int(),
		nanosecond: str_timestamp[14..20].int() * 1000,
	}

	println('bytes_hash_main_metadata: ${bytes_hash_main_metadata}')
	println('bytes_magic_timestamp: ${bytes_magic_timestamp}')
	println('bytes_magic_version: ${bytes_magic_version}')
	println('bytes_timestamp: ${bytes_timestamp}')

	bytes_amount_elements := f.read_bytes_at(4, curr_pos)
	curr_pos += 4
	amount_elements := unsafe { (&u32(&bytes_amount_elements[0]))[0] }

	println('bytes_amount_elements: ${bytes_amount_elements}')
	println('amount_elements: ${amount_elements}')

	len_bytes_arr_content_length := 4 * int(amount_elements)
	bytes_arr_content_length := f.read_bytes_at(len_bytes_arr_content_length, curr_pos)
	curr_pos += u64(len_bytes_arr_content_length)
	mut arr_content_length := []u32{len: int(amount_elements)}
	ptr_u32_content_length := unsafe { &u32(&bytes_arr_content_length[0]) }
	for i in 0..amount_elements {
		arr_content_length[i] = unsafe { ptr_u32_content_length[i] }
	}

	println('bytes_arr_content_length: ${bytes_arr_content_length}')
	println('arr_content_length: ${arr_content_length}')

	println('${sha256.hexhash('Rosetta code')}')

	mut h := sha256.new()
	
	h.write(bytes_magic_timestamp)!
	h.write(bytes_magic_version)!
	h.write(bytes_timestamp)!
	h.write(bytes_amount_elements)!
	h.write(bytes_arr_content_length)!

	bytes_hash_main_metadata_calc := h.sum([]u8{})
	println('${bytes_hash_main_metadata_calc.hex()}')
	assert bytes_hash_main_metadata_calc == bytes_hash_main_metadata

	for i in 0..amount_elements {
		content_length := arr_content_length[i]

		bytes_hash_metadata := f.read_bytes_at(32, curr_pos)
		curr_pos += 32

		bytes_len_key := f.read_bytes_at(2, curr_pos)
		curr_pos += 2
		len_key := unsafe { (&u16(&bytes_len_key[0]))[0] }

		bytes_key := f.read_bytes_at(int(len_key), curr_pos)
		curr_pos += len_key
		key := bytes_key.bytestr()

		bytes_type_nr := f.read_bytes_at(1, curr_pos)
		curr_pos += 1
		type_nr := bytes_type_nr[0]
		
		bytes_amount_elements_arr := f.read_bytes_at(4, curr_pos)
		curr_pos += 4
		amount_elements_arr := int(unsafe { (&u32(&bytes_amount_elements_arr[0]))[0] })

		type_name := map_type_nr_to_type_name[type_nr]
		amount_bytes_per_type := map_type_name_to_amount_bytes_per_type[type_name]

		len_bytes_arr := amount_elements_arr * amount_bytes_per_type
		bytes_arr := f.read_bytes_at(len_bytes_arr, curr_pos)
		curr_pos += u64(len_bytes_arr)

		println('bytes_hash_metadata: ${bytes_hash_metadata}')
		println('---------------')
		println('bytes_len_key: ${bytes_len_key}')
		println('len_key: ${len_key}')
		println('---------------')
		println('bytes_key: ${bytes_key}')
		println('key: "${key}"')
		println('---------------')
		println('bytes_type_nr: ${bytes_type_nr}')
		println('type_nr: ${type_nr}')
		println('type_name: "${type_name}"')
		println('---------------')
		println('bytes_amount_elements_arr: ${bytes_amount_elements_arr}')
		println('amount_elements_arr: ${amount_elements_arr}')
		println('len_bytes_arr: ${len_bytes_arr}')
		println('---------------')
		println('bytes_arr: ${bytes_arr}')
		println('---------------')

		println('- bytes_hash_metadata.len: ${bytes_hash_metadata.len}')
		println('- bytes_len_key.len: ${bytes_len_key.len}')
		println('- bytes_key.len: ${bytes_key.len}')
		println('- bytes_type_nr.len: ${bytes_type_nr.len}')
		println('- bytes_amount_elements_arr.len: ${bytes_amount_elements_arr.len}')
		println('- bytes_arr.len: ${bytes_arr.len}')
		
		assert content_length == bytes_hash_metadata.len +
			bytes_len_key.len +
			bytes_key.len +
			bytes_type_nr.len +
			bytes_amount_elements_arr.len +
			bytes_arr.len

		mut h_2 := sha256.new()
	
		h_2.write(bytes_len_key)!
		h_2.write(bytes_key)!
		h_2.write(bytes_type_nr)!
		h_2.write(bytes_amount_elements_arr)!
		h_2.write(bytes_arr)!

		bytes_hash_metadata_calc := h_2.sum([]u8{})
		println('${bytes_hash_metadata_calc.hex()}')
		println('')
		assert bytes_hash_metadata_calc == bytes_hash_metadata

		match type_name {
			'u8' {
				mut arr := []u8{len: amount_elements_arr}
				ptr_u8 := unsafe { &u8(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_u8[j] }
				}
				cross_lang_serialization.map_str_to_arr_u8[key] = arr
			}
			'u16' {
				mut arr := []u16{len: amount_elements_arr}
				ptr_u16 := unsafe { &u16(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_u16[j] }
				}
				cross_lang_serialization.map_str_to_arr_u16[key] = arr
			}
			'u32' {
				mut arr := []u32{len: amount_elements_arr}
				ptr_u32 := unsafe { &u32(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_u32[j] }
				}
				cross_lang_serialization.map_str_to_arr_u32[key] = arr
			}
			'u64' {
				mut arr := []u64{len: amount_elements_arr}
				ptr_u64 := unsafe { &u64(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_u64[j] }
				}
				cross_lang_serialization.map_str_to_arr_u64[key] = arr
			}
			'i8' {
				mut arr := []i8{len: amount_elements_arr}
				ptr_i8 := unsafe { &i8(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_i8[j] }
				}
				cross_lang_serialization.map_str_to_arr_i8[key] = arr
			}
			'i16' {
				mut arr := []i16{len: amount_elements_arr}
				ptr_i16 := unsafe { &i16(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_i16[j] }
				}
				cross_lang_serialization.map_str_to_arr_i16[key] = arr
			}
			'i32' {
				mut arr := []i32{len: amount_elements_arr}
				ptr_i32 := unsafe { &i32(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_i32[j] }
				}
				cross_lang_serialization.map_str_to_arr_i32[key] = arr
			}
			'i64' {
				mut arr := []i64{len: amount_elements_arr}
				ptr_i64 := unsafe { &i64(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_i64[j] }
				}
				cross_lang_serialization.map_str_to_arr_i64[key] = arr
			}
			'f32' {
				mut arr := []f32{len: amount_elements_arr}
				ptr_f32 := unsafe { &f32(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_f32[j] }
				}
				cross_lang_serialization.map_str_to_arr_f32[key] = arr
			}
			'f64' {
				mut arr := []f64{len: amount_elements_arr}
				ptr_f64 := unsafe { &f64(&bytes_arr[0]) }
				for j in 0..amount_elements_arr {
					arr[j] = unsafe { ptr_f64[j] }
				}
				cross_lang_serialization.map_str_to_arr_f64[key] = arr
			}
			else {
				assert false
			}
		}
	}

	f.close()
}

fn main() {
	mut rng := rand.PRNG(pcg32.PCG32RNG{})
	arr_seed := seed.time_seed_array(pcg32.seed_len)
	rng.seed(arr_seed)

	println('arr_seed: ${arr_seed}')

	mut cross_lang_serialization := CrossLangSerialization.new()

	// load a test file, which was already created
	file_path_1 := '/tmp/test_1.arrhex'
	cross_lang_serialization.load_data_from_file(file_path_1)!
	file_path_2 := '/tmp/test_v_data_1.arrhex'
	cross_lang_serialization.save_data_to_file(file_path_2)!

	cross_lang_serialization.print_data()

	println('cross_lang_serialization.dt: ${cross_lang_serialization.dt}')
	println('cross_lang_serialization.dt_load: ${cross_lang_serialization.dt_load}')
	println('cross_lang_serialization.dt_load == empty_dt? ${cross_lang_serialization.dt_load == empty_dt}')

	println('magic_timestamp: ${magic_timestamp}')
	println('magic_version: ${magic_version}')
}
