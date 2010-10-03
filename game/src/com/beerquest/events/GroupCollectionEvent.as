package com.beerquest.events {
import com.beerquest.BoardState;

public class GroupCollectionEvent extends GameEvent {

    public static const GROUPS_COLLECTED:String = "GroupsCollected";

    public function GroupCollectionEvent(groups:Array) {
        super(GROUPS_COLLECTED, board);
        _groups = groups;
    }

    public function get groups():Array {
        return _groups;
    }

    private var _groups:Array;

}
}