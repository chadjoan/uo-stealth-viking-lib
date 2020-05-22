unit viking_arrays;

interface
uses
	viking_types,
	viking_string_algorithms;

function parse_uint16_array(text_ : String) : uint16_array;

function cmp_uint32_array(
	var array1_ : uint32_array; var array2_ : uint32_array)
	: index_t;

function uint32_array_to_hex_string(const toPrint_ : uint32_array) : String;

implementation

function parse_uint16_array(text_ : String) : uint16_array;
var
	pos    : index_t;
	tlen   : index_t;
	count  : index_t;
	idx    : index_t;
	elems  : uint16_array;
	hexStr : String;
	ch     : Char;
begin
	count := 0;
	tlen  := length(text_);
	for pos := 1 to tlen do
		if text_[pos] = ',' then
			count := count + 1;

	// Ex: '1234,ABCD,7890' -> 2 commas -> 3 elements
	SetLength(elems, count+1);

	idx := 0;
	pos := 1;
	while pos <= tlen do
	begin
		pos := skip_whitespace(text_, pos, tlen);

		hexStr := tokenize_hex(text_, pos, tlen);
		pos := pos + length(hexStr)+1;
		elems[idx] := StrToInt('$'+hexStr);
		idx := idx + 1;

		pos := skip_whitespace(text_, pos, tlen);

		if (pos <= tlen) then
		begin
			ch := text_[pos];
			if (Ord(ch) = 0) then
				break // Null terminator character.
			else if (text_[pos] = ',') then
				pos := pos + 1
			else
				RaiseException(erException,
					'Error: Unexpected character "'+char_escape_nonprintable(ch)+'"'+
					' at position '+IntToStr(pos)+' in text "'+text_+'".');
		end;
	end;

	Result := elems;
end;

function cmp_uint32_array(
	var array1_ : uint32_array; var array2_ : uint32_array) : index_t;
var
	idx, offset : index_t;
begin
	if length(array1_) > length(array2_) then
		Result := 1
	else if length(array1_) < length(array2_) then
		Result := -1
	else
	begin
		offset := Low(array2_) - Low(array1_);
		for idx := Low(array1_) to High(array1_) do
		begin
			if array1_[idx] > array2_[idx+offset] then
				Result := 1
			else if array1_[idx] < array2_[idx+offset] then
				Result := -1
			else
				Result := 0;
		end;
	end;
end;

function uint32_array_to_hex_string(const toPrint_ : uint32_array) : String;
var
	idx     : index_t;
	buffer  : String;
begin
	buffer := '[';
	if length(toPrint_) > 0 then
		buffer := buffer + '$' + IntToHex(toPrint_[0],8);
	for idx := 1 to length(toPrint_)-1 do
	begin
		buffer := buffer + ',$' + IntToHex(toPrint_[idx],8);
	end;
	buffer := buffer + ']';
	Result := buffer;
end;

function uint16_array_contains(haystack_ :uint16_array;  needle_ :uint16) : boolean;
var
	idx : index_t;
begin
	for idx := Low(haystack_) to High(haystack_) do
	begin
		if needle_ = haystack_[idx] then
		begin
			Result := true;
			Exit;
		end;
	end;
	Result := false; 
end;

end.