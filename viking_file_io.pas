unit viking_file_io;

interface
uses
	viking_types,
	viking_testing,
	viking_utf;

function mk_file_stream_open_for_appending(path_: String) : TFileStream;

function write_utf8(writer_ : TFileStream; text_ : String) : size_t;
function write_utf8_line(writer_ : TFileStream;  line_ : String) : size_t;

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

function write_utf8_buffer_(writer_ : TFileStream; bytes_ : uint8_array) : size_t;
var
	// NOTE: In RemObjects PascalScript, TStream only accepts AnsiString
	// as its argument and can't handle byte arrays. So we need to move all
	// of the bytes out of the uint8_array and into the AnsiString buffer
	// before writing the buffer out to disk. We try to do this in chunks that
	// avoid spurious disk I/O, though this will still be a little inefficient
	// due to the additional buffer-copy/transfer needed to place things into
	// the AnsiString.
	buffer       : AnsiString; // Note: 1-based indexing.
	//bidx         : index_t;

	len          : size_t;
	idx          : index_t;
	bytesWritten : size_t;
	//blockSize    : size_t;
begin
	//blockSize := 4096;
	//SetLength(buffer,blockSize);
	SetLength(buffer,1);

	idx := 0;
	len := length(bytes_);
	while idx < len do
	begin
		buffer[1] := chr(bytes_[idx]);
		bytesWritten := writer_.Write(buffer[1], 1);
		if bytesWritten = 0 then
			break;
		idx := idx + 1;
		(*bidx := 0;
		while (bidx <= blockSize) and (idx < len) do
		begin
			buffer[bidx+1] := chr(bytes_[idx]);
			bidx := bidx + 1;
			idx  := idx  + 1;
		end;

		bytesWritten := writer_.Write(buffer[1], bidx);
		if bytesWritten < bidx then
		begin
			idx := (idx - bidx) + bytesWritten;
			break;
		end;
		*)
	end;
	Result := idx;
end;

function write_utf8(writer_ : TFileStream; text_ : String) : size_t;
var
	utf8Str      : uint8_array;
	bytesWritten : size_t;
begin
	if length(text_) = 0 then
	begin
		Result := 0;
		Exit;
	end;

	utf8Str := to_utf8(text_);
	try
		bytesWritten := write_utf8_buffer_(writer_, utf8Str)
	finally
		SetLength(utf8Str, 0)
	end;
	Result := bytesWritten;
end;

function write_utf8_line(writer_ : TFileStream; line_ : String) : size_t;
var
	utf8Str      : uint8_array;
	theEnd       : index_t; // Totally not ominous at all.
	bytesWritten : size_t;
begin
	if length(line_) = 0 then
	begin
		SetLength(utf8Str, 2);
		Exit;
	end
	else
	begin
		utf8Str := to_utf8(line_);
		theEnd  := length(utf8Str)+2;
		SetLength(utf8Str, theEnd);
	end;

	utf8Str[theEnd-2] := 13;
	utf8Str[theEnd-1] := 10;

	try
		bytesWritten := write_utf8_buffer_(writer_, utf8Str);
	finally
		SetLength(utf8Str,0);
	end;
	Result := bytesWritten;
end;

end.