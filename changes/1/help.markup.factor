USING: help.markup.private io namespaces sequences
ui.tools.environment.graph.help-graph ui.gadgets.panes ;
IN: help.markup

: $graph ( element -- )
    check-first <help-graph> nl nl output-stream get write-gadget ;

: $inputs ( element -- )
    "Inputs" $heading
    [ [ "none" print ] ($block) ]
    [ [ values-row ] map $table ] if-empty ;

: $outputs ( element -- )
    "Outputs" $heading
    [ [ "none" print ] ($block) ]
    [ [ values-row ] map $table ] if-empty ;
