scores := {-3,-4,-3,2,-4,2,4,-3,2,3,3,-3,4,-4,-3,4,-4,3,2,-4}.

inverses := {1,-1,1,-1,1,-1,-1,1,-1,1,-1,1,-1,1,1,-1,1,-1,-1,1}.

adjustedScores := scores * inverses + 5 \ #+.

out println:(scores * inverses).
out println:adjustedScores.
out println:(adjustedScores \ #+).