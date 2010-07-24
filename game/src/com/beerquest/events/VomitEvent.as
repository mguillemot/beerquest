package com.beerquest.events {
import com.beerquest.PlayerData;

public class VomitEvent extends GameEvent {
    public static const VOMIT:String = "Vomit";

    public function VomitEvent(player:PlayerData, cells:Array) {
        super(VOMIT, player);
        _cells = cells;
    }

    public function get cells():Array {
        return _cells;
    }

    private var _cells:Array;
}
}