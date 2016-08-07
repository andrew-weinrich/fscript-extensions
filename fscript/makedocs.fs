#!/bin/fscript

"
This file compiles headerdoc for all the headers in the project, then comiles
the top-level headerdoc
The script caches file modifications times in the header_mod_times file to 
avoid unnecessary reprocessing
"
modFileName := 'header_mod_times'.
outputDir   := 'Documentation'.
configLoc   := '~/Library/Preferences/com.apple.headerdoc2HTML.config' stringByExpandingTildeInPath.

"list of header names"
headers := { 'ArrayUtil', 'SystemUtility', 'FSNSNumberMod', 'FSFile', 'StringSprintf', 'StringRegex',
             'FSNSMutableDictionary', 'BlockForeach'
           } @ ++ '.h'.

"subroutine to run headerdoc on a file"
runh2h := [ :headerFile |
    sys execNoOutput:'headerdoc2HTML' args:{'-H', '-o', outputDir++'/', headerFile}.
].

"if the mod times file exists and we were not told to run clean, use it"
"otherwise, use a blank file"
clean := (args count > 0) ifTrue:[ (args at:0) = 'clean'] ifFalse:[ false ].

oldModTimes := ((filem test_f:modFileName) & (clean not)) ifTrue:[
    NSDictionary dictionaryWithContentsOfFile:modFileName.
]
ifFalse:[
    NSDictionary dictionaryWithObjects:(NSDate distantPast enlist:(headers count)) forKeys:headers.
].
newModTimes := NSMutableDictionary dictionaryWithCapacity:0.

"move existing config file out of the way and replace with a link to our file"
tempConfigLoc := configLoc++'.temp'.
(filem fileExistsAtPath:configLoc) ifTrue:[
    filem movePath:configLoc toPath:tempConfigLoc handler:nil.
].
filem createSymbolicLinkAtPath:configLoc pathContent:'Documentation/headerconfig'.

"For each header file, check to see if it has been changed since the last time we ran this
script; if so, regenerate documentation files"
updateModTimes := NO.
[ :header |  |fileModTime|
    fileModTime := filem test_m:header.
    ((oldModTimes objectForKey:header) < fileModTime) ifTrue:[
        out println:('headerdoc2html -H -o ' ++ outputDir ++ '/ ' ++ header).
        runh2h value:header.
        updateModTimes := YES.
    ].
    newModTimes setObject:fileModTime forKey:header.
]
value: @ headers.

"Save new modification times"
updateModTimes ifTrue:[
    newModTimes writeToFile:modFileName atomically:YES.
].

"generate program header"
runh2h value:'fscript.hdoc'.

"create document structure"
sys execNoOutput:'gatherheaderdoc' args:{outputDir}.

"move existing config file back"
(filem test_f:tempConfigLoc) ifTrue:[
    filem movePath:tempConfigLoc toPath:configLoc handler:nil.
].