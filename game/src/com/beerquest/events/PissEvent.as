package com.beerquest.events {
import com.beerquest.PlayerData;

public class PissEvent extends GameEvent {
    public static const PISS:String = "Piss";

    public function PissEvent(player:PlayerData) {
        super(PISS, player);
    }
}
}