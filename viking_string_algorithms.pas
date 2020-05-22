unit viking_string_algorithms;

interface
uses
	viking_types;

function char_escape_nonprintable(ch_ : Char) : String;
function is_whitespace(ch_ : Char) : Boolean;
function skip_whitespace(text_ : String; pos_ : Integer; tlen_ : index_t ) : Integer;
function tokenize_hex(text_ :String;  pos_ :index_t;  tlen_ :index_t ) : String;

implementation

function char_escape_nonprintable(ch_ : Char) : String;
var
	codePoint : uint32;
begin
	codePoint := Ord(ch_);
	if (codePoint < 32) then // non-printable character.
		Result := '\x'+IntToHex(codePoint,2)
	else
		Result := ch_;
end;

function is_whitespace(ch_ : Char) : Boolean;
begin
	Result := ((ch_ = ' ') OR (ch_ = chr(9)) OR (ch_ = chr(10)) OR (ch_ = chr(13)));
end;

function skip_whitespace(text_ : String; pos_ : Integer; tlen_ : index_t ) : Integer;
var
	pos : Integer;
begin
	pos := pos_;
	while pos <= tlen_ do
	begin
		if not is_whitespace(text_[pos]) then
			break;

		pos := pos + 1;
	end;
	Result := pos;
end;

function tokenize_hex(text_ :String;  pos_ :index_t;  tlen_ :index_t ) : String;
var
	pos    : index_t;
	hexStr : String;
	ch     : Char;
begin
	pos := pos_;

	// Skip the Pascal-style $ hex prefix, if present.
	if (pos <= tlen_) AND (text_[pos] = '$') then
		pos := pos + 1
	else
	// Skip the C-style 0x hex prefix, if present.
	if  (pos+0 <= tlen_) AND (text_[pos+0] = '0')
	AND (pos+1 <= tlen_) AND (text_[pos+1] = 'x') then
		pos := pos + 2;

	while (pos <= tlen_) do
	begin
		ch := text_[pos];

		if (('0' <= ch) AND (ch <= '9'))
		OR (('A' <= ch) AND (ch <= 'F'))
		OR (('a' <= ch) AND (ch <= 'f'))
		then
		begin
			hexStr := hexStr + ch;
			pos := pos + 1;
			continue;
		end;

		if is_whitespace(ch) OR (ch = ',') OR (Ord(ch) = 0) then
			break;

		RaiseException(erException, 'Error: Invalid character "'+char_escape_nonprintable(ch)+'"'
			+' at position '+IntToStr(pos)+' in text "'+text_+'".');
	end;
	Result := hexStr;
end;
 
end.