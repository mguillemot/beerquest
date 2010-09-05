package com.beerquest.events {
import com.beerquest.BoardState;
import com.beerquest.Group;

public class GroupCollectionEvent extends GameEvent {

    public static const GROUPS_COLLECTED:String = "GroupsCollected";

    public function GroupCollectionEvent(groups:Array, board:BoardState) {
        super(GROUPS_COLLECTED);
        _groups = groups;
        _board = board;
    }

    public function get groups():Array {
        return _groups;
    }

    public function get board():BoardState {
        return _board;
    }

    private var _groups:Array;
    private var _board:BoardState;

}
}