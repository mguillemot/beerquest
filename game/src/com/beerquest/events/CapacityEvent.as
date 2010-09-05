package com.beerquest.events {
import com.beerquest.Capacity;

public class CapacityEvent extends GameEvent {

    public static const CAPACITY_GAINED:String = "CapacityGained";
    public static const CAPACITY_EXECUTED:String = "CapacityExecuted";

    public function CapacityEvent(event:String, capacity:Capacity) {
        super(event);
        _capacity = capacity;
    }

    public function get capacity():Capacity {
        return _capacity;
    }

    private var _capacity:Capacity;
}
}