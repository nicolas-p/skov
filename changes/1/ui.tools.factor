USING: namespaces ui.backend ui.tools.environment ;
IN: ui.tools

: ui-tools-main ( -- )
    f ui-stop-after-last-window? set-global
    environment-window ;
