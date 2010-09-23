package com.beerquest.events {
import com.beerquest.BoardState;

public class PissLevelEvent extends GameEvent {
    public static const PISS_LEVEL_CHANGED:String = "PissLevelChanged";

    public function PissLevelEvent(pissRaise:Boolean, board:BoardState = null) {
        super(PISS_LEVEL_CHANGED, board);
        _pissRaise = pissRaise;
    }

    public function get pissRaise():Boolean {
        return _pissRaise;
    }

    private var _pissRaise:Boolean;
}
}