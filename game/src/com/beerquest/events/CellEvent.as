package com.beerquest.events {
import com.beerquest.TokenType;

public class CellEvent extends BoardEvent {
    public static const CELL_DESTROYED:String = "CellDestroyed";
    public static const CELL_TRANSFORMED:String = "CellTransformed";

    public function CellEvent(event:String, x:int, y:int, replacementToken:TokenType) {
        super(event, x, y);
        _replacemenToken = replacementToken;
    }

    private var _replacemenToken:TokenType;
}
}