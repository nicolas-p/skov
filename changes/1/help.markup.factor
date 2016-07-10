USING: help.markup.private io namespaces ui.environment.help-graph
ui.gadgets.panes ;
IN: help.markup

: $graph ( element -- )
    check-first <help-graph> nl nl output-stream get write-gadget ;
