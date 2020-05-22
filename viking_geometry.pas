unit viking_geometry;

interface
uses
	viking_types;

type
	vector2int32_rec = record
		x : int32; // + = east,  - = west
		y : int32; // + = south, - = north
	end;

function mk_vec2i32(x_ : int32; y_ : int32) : vector2int32_rec;
function vec2i32_add(a_ : vector2int32_rec;  b_ : vector2int32_rec) : vector2int32_rec;
function vec2i32_to_string(vec_ : vector2int32_rec) : String;

function distance_chebyshev_i32(x1, y1, x2, y2 : int32) : int32;
function distance_chebyshev_v2i32(v1, v2 : vector2int32_rec) : int32;

implementation

function mk_vec2i32(x_ :int32;  y_ :int32) : vector2int32_rec;
var
	vec2d : vector2int32_rec;
begin
	vec2d.x := x_;
	vec2d.y := y_;
	Result := vec2d;
end;

function vec2i32_add(a_ :vector2int32_rec; b_ :vector2int32_rec) : vector2int32_rec;
var
	x, y : int32;
begin
	x := a_.x + b_.x;
	y := a_.y + b_.y;
	Result := mk_vec2i32(x,y);
end;

function vec2i32_to_string(vec_ : vector2int32_rec) : String;
begin
	Result := '(' + IntToStr(vec_.x) + ',' + IntToStr(vec_.y) + ')';
end;

// TODO: This should end up in a math module or something. Just don't make
// TODO:  it public in this module.
// Abs function that doesn't return a berping floating point number.
function abs_i32(n : int32) : int32;
begin
	if n < 0 then
    	Result := -n
    else
    	Result := n;
end;


function distance_chebyshev_i32(x1, y1, x2, y2 : int32) : int32;
var
	adx, ady : int32;
begin
	adx := abs_i32(x2-x1);
	ady := abs_i32(y2-y1);
	if adx > ady then
		Result := adx
	else
		Result := ady
end;

function distance_chebyshev_v2i32(v1, v2 : vector2int32_rec) : int32;
begin
	Result := distance_chebyshev_i32(v1.x, v1.y, v2.x, v2.y);
end;

end.