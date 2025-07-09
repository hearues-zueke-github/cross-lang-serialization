module arraybyte_serialization

import rand
import rand.seed
import rand.pcg32

fn test_simple_loading_saving_of_data()! {
	mut rng := rand.PRNG(pcg32.PCG32RNG{})
	arr_seed := seed.time_seed_array(pcg32.seed_len)
	rng.seed(arr_seed)

	println('arr_seed: ${arr_seed}')

	mut cross_lang_serialization_1 := CrossLangSerialization.new()

	// load a test file, which was already created
	file_path_1 := '/tmp/test_1.arrhex'
	cross_lang_serialization_1.load_data_from_file(file_path_1)!
	file_path_2 := '/tmp/test_v_data_1.arrhex'
	cross_lang_serialization_1.save_data_to_file(file_path_2)!

	cross_lang_serialization_1.print_data()

	mut cross_lang_serialization_2 := CrossLangSerialization.new()
	cross_lang_serialization_2.load_data_from_file(file_path_2)!

	println('cross_lang_serialization_1.dt: ${cross_lang_serialization_1.dt}')
	println('cross_lang_serialization_1.dt_load: ${cross_lang_serialization_1.dt_load}')
	println('cross_lang_serialization_1.dt_load == empty_dt? ${cross_lang_serialization_1.dt_load == empty_dt}')

	println('cross_lang_serialization_1.dt: ${cross_lang_serialization_1.dt}')
	println('cross_lang_serialization_1.dt_load: ${cross_lang_serialization_1.dt_load}')
	println('cross_lang_serialization_1.dt_load == empty_dt? ${cross_lang_serialization_1.dt_load == empty_dt}')

	println('magic_timestamp: ${magic_timestamp}')
	println('magic_version: ${magic_version}')

	are_two_serializations_equal := cross_lang_serialization_2.equal(cross_lang_serialization_1)
	println('check if cross_lang_serialization_1 and cross_lang_serialization_2 are equal? ${are_two_serializations_equal}')

	if !are_two_serializations_equal {
		panic('The two serializations of data are not equal!')
	}

	// change only one value from a map in the cross_lang_serialization_2 object
	map_str_to_arr_u16 := unsafe { &(cross_lang_serialization_2.map_str_to_arr_u16) }
	keys := map_str_to_arr_u16.keys()
	key := keys[0]
	arr_u16 := unsafe { &(map_str_to_arr_u16[key]) }
	orig_val_u16 := unsafe { arr_u16[0] }
	unsafe { arr_u16[0] += 1 }

	println('changed one value in cross_lang_serialization_2 in one array of map_str_to_arr_u16.')

	are_two_serializations_still_equal := cross_lang_serialization_2.equal(cross_lang_serialization_1)
	println('check if cross_lang_serialization_1 and cross_lang_serialization_2 are still equal? ${are_two_serializations_still_equal}')

	if are_two_serializations_still_equal {
		panic('The two serializations of data are equal!')
	}

	// now save cross_lang_serialization_2 as file
	file_path_3 := '/tmp/test_v_data_2.arrhex'
	cross_lang_serialization_2.save_data_to_file(file_path_3)!

	mut cross_lang_serialization_3 := CrossLangSerialization.new()
	cross_lang_serialization_3.load_data_from_file(file_path_3)!

	println('changed one value back in cross_lang_serialization_2 in one array of map_str_to_arr_u16.')
	unsafe { arr_u16[0] -= 1 }

	are_two_serializations_still_equal_again := cross_lang_serialization_2.equal(cross_lang_serialization_1)
	println('check if cross_lang_serialization_1 and cross_lang_serialization_2 are again still equal? ${are_two_serializations_still_equal_again}')

	if !are_two_serializations_still_equal_again {
		panic('The two serializations of data are not equal!')
	}

	println('check if cross_lang_serialization_1 and cross_lang_serialization_3 are not equal.')

	are_cross_lang_serialization_1_and_3_equal := cross_lang_serialization_1.equal(cross_lang_serialization_3)
	println('check if cross_lang_serialization_1 and cross_lang_serialization_3 are equal? ${are_cross_lang_serialization_1_and_3_equal}')

	if are_cross_lang_serialization_1_and_3_equal {
		panic('cross_lang_serialization_1 and cross_lang_serialization_3 are equal!')
	}
}
