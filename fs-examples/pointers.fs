"Shows how to indirectly set variables"

thing := 5.

pointer := FSPointer objectPointer.

pointer at:0 put:thing.

"prints '5'"
out println:(pointer at:0).

pointer at:0 put:6.

"prints '6'"
out println:thing.

out println:(pointer at:0).