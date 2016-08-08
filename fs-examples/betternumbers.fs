dataFile := FSFile open:'lotsanumbers.txt'.

[dataFile readln] foreach:[ :line |
    data := (line componentsSeparatedByString:'\t') doubleValue.
    out print:(data \#+ / data count).
    out print:', '.
].

out newln.

