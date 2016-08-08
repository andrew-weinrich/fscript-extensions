
sys import:'printf_common'.


"Decimal integer tests"
int_formats := {
    '%-1.5d',   '%1.5d',    '%31.9d',   '%5.5d',    '%10.5d',   '% 10.5d',
    '%+22.30i', '%01.3i',   '%4i',      '%i',
    '%+22.30d', '%01.3d',   '%4d',      '%d'
}.
int_nums := { 3557670, 747874, 2902903, 748, 828, 99, -1, 134, 91340, 341, 0203, 0, -3890021, -784 }.
intTests := generateTestSuite value:int_formats value:int_nums.


runTestSuite value:intTests.





