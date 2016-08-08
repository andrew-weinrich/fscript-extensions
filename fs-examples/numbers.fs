"Read a file with multiple numbers per line, then print each line's sum"
dataFile := FSFile open:'lotsanumbers.txt'.

data := (dataFile readlines componentsSeparatedByString:'\t') doubleValue.

out println:((data @ \#+ ) / (data @ count)).

columns := (data @2 at: @ (((data objectAtIndex:0) count) iota)) .

out println:((columns @ \#+ ) / (columns @ count)).