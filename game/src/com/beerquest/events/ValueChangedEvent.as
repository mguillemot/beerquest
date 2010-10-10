/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 10 oct. 2010
 * Time: 16:17:56
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest.events {
import com.beerquest.BoardState;

public class ValueChangedEvent extends GameEvent {

    public static const VOMIT_CHANGED:String = "VomitChanged";
    public static const PISS_CHANGED:String = "PissChanged";
    public static const REMAINING_TURNS_CHANGED:String = "RemainingTurnsChanged";
    public static const SCORE_CHANGED:String = "ScoreChanged";

    public function ValueChangedEvent(event:String, oldValue:Number, newValue:Number, board:BoardState = null) {
        super(event, board);
        _oldValue = oldValue;
        _newValue = newValue;
    }

    public function get oldValue():Number {
        return _oldValue;
    }

    public function get newValue():Number {
        return _newValue;
    }

    private var _oldValue:Number;
    private var _newValue:Number;
}
}