sys import:'printf_common'.


"String tests"
longString := 'abcdefghijklmnopqrstuvwxyz0123456789'.
noValue := 12398.
anohitoString := 12354 unicharToString ++ noValue unicharToString ++ 20154 unicharToString.
stringTests := {
	PrintfTest test:'%c' values:{71} result:'G',
	PrintfTest test:'%s' values:{'abcd'} result:'abcd',
	PrintfTest test:'%d' values:{20} result:'20',
	PrintfTest test:'%s' values:{longString} result:longString,
	PrintfTest test:'%.10s' values:{longString} result:'abcdefghij',
	PrintfTest test:'%12.10s' values:{longString} result:'  abcdefghij',
	PrintfTest test:'%-14.10s' values:{longString} result:'abcdefghij    ',
	PrintfTest test:'%50s' values:{longString} result:'              abcdefghijklmnopqrstuvwxyz0123456789',
	PrintfTest test:'%%%0s%%' values:{'abcd'} result:'%abcd%',
	PrintfTest test:'%.26s  %d' values:{longString, 4444} result:'abcdefghijklmnopqrstuvwxyz  4444',
	PrintfTest test:'%.26s  %.1f' values:{longString, -2.5} result:'abcdefghijklmnopqrstuvwxyz  -2.5',
	PrintfTest test:'%.10s %d' values:{longString,4444} result:'abcdefghij 4444',

	"test handling of multi-byte Unicode characters"
	PrintfTest test:'%c' values:{noValue} result:(12398 unicharToString),
	PrintfTest test:'%5s' values:{anohitoString} result:('  ' ++ anohitoString),
	PrintfTest test:'%5.2s' values:{anohitoString} result:('   ' ++ 12354 unicharToString ++ noValue unicharToString)
}.





runTestSuite value:stringTests.
