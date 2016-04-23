USING: accessors combinators kernel ui.gadgets.sliders.private
ui.gadgets.tracks ;
IN: ui.gadgets.sliders

: <slider> ( range orientation -- slider )
    slider new-track
        swap >>model
        16 >>line
        dup orientation>> {
            [ <thumb> >>thumb ]
            [ <elevator> >>elevator ]
            [ drop dup add-thumb-to-elevator 1 track-add ]
        } cleave ;
