sys import:'printf_common'.




"Floating point tests"
fp_formats := {
    '%-1.5f',   '%1.5f',    '%31.9f',   '%10.5f',   '% 10.5f',  '%+22.9f',
    '%+4.9f',   '%01.3f',   '%3.1f',    '%3.2f',    '%.0f',     '%.1f', '%.2f',
    '%f'
}.
fp_nums := {
    -1.5, 134.21, 91340.2, 341.1234, 0203.9, 0.96, 0.996, 0.9996, 1.996,
    4.136, 0, -234269714.56, -450539008.79
}.
floatTests := generateTestSuite value:fp_formats value:fp_nums.


runTestSuite value:floatTests.

