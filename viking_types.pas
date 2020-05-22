unit viking_types;

interface

type
	// Signed integers
	int8   = Shortint;
	int16  = Smallint;
	int32  = Integer;
	//int64  = Int64; // Already declared in RemObjects PascalScript
	
	// Unsigned integers
	uint8  = Byte;
	uint16 = Word;
	uint32 = Cardinal;
	//uint64 = UInt64; // TODO: Not sure how to define this in PascalScript
	
	// Use this for array indices.
	// If you use something else, the plague of "Type Mismatch" errors will
	// be upon you!
	index_t = int32;

	int8_array  = Array of int8;
	int16_array = Array of int16;
	int32_array = Array of int32;
	int64_array = Array of int64;

	uint8_array  = Array of uint8;
	uint16_array = Array of uint16;
	uint32_array = Array of uint32;
	//uint64_array = Array of uint64;

	index_array = int32_array;

	// Strings.
	string_array = Array of String;

end.