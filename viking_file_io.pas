unit viking_file_io;

interface
uses
	viking_types,
	viking_testing,
	viking_utf;

function mk_file_stream_open_for_appending(path_: String) : TFileStream;

function write_utf8(writer_ : TFileStream; text_ : String) : Int64;
function write_utf8_line(writer_ : TFileStream;  line_ : String) : Int64;

implementation

function mk_file_stream_open_for_appending(path_: String) : TFileStream;
var
	fd   : TFileStream;
	mode : Word;
begin
	if FileExists(path_) then
		mode := fmOpenReadWrite
	else
		mode := fmCreate;

	fd := TFileStream.Create(path_,mode);
	if mode = fmOpenReadWrite then
		fd.Seek(0,soFromEnd);

	Result := fd;
end;

function write_utf8_buffer_(writer_ : TFileStream; bytes_ : uint8_array) : int64;
var
	// NOTE: In RemObjects PascalScript, TStream only accepts AnsiString
	// as its argument and can't handle byte arrays. So we need to move all
	// of the bytes out of the uint8_array and into the AnsiString buffer
	// before writing the buffer out to disk. We try to do this in chunks that
	// avoid spurious disk I/O, though this will still be a little inefficient
	// due to the additional buffer-copy/transfer needed to place things into
	// the AnsiString.
	buffer    : AnsiString;
	bidx      : int64;

	len       : int64;
	idx       : int64;
	res       : LongInt;
	blockSize : int64;
begin
	blockSize := 4096;
	SetLength(buffer,blockSize);

	len := length(bytes_);
	while idx < len do
	begin
		while (bidx < blockSize) and (idx < len) do
		begin
			buffer[bidx] := chr(bytes_[idx]);
			bidx := bidx + 1;
			idx  := idx  + 1;
		end;

		res := writer_.Write(buffer, bidx);
		if res <= 0 then
		begin
			idx := (idx - bidx) + res;
			break;
		end;
	end;
	Result := idx;
end;

function write_utf8(writer_ : TFileStream; text_ : String) : int64;
var
	utf8Str : uint8_array;
begin
	if length(text_) = 0 then
	begin
		Result := 0;
		Exit;
	end;

	utf8Str := to_utf8(text_);
	Result := write_utf8_buffer_(writer_, utf8Str);
end;

function write_utf8_line(writer_ : TFileStream; line_ : String) : int64;
var
	utf8Str : uint8_array;
	theEnd  : int64; // Totally not ominous at all.
begin
	if length(line_) = 0 then
	begin
		Result := 0;
		Exit;
	end;

	utf8Str := to_utf8(line_);
	theEnd  := length(utf8Str)+2;
	SetLength(utf8Str, theEnd);
	utf8Str[theEnd-2] := 13;
	utf8Str[theEnd-1] := 10;

	Result := write_utf8_buffer_(writer_, utf8Str);
end;

end.