unit viking_utf;

interface
uses
	viking_types,
	viking_testing;

type
	utf8_x4_t = Array [0..3] of uint8;

procedure viking_utf_run_tests(runner_ : test_runner_rec);

function encode_utf8(var buf_ : utf8_x4_t; codePoint_ : uint32) : uint8;
function to_utf8(text_ : String) : uint8_array;

implementation

procedure viking_utf_run_tests(runner_ : test_runner_rec);
begin
	//unittest_encode_utf8(runner_);
end;

function encode_utf8(var buf_ : utf8_x4_t; codePoint_ : uint32) : uint8;
var
	cp : uint32;
begin
	cp := codePoint_;
	if (cp <= $7F) then
	begin
		//assert(isValidDchar(c));
		buf_[0] := uint8(cp);
		Result := 1;
	end;
	if (cp <= $7FF) then
	begin
		//assert(isValidDchar(c));
		buf_[0] := uint8($C0 or (cp shr 6));
		buf_[1] := uint8($80 or (cp and $3F));
		Result := 2;
	end;
	if (cp <= $FFFF) then
	begin
		if ($D800 <= cp) and (cp <= $DFFF) then
		begin
			RaiseException(erException,
				'Encoding a surrogate code point in UTF-8: '+ IntToHex(cp,4));
			//cp = _utfException!useReplacementDchar("Encoding a surrogate code point in UTF-8", cp);
		end;

		//assert(isValidDchar(c));
	//L3:
		buf_[0] := uint8($E0 or (cp shr 12));
		buf_[1] := uint8($80 or ((cp shr 6) and $3F));
		buf_[2] := uint8($80 or (cp and $3F));
		Result := 3;
	end;
	if (cp <= $10FFFF) then
	begin
		//assert(isValidDchar(c));
		buf_[0] := uint8($F0 or (cp shr 18));
		buf_[1] := uint8($80 or ((cp shr 12) and $3F));
		buf_[2] := uint8($80 or ((cp shr 6) and $3F));
		buf_[3] := uint8($80 or (cp and $3F));
		Result := 4;
	end;

	//assert(!isValidDchar(c));
	//c = _utfException!useReplacementDchar("Encoding an invalid code point in UTF-8", c);
	//goto L3;
	RaiseException(erException, 'Encoding an invalid code point in UTF-8: '+ IntToHex(cp, 8));
	Result := 0; // Should not be reachable.
end;

const
	utf8_encoder_num_alloc_escalations = 5;
type
	utf8_encoder_allocation_escalations_t =
		Array [0 .. utf8_encoder_num_alloc_escalations] of uint8;
	// We will start with a utf-8 array whose byte-count is %150 of the
	// Char-count of the given 'text_' string. If we run out of space while
	// decoding, we bump it up to the next dose: %200. If decoding still
	// requires more bytes, we jump to %300. Still not enough? %400. No? %500.
	// After that, something crazy is happening, so just double every time.
	// This is a compromise between avoiding spurious reallocations and
	// avoiding gratuitous over-allocation.
	//allocationEscalations = (150, 200, 300, 400, 500); // : Array [0..4] of uint32

function to_utf8(text_ : String) : uint8_array;
var
	output     : uint8_array;
	ipos       : int64;
	opos       : int64;
	codePoint  : uint32;
	buffer     : utf8_x4_t;
	bufferSize : uint32;
	idx        : uint32;
	allocLevel : uint8;
	allocationEscalations : utf8_encoder_allocation_escalations_t;
	allocLevelMax : uint8;
begin
	allocationEscalations[0] := 150;
	allocationEscalations[1] := 200;
	allocationEscalations[2] := 300;
	allocationEscalations[3] := 400;
	allocationEscalations[4] := 500;
	allocLevelMax := utf8_encoder_num_alloc_escalations;

	allocLevel := 0;
	SetLength(output, (length(text_) * allocationEscalations[allocLevel]) div 100);

	opos := 0;
	for ipos := 1 to length(text_) do
	begin
		// TODO: Decode UTF-16 -> UTF-32.
		codePoint := Ord(text_[ipos]);

		// Encode UTF-32 -> UTF-8.
		bufferSize := encode_utf8(buffer, codePoint);

		// Allocate more space when needed.
		if (bufferSize + ipos) > length(output) then
		begin
			if allocLevel < allocLevelMax then
			begin
				allocLevel := allocLevel + 1;
				SetLength(output, (length(text_) * allocationEscalations[allocLevel]) div 100);
			end
			else
				SetLength(output, length(output)*2);
		end;

		// Serialize
		for idx := 0 to bufferSize-1 do
		begin
			output[opos] := buffer[idx];
			opos := opos + 1;
		end;
	end;

	// Trim the output array to its exact length.
	SetLength(output, opos);
	Result := output;
end;


/// unittest for encode_utf8 function
(*
procedure unittest_encode_utf8(runner : test_runner_rec);
begin
{
    import std.exception : assertThrown;
    import std.typecons : Yes;

    char[4] buf;

    assert(encode(buf, '\u0000') == 1 && buf[0 .. 1] == "\u0000");
    assert(encode(buf, '\u007F') == 1 && buf[0 .. 1] == "\u007F");
    assert(encode(buf, '\u0080') == 2 && buf[0 .. 2] == "\u0080");
    assert(encode(buf, '\uE000') == 3 && buf[0 .. 3] == "\uE000");
    assert(encode(buf, 0xFFFE) == 3 && buf[0 .. 3] == "\xEF\xBF\xBE");
    assertThrown!UTFException(encode(buf, cast(dchar) 0x110000));

    encode!(Yes.useReplacementDchar)(buf, cast(dchar) 0x110000);
    auto slice = buf[];
    assert(slice.decodeFront == replacementDchar);
}

///
@safe unittest
{
    import std.exception : assertThrown;
    import std.typecons : Yes;

    wchar[2] buf;

    assert(encode(buf, '\u0000') == 1 && buf[0 .. 1] == "\u0000");
    assert(encode(buf, '\uD7FF') == 1 && buf[0 .. 1] == "\uD7FF");
    assert(encode(buf, '\uE000') == 1 && buf[0 .. 1] == "\uE000");
    assert(encode(buf, '\U00010000') == 2 && buf[0 .. 2] == "\U00010000");
    assert(encode(buf, '\U0010FFFF') == 2 && buf[0 .. 2] == "\U0010FFFF");
    assertThrown!UTFException(encode(buf, cast(dchar) 0xD800));

    encode!(Yes.useReplacementDchar)(buf, cast(dchar) 0x110000);
    auto slice = buf[];
    assert(slice.decodeFront == replacementDchar);
}

///
@safe unittest
{
    import std.exception : assertThrown;
    import std.typecons : Yes;

    dchar[1] buf;

    assert(encode(buf, '\u0000') == 1 && buf[0] == '\u0000');
    assert(encode(buf, '\uD7FF') == 1 && buf[0] == '\uD7FF');
    assert(encode(buf, '\uE000') == 1 && buf[0] == '\uE000');
    assert(encode(buf, '\U0010FFFF') == 1 && buf[0] == '\U0010FFFF');
    assertThrown!UTFException(encode(buf, cast(dchar) 0xD800));

    encode!(Yes.useReplacementDchar)(buf, cast(dchar) 0x110000);
    assert(buf[0] == replacementDchar);
}

@safe unittest
{
    import std.exception;
    assertCTFEable!(
    {
    char[4] buf;

    assert(encode(buf, '\u0000') == 1 && buf[0 .. 1] == "\u0000");
    assert(encode(buf, '\u007F') == 1 && buf[0 .. 1] == "\u007F");
    assert(encode(buf, '\u0080') == 2 && buf[0 .. 2] == "\u0080");
    assert(encode(buf, '\u07FF') == 2 && buf[0 .. 2] == "\u07FF");
    assert(encode(buf, '\u0800') == 3 && buf[0 .. 3] == "\u0800");
    assert(encode(buf, '\uD7FF') == 3 && buf[0 .. 3] == "\uD7FF");
    assert(encode(buf, '\uE000') == 3 && buf[0 .. 3] == "\uE000");
    assert(encode(buf, 0xFFFE) == 3 && buf[0 .. 3] == "\xEF\xBF\xBE");
    assert(encode(buf, 0xFFFF) == 3 && buf[0 .. 3] == "\xEF\xBF\xBF");
    assert(encode(buf, '\U00010000') == 4 && buf[0 .. 4] == "\U00010000");
    assert(encode(buf, '\U0010FFFF') == 4 && buf[0 .. 4] == "\U0010FFFF");

    assertThrown!UTFException(encode(buf, cast(dchar) 0xD800));
    assertThrown!UTFException(encode(buf, cast(dchar) 0xDBFF));
    assertThrown!UTFException(encode(buf, cast(dchar) 0xDC00));
    assertThrown!UTFException(encode(buf, cast(dchar) 0xDFFF));
    assertThrown!UTFException(encode(buf, cast(dchar) 0x110000));

    assert(encode!(Yes.useReplacementDchar)(buf, cast(dchar) 0x110000) == buf.stride);
    assert(buf.front == replacementDchar);
    });
end;
*)

end.