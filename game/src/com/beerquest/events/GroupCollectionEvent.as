package com.beerquest.events {
import com.beerquest.Group;

public class GroupCollectionEvent extends GameEvent {

    public static const GROUP_COLLECTED:String = "GroupCollected";

    public function GroupCollectionEvent(group:Group) {
        super(GROUP_COLLECTED);
        _group = group;
    }

    public function get group():Group {
        return _group;
    }

    private var _group:Group;

}
}