! Copyright (C) 2015 Nicolas Pénet.
USING: skov.gadgets.environment-gadget ui.gadgets.status-bar ui ;
IN: skov

: skov-window ( -- )
    [ <environment-gadget> "Skov" open-status-window ] with-ui ;

MAIN: skov-window
