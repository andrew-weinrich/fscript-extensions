FSRule onClassMessage:#rule: do:[ :self :pair |
    self ruleWithTest:(pair first) action:(pair second)
].