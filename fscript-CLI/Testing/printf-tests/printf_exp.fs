sys import:'printf_common'.




"Scientific notation tests"
exp_formats := {
    '%-1.5e',   '%1.5e',    '%31.9e',   '%10.5e',   '% 10.5e',  '%+22.9e',
    '%+4.9e',   '%01.3e',   '%3.1e',    '%3.2e',    '%.0e',     '%.1e', '%.2e', '%.1E', '%.2E',
    '%e'
}.
fp_nums := {
    -1.5, 134.21, 91340.2, 341.1234, 0203.9, 0.96, 0.996, 0.9996, 1.996,
    4.136, 0, -234269714.56, -450539008.79
}.
expTests := generateTestSuite value:exp_formats value:fp_nums.



runTestSuite value:expTests.

