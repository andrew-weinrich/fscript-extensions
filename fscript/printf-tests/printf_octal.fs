
sys import:'printf_common'.


"Octal tests"
octal_formats := {
    '%-1.5o',   '%1.5o',    '%31.9o',   '%5.5o',    '%10.5o',
    '%+22.30o', '%01.3o',   '%4o',      '%o'
}.
hex_nums := { 3557670, 747874, 2902903, 748, 828, 99 }.
octalTests := generateTestSuite value:octal_formats value:hex_nums.


runTestSuite value:octalTests.





