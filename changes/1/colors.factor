USING: arrays assocs kernel math sequences ;
IN: colors

: avg-color ( rgba rgba -- rgba )
    [ >rgba-components 4array ] bi@ zip [ first2 + 2 / ] map first4 <rgba> ;
