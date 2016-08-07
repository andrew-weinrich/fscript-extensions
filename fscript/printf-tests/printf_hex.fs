
sys import:'printf_common'.


"Hexadecimal tests"
hex_formats := {
    '%-1.5x',   '%1.5x',    '%31.9x',   '%5.5X',    '%10.5X',   '% 10.5x',
    '%+22.30x', '%01.3x',   '%4x',      '%x'
}.
hex_nums := { 3557670, 747874, 2902903, 748, 828, 99 }.
hexTests := generateTestSuite value:hex_formats value:hex_nums.


runTestSuite value:hexTests.





