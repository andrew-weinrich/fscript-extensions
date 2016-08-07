



"
myString := 'A string: %s.' sprintf:{'exceedinglny exceedinglny exceedinglny exceedinglny exceedinglny exceedinglny exceedinglny exceedinglny exceedinglny long string', 2}.

out println:myString.


myString2 := 'asdf aseas asdf asf asf asf asdf aseas asdf asf asf asf %s asdf aseas asdf asf asf asf'
    sprintf:{'middle'}.

out println:myString2.

"

out printf:'Padded string 1:(%10s)\n' withValues:{'aaa'}.
out printf:'Padded string 2:(%-10s)\n' withValues:{'aaa'}.
out printf:'Max-precision string (5 chars): (%.5s)\n' withValues:{'abcdefg'}.


out print:('A %%substring: (%-3.4s)\n' sprintf:{'ûstring'}).

out printf:'A %%substring: (%-3.4s)\n' withValues:{'ûstring'}.
out println:'.'.

out printf:'Description test 1: (%@)\n' withValues:{'plain string'}.
out printf:'Description test 2: (%@)\n' withValues:{2}.
out printf:'Description test 2: (%@)\n' withValues:{ 4.5369 }.
out printf:'Description test 3: (%@)\n' withValues:{ {'plain string', 3, NSString } }.
out newln.




out newln.
"
out printf:'A number: %+d;\n' withValues:{ 4 }.
out printf:'A specified-precision number: %+.5d;\n' withValues:{ 22 }.
out printf:'A min-width number, pad 0: (%+05d);\n' withValues:{ 8 }.
out printf:'A min-width number, pad 0: (%05d);\n' withValues:{ 8 }.
out printf:'A min-width number, pad _: (%+5d);\n' withValues:{ 8 }.
out printf:'A min-width number, pad _: (%5d);\n' withValues:{ 8 }.
out printf:'A min-width number, pad right 0: (%-5d);\n' withValues:{ 11 }.
out printf:'A min-width number, pad right _: (%-5d);\n' withValues:{ 11 }.
out printf:'A neg min-width number, pad right 0: (%-5d);\n' withValues:{ -11 }.
out printf:'A neg min-width number, pad right _: (%-5d);\n' withValues:{ -11 }.
out printf:'A pos min-width number, pad right 0: (%+5d);\n' withValues:{ 11 }.
"


out printf:'A pos min-width number, pad right _, leading +: (%-+5d);\n' withValues:{ 11 }.
out printf:'A pos min-width number, pad right _, leading _: (% 05d);\n' withValues:{ 11 }.

out newln.
out printf:'Hex, pad 0 left, sign on, no prefix: (%+010x);\n' withValues:{ 11 }.
out printf:'Hex, pad 0 left, sign on,    prefix: (%+#010x);\n' withValues:{ 11 }.

out newln.
out printf:'Hex, pad 0 left, sign on,    prefix: (%+#010x);\n' withValues:{ 0 }.

out newln.
out printf:'Octal,negative: (%o);\n' withValues:{ -23 }.
out printf:'Octal,negative, width        : (%5o);\n' withValues:{ -23 }.
out printf:'Octal,negative, width, pad 0 : (%05o);\n' withValues:{ -23 }.
out printf:'Octal,negative, width, prefix: (%#5o);\n' withValues:{ -23 }.
out newln.


out printf:'Octal,    prefix: (%#.4o);\n' withValues:{ 23 }.
out printf:'Octal,    prefix: (%#.4o);\n' withValues:{ 700 }.
out printf:'Octal, no prefix: (%.5o);\n' withValues:{ 700 }.
out printf:'Octal, width, prefix: (%#5.5x);\n' withValues:{ 0 }.

out newln.
out printf:'Dynamic width test (5): (%*d);\n' withValues:{ 5, 10 }.


out newln.
out newln.
out printf:'Float test:                      (%f)\n' withValues:{ 5.5 }.
out printf:'Float test, specified precision: (%.8f)\n' withValues:{ 5.5 }.
out printf:'Float test, specified precision: (%- 010.4f)\n' withValues:{ 5.5 }.



out newln.
out newln.
out printf:'Exp test:                      (%e)\n' withValues:{ 5.5 }.
out printf:'Exp test, specified precision: (%.8e)\n' withValues:{ 5.5 }.
out printf:'Exp test, specified precision: (%- 010.4e)\n' withValues:{ 5.5 }.
out printf:'Exp test, specified precision: (%- 010.4g)\n' withValues:{ 5.5 }.



out newln.
out printf:'%s, %s %d, %.2d:%.2d\n' withValues:{ 'Sunday', 'July', 3, 10, 2 }.
out printf:'pi = %.5f\n' withValues:{ 1.0 arcTan * 4 }.
"
out printf:'Hex number: %x;\n' withValues:{ 12 }.
out printf:'Hex number: %X;\n' withValues:{ 25 }.
out printf:'Hex number: %#x;\n' withValues:{ 1385138138 }.
out printf:'Dec number: %#d;\n' withValues:{ 1385138138 }.
out printf:'Limited-precision dec number: %0.5d;\n' withValues:{ 1385138138 }.
"