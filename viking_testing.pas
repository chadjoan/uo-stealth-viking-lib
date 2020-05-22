unit viking_testing;

interface
uses
	viking_types;

type
	unittest_failure_rec = record
		lineNumber  : uint32;
 
		// Test results. Tests can accept a variety of types, but to keep things
		// simple, we stringize them before storing them in these reporting
		// records. As long as we don't need to work with the data directly,
		// this is sufficient and avoids generic programming.
		actual   : AnsiString;
		expected : AnsiString;
		dataType : AnsiString; // Ex: 'int16', 'String', 'uint8_array', etc.
	end;
	
	unittest_failure_array = Array of unittest_failure_rec;

	unittest_results_rec = record
		moduleName : String; // TODO: don't know how to populate this. Delphi macros? Exception stack trace?
		filePath   : String; // ditto
		testName   : String;
		passCount  : uint32;
		failCount  : uint32;
		totalCount : uint32; // Note that (pass+fail <= totalCount) because fatal failures.
		failures   : unittest_failure_array;
	end;

	unittest_results_array = Array of unittest_results_rec;

	test_runner_rec = record
		allResults : unittest_results_array;
	end;

	function new_test_runner() : test_runner_rec;

(*	procedure assert_eq_int(actual, expected : int64);

	procedure assert_eq_int8a(actual,  expected : int8_array);
	procedure assert_eq_int16a(actual, expected : int16_array);
	procedure assert_eq_int32a(actual, expected : int32_array);
	procedure assert_eq_int64a(actual, expected : int64_array);

	procedure assert_eq_uint8a(actual,  expected : uint8_array);
	procedure assert_eq_uint16a(actual, expected : uint16_array);
	procedure assert_eq_uint32a(actual, expected : uint32_array);
	procedure assert_eq_uint64a(actual, expected : uint64_array);

	procedure assert_eq_str(actual, expected : String);
	procedure assert_eq_stra(actual, expected : string_array;
*)

implementation

	function new_test_runner() : test_runner_rec;
	var
		runner : test_runner_rec;
	begin
		// TODO: implement it at all.
		Result := runner;
	end;

end.
