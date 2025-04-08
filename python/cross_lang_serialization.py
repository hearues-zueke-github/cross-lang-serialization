import numpy as np

from datetime import datetime
from hashlib import sha256

MAGIC_TIMESTAMP = '20250408130000'
MAGIC_VERSION = '0.1v\0\0\0\0'

d_np_type_name_to_type_nr = {
	'uint8': 0x01,
	'uint16': 0x02,
	'uint32': 0x03,
	'uint64': 0x04,
	'int8': 0x05,
	'int16': 0x06,
	'int32': 0x07,
	'int64': 0x08,
	'float32': 0x09,
	'float64': 0x0A,
}
d_type_nr_to_np_type_name = {v: k for k, v in d_np_type_name_to_type_nr.items()}

d_type_name_to_np_type = {
	'uint8': np.uint8,
	'uint16': np.uint16,
	'uint32': np.uint32,
	'uint64': np.uint64,
	'int8': np.int8,
	'int16': np.int16,
	'int32': np.int32,
	'int64': np.int64,
	'float32': np.float32,
	'float64': np.float64,
}

class CrossLangSerialization:
	def __init__(self):
		self.d_str_to_arr_u8 = {}
		self.d_str_to_arr_u16 = {}
		self.d_str_to_arr_u32 = {}
		self.d_str_to_arr_u64 = {}
		self.d_str_to_arr_i8 = {}
		self.d_str_to_arr_i16 = {}
		self.d_str_to_arr_i32 = {}
		self.d_str_to_arr_i64 = {}
		self.d_str_to_arr_f32 = {}
		self.d_str_to_arr_f64 = {}

		self.d_type_name_to_d_str_to_arr_type = {}
		self.d_type_name_to_d_str_to_arr_type['uint8'] = self.d_str_to_arr_u8
		self.d_type_name_to_d_str_to_arr_type['uint16'] = self.d_str_to_arr_u16
		self.d_type_name_to_d_str_to_arr_type['uint32'] = self.d_str_to_arr_u32
		self.d_type_name_to_d_str_to_arr_type['uint64'] = self.d_str_to_arr_u64
		self.d_type_name_to_d_str_to_arr_type['int8'] = self.d_str_to_arr_i8
		self.d_type_name_to_d_str_to_arr_type['int16'] = self.d_str_to_arr_i16
		self.d_type_name_to_d_str_to_arr_type['int32'] = self.d_str_to_arr_i32
		self.d_type_name_to_d_str_to_arr_type['int64'] = self.d_str_to_arr_i64
		self.d_type_name_to_d_str_to_arr_type['float32'] = self.d_str_to_arr_f32
		self.d_type_name_to_d_str_to_arr_type['float64'] = self.d_str_to_arr_f64

		self.dt = datetime.now()
		self.dt_load = None


	def equal(self, other):
		l_d1_d2 = [
			(self.d_str_to_arr_u8, other.d_str_to_arr_u8),
			(self.d_str_to_arr_u16, other.d_str_to_arr_u16),
			(self.d_str_to_arr_u32, other.d_str_to_arr_u32),
			(self.d_str_to_arr_u64, other.d_str_to_arr_u64),
			(self.d_str_to_arr_i8, other.d_str_to_arr_i8),
			(self.d_str_to_arr_i16, other.d_str_to_arr_i16),
			(self.d_str_to_arr_i32, other.d_str_to_arr_i32),
			(self.d_str_to_arr_i64, other.d_str_to_arr_i64),
			(self.d_str_to_arr_f32, other.d_str_to_arr_f32),
			(self.d_str_to_arr_f64, other.d_str_to_arr_f64),
		]

		for d1, d2 in l_d1_d2:
			if d1.keys() != d2.keys():
				return False

			for key in d1.keys():
				if np.all(d1[key] != d2[key]):
					return False

		return True


	def save_data_to_file(self, file_path):
		# hash, of the overall metadata
		# magic number, the version of the serialization
		# magic number timestamp
		# timestamp, as string with format: YYYYMMDDhhmmssffffff
		# u32, number of amount of data
		# []u32, length of the content itself

		# per content:
		# hash of meta + data
		# string length u16
		# string name
		# data type u8
		# amount of elements u32
		# data itself in u8 format, length of bytes is amount of elements * bytes of type
		
		timestamp_str = datetime.strftime(self.dt, '%Y%m%d%H%M%S%f')
		
		# prepare all metadata of each content
		l_metadata = []

		for d, np_type in (
			(self.d_str_to_arr_u8, np.uint8),
			(self.d_str_to_arr_u16, np.uint16),
			(self.d_str_to_arr_u32, np.uint32),
			(self.d_str_to_arr_u64, np.uint64),
			(self.d_str_to_arr_i8, np.int8),
			(self.d_str_to_arr_i16, np.int16),
			(self.d_str_to_arr_i32, np.int32),
			(self.d_str_to_arr_i64, np.int64),
			(self.d_str_to_arr_f32, np.float32),
			(self.d_str_to_arr_f64, np.float64),
		):
			l_key = sorted(d.keys())
			for key in l_key:
				arr = d[key]
				type_byte_amount = np_type().size
				content_length = 32 + 2 + len(key) + 1 + 4 + type_byte_amount * arr.shape[0]
				l_metadata.append((d, key, arr, np_type, content_length))

		l_content_length = []
		for _, _, _, _, content_length in l_metadata:
			l_content_length.append(content_length)

		print(f'l_content_length: {l_content_length}')

		amount = len(l_content_length)

		arr_main_metadata = np.hstack((
			np.array(bytearray((MAGIC_TIMESTAMP.encode('utf-8')))),
			np.array(bytearray((MAGIC_VERSION.encode('utf-8')))),
			np.array(bytearray((timestamp_str.encode('utf-8')))),
			np.array([amount], dtype=np.uint32).view(np.uint8),
			np.array(l_content_length, dtype=np.uint32).view(np.uint8),
		))
		print(f'arr_main_metadata: {arr_main_metadata}')
		str_hex_main_metadata = ''.join([f'{v:02x}' for v in arr_main_metadata])
		print(f'str_hex_main_metadata: {str_hex_main_metadata}')

		arr_hash_main_metadata = np.array(list(sha256(arr_main_metadata.data).digest()), dtype=np.uint8)
		print(f'arr_hash_main_metadata: {arr_hash_main_metadata}')
		str_hex_hash_main_metadata = ''.join([f'{v:02x}' for v in arr_hash_main_metadata])
		print(f'str_hex_hash_main_metadata: {str_hex_hash_main_metadata}')

		with open(file_path, 'wb') as f:
			f.write(arr_hash_main_metadata.data)
			f.write(arr_main_metadata.data)

			for d, key, arr, np_type, content_length in l_metadata:
				len_key = len(key)
				type_nr = d_np_type_name_to_type_nr[np_type.__name__]
				amount_elements = arr.shape[0]

				arr_metadata = np.hstack((
					np.array([len_key], dtype=np.uint16).view(np.uint8),
					np.array(bytearray((key.encode('utf-8')))),
					np.array([type_nr], dtype=np.uint8).view(np.uint8),
					np.array([amount_elements], dtype=np.uint32).view(np.uint8),
				))

				hash_sha256 = sha256()
				hash_sha256.update(arr_metadata.data)
				hash_sha256.update(arr.data)
				arr_hash_metadata_data = np.array(list(hash_sha256.digest()), dtype=np.uint8)

				f.write(arr_hash_metadata_data.data)
				f.write(arr_metadata.data)
				f.write(arr.data)

		globals()['loc_save'] = locals()


	def load_data_from_file(self, file_path):
		with open(file_path, 'rb') as f:
			bytes_hash_main_metadata = f.read(32)
			bytes_magic_timestamp = f.read(14)
			bytes_magic_version = f.read(8)
			bytes_timestamp = f.read(20)
			amount_elements = np.fromfile(f, dtype=np.uint32, count=1)[0]
			arr_content_length = np.fromfile(f, dtype=np.uint32, count=amount_elements)
			
			self.dt_load = datetime.strptime(bytes_timestamp.decode('utf-8'), '%Y%m%d%H%M%S%f')

			hash_sha256 = sha256()

			hash_sha256.update(bytes_magic_timestamp)
			hash_sha256.update(bytes_magic_version)
			hash_sha256.update(bytes_timestamp)
			hash_sha256.update(amount_elements.tobytes())
			hash_sha256.update(arr_content_length.data)

			assert hash_sha256.digest() == bytes_hash_main_metadata

			for i in range(0, amount_elements):
				bytes_hash_metadata = f.read(32)
				len_key = np.fromfile(f, dtype=np.uint16, count=1)[0]
				key = f.read(len_key).decode('utf-8')

				type_nr = np.fromfile(f, dtype=np.uint8, count=1)[0]
				amount_elements = np.fromfile(f, dtype=np.uint32, count=1)[0]
				
				type_name = d_type_nr_to_np_type_name[type_nr]
				np_type = d_type_name_to_np_type[type_name]

				arr = np.fromfile(f, dtype=np_type, count=amount_elements)
				self.d_type_name_to_d_str_to_arr_type[type_name][key] = arr

				hash_sha256 = sha256()

				hash_sha256.update(len_key.tobytes())
				hash_sha256.update(key.encode('utf-8'))
				hash_sha256.update(type_nr.tobytes())
				hash_sha256.update(amount_elements.tobytes())
				hash_sha256.update(arr.data)

				assert hash_sha256.digest() == bytes_hash_metadata


		globals()['loc_load'] = locals()


if __name__ == '__main__':
	print('Hello World!')

	arr_u8 = np.random.randint(0, 256, size=(19, ), dtype=np.uint8)
	arr_u16 = np.random.randint(0, 256, size=(6, ), dtype=np.uint8).view(np.uint16)
	arr_u32 = np.random.randint(0, 256, size=(8, ), dtype=np.uint8).view(np.uint32)
	arr_u64 = np.random.randint(0, 256, size=(24, ), dtype=np.uint8).view(np.uint64)

	arr_i8 = np.random.randint(0, 256, size=(20, ), dtype=np.uint8).view(np.int8)
	arr_i16 = np.random.randint(0, 256, size=(10, ), dtype=np.uint8).view(np.int16)
	arr_i32 = np.random.randint(0, 256, size=(12, ), dtype=np.uint8).view(np.int32)
	arr_i64 = np.random.randint(0, 256, size=(32, ), dtype=np.uint8).view(np.int64)
	
	arr_f32 = np.random.randint(0, 256, size=(20, ), dtype=np.uint8).view(np.float32)
	arr_f64 = np.random.randint(0, 256, size=(16, ), dtype=np.uint8).view(np.float64)

	print(f'arr_u8: {arr_u8}')
	print(f'arr_u16: {arr_u16}')
	print(f'arr_u32: {arr_u32}')
	print(f'arr_u64: {arr_u64}')
	print(f'arr_i8: {arr_i8}')
	print(f'arr_i16: {arr_i16}')
	print(f'arr_i32: {arr_i32}')
	print(f'arr_i64: {arr_i64}')
	print(f'arr_f32: {arr_f32}')
	print(f'arr_f64: {arr_f64}')

	cross_lang_serialization = CrossLangSerialization()
	cross_lang_serialization.d_str_to_arr_u8['arr_u8'] = arr_u8
	cross_lang_serialization.d_str_to_arr_u16['arr_u16'] = arr_u16
	cross_lang_serialization.d_str_to_arr_u32['arr_u32'] = arr_u32
	cross_lang_serialization.d_str_to_arr_u64['arr_u64'] = arr_u64
	cross_lang_serialization.d_str_to_arr_i8['arr_i8'] = arr_i8
	cross_lang_serialization.d_str_to_arr_i16['arr_i16'] = arr_i16
	cross_lang_serialization.d_str_to_arr_i32['arr_i32'] = arr_i32
	cross_lang_serialization.d_str_to_arr_i64['arr_i64'] = arr_i64
	cross_lang_serialization.d_str_to_arr_f32['arr_f32'] = arr_f32
	cross_lang_serialization.d_str_to_arr_f64['arr_f64'] = arr_f64

	file_path_1 = '/tmp/test_1.arrhex'
	cross_lang_serialization.save_data_to_file(file_path=file_path_1)

	cross_lang_serialization_load_1 = CrossLangSerialization()
	cross_lang_serialization_load_1.load_data_from_file(file_path=file_path_1)
	
	file_path_2 = '/tmp/test_2.arrhex'
	cross_lang_serialization_load_1.save_data_to_file(file_path=file_path_2)

	cross_lang_serialization_load_2 = CrossLangSerialization()
	cross_lang_serialization_load_2.load_data_from_file(file_path=file_path_2)

	assert cross_lang_serialization.equal(cross_lang_serialization_load_1)
	assert cross_lang_serialization.equal(cross_lang_serialization_load_2)
	assert cross_lang_serialization_load_1.equal(cross_lang_serialization_load_2)
