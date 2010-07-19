package com.beerquest.events {
import com.beerquest.PlayerData;

public class CapacityGainedEvent extends GameEvent {
    public static const CAPACITY_GAINED:String = "CapacityGained";

    public function CapacityGainedEvent(player:PlayerData) {
        super(CAPACITY_GAINED, player);
    }
}
}