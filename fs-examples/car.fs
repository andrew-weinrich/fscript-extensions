"Create an instance of a blank, anonymous class"
myInstance := FSClass newClass new init.

"This line would throw an exception because foo: is not defined for this class"
"myInstance foo:5."

"Retrieve the class and add another method to it"
(myInstance fsClass) onMessage:#foo: do:[ :self :fooValue |
    sys log:'Foo value: ' ++ (fooValue description).
].

"This line will now run without any problems"
"Prints 'Foo value: 5'"
myInstance foo:5.