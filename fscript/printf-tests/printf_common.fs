"Simple class that hold a format, values, and expected output"
PrintfTest := FSClass newClass:'PrintfTest'.
PrintfTest addProperty: @ { 'format', 'values', 'result' }.
PrintfTest onClassMessage:#test:values:result: do:[ :self :test :values :result | |newTest|
	newTest := self alloc init.
	newTest setFormat:test; setValues:values; setResult:result.
	newTest
].



"Creates a 'cartesian product' test suite of values and formats, checked against
the the output of Perl's printf"
generateTestSuite := [ :formats :values |
	([ :format |
		[ :value | |perlString output|
			perlString := 'printf(\'' ++ format ++ '\', ' ++ value description ++ ')'.
			output := sys exec:'/usr/bin/perl' args:{'-e', perlString}.
			PrintfTest test:format values:{value} result:output.
		] value: @ values
	] value: @ formats) \#++
].


"Runs an array of PrintfTest tests, showing errors and reporting a final pass/fail count"
runTestSuite := [ :tests | |i passedCount failedCount|
	passedCount := 0.
	failedCount := 0.
	i := 0.
	[ :test | |result|
		i := i + 1.
		result := test format sprintf:(test values).
		(result = test result) ifTrue:[
			passedCount := passedCount + 1.
		]
		ifFalse:[
			out printf:'Failed test %d (%s): expecting "%s", got "%s"\n'
				withValues:{i, test format, test result, result}.
			failedCount := failedCount + 1.
		].
	] value: @ tests.
	
	out println:'Passed: ' ++ passedCount description.
	out println:'Failed: ' ++ failedCount description.
].
