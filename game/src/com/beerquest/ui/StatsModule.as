/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 1 sept. 2010
 * Time: 01:00:04
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest.ui {
import com.beerquest.Constants;
import com.beerquest.GameStats;
import com.beerquest.Group;
import com.beerquest.events.BoardEvent;
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GemsSwappedEvent;
import com.beerquest.events.GroupCollectionEvent;
import com.beerquest.events.PissLevelEvent;
import com.beerquest.events.ValueChangedEvent;

import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.system.Capabilities;

import mx.core.UIComponent;

public class StatsModule extends UIComponent {

    public function StatsModule() {
        Constants.GAME.addEventListener(GameEvent.PISS, onPiss);
        Constants.GAME.addEventListener(GameEvent.VOMIT, onVomit);
        Constants.GAME.addEventListener(GameEvent.GAME_OVER, onGameOver);
        Constants.GAME.addEventListener(ValueChangedEvent.REMAINING_TURNS_CHANGED, onTurnChange);
        Constants.GAME.addEventListener(GemsSwappedEvent.GEMS_SWAPPED, onGemsSwapped);
        Constants.GAME.addEventListener(PissLevelEvent.PISS_LEVEL_CHANGED, onPissLevelChanged);
        Constants.GAME.addEventListener(BoardEvent.BOARD_RESET, onBoardReset);
        Constants.GAME.addEventListener(GroupCollectionEvent.GROUPS_COLLECTED, onGroupsCollected);
        Constants.GAME.addEventListener(CapacityEvent.CAPACITY_EXECUTED, onCapacityExecuted);
    }

    private function onTurnChange(e:GameEvent):void {
        _stats.startTurn(Constants.GAME);
        uploadScoreUpdate();
    }

    private function onPiss(e:GameEvent):void {
        _stats.pissed();
    }

    private function onGameOver(e:GameEvent):void {
        _stats.gameOver = true;
        uploadScoreUpdate();
    }

    private function onPissLevelChanged(e:PissLevelEvent):void {
    }

    private function onGemsSwapped(e:GemsSwappedEvent):void {
        _stats.gemsSwapped(e.sx, e.sy, e.dx, e.dy);
    }

    private function onBoardReset(e:GameEvent):void {
        _stats.resetCount++;
    }

    private function onVomit(e:GameEvent):void {
        _stats.vomitCount++;
    }

    private function onGroupsCollected(e:GroupCollectionEvent):void {
        for each (var group:Group in e.groups) {
            _stats.addCollectedGroup(group.token, group.length);
        }
    }

    private function onCapacityExecuted(e:CapacityEvent):void {
        _stats.capacityUsed(e.capacity, e.targetToken);
    }

    public function uploadScoreUpdate():void {
        if (Constants.DEBUG) {
            var data:URLVariables = _stats.getForSerialization();
            data.token = token;
            data.game_version = Constants.VERSION.toString();
            data.score = Constants.GAME.me.score;
            data.flash_version = Capabilities.version;

            var request:URLRequest = new URLRequest("/postscore");
            request.method = URLRequestMethod.POST;
            request.data = data;
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, function(e:Event):void {
                trace("Score update posted.");
            });
            try {
                loader.load(request);
                trace("Start post score update...");
            } catch (e:ArgumentError) {
                trace("Post score update: an ArgumentError has occurred.");
            } catch (e:SecurityError) {
                trace("Post score update: a SecurityError has occurred.");
            }
        }
    }

    [Bindable]
    public function get token():String {
        return _token;
    }

    [Bindable]
    public function set token(value:String):void {
        _token = value;
    }

    public function get stats():GameStats {
        return _stats;
    }

    private var _stats:GameStats = new GameStats();
    private var _token:String;
}
}