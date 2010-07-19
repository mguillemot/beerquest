package com.beerquest.events {
import com.beerquest.PlayerData;

public class VomitEvent extends GameEvent {
    public static const VOMIT:String = "Vomit";

    public function VomitEvent(player:PlayerData) {
        super(VOMIT, player);
    }
}
}