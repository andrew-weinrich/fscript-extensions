"Reads a simple 'Key = Value' file and returns the contents as a dictionary"
ConfigFile := [ :filename | |file data newClass|
    file := FSFile open:filename mode:'<'.
	
	"converts an array of strings into an array of arrays of strings"
    data := (file readlines) split:' *= *'.
    file closeFile.
    
    "Create a new, anonymous class"
    newClass := FSClass newClass.
    
    "For each config line in the file, add a new method to
    the class that returns the corresponding value"
    "We could use addProperty: for this, but we want them to
    be read-only"
    [ :fileLine |
        newClass onMessage:(fileLine at:0) do:[
            fileLine at:1
        ].
    ]
	"apply the function to each element in the array"
    value: @ data.
    
    "return an instance of the anon class"
    newClass alloc init
].

nil