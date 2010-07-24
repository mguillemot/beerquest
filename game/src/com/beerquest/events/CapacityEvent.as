package com.beerquest.events {
import com.beerquest.Capacity;
import com.beerquest.PlayerData;

public class CapacityEvent extends GameEvent {

    public static const CAPACITY_GAINED:String = "CapacityGained";
    public static const CAPACITY_EXECUTED:String = "CapacityExecuted";

    public function CapacityEvent(event:String, player:PlayerData, capacity:Capacity) {
        super(event, player);
        _capacity = capacity;
    }

    public function get capacity():Capacity {
        return _capacity;
    }

    private var _capacity:Capacity;
}
}