/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 1 sept. 2010
 * Time: 01:00:04
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest.ui {
import com.beerquest.Capacity;
import com.beerquest.Group;
import com.beerquest.TokenType;
import com.beerquest.events.BoardEvent;
import com.beerquest.events.CapacityEvent;
import com.beerquest.events.GameEvent;
import com.beerquest.events.GroupCollectionEvent;
import com.beerquest.events.PissLevelEvent;
import com.beerquest.ui.events.UiGameEvent;

import flash.events.Event;
import flash.media.Sound;

import mx.core.UIComponent;

public class SoundModule extends UIComponent {
    public function SoundModule() {
        addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
            stage.addEventListener(UiGameEvent.UI_GAME_EVENT, onUiGameEvent);
        });
    }

    private function onUiGameEvent(e:UiGameEvent):void {
        var ge:Event = e.event;
        switch (ge.type) {
            case GameEvent.PISS:
                onPiss(ge as GameEvent);
                break;
            case GameEvent.VOMIT:
                onVomit(ge as GameEvent);
                break;
            case GameEvent.GAME_OVER:
                onGameOver(ge as GameEvent);
                break;
            case GameEvent.BEER_COLLECTED:
                onBeerCollected(ge as GameEvent);
                break;
            case PissLevelEvent.PISS_LEVEL_CHANGED:
                onPissLevelChanged(ge as PissLevelEvent);
                break;
            case BoardEvent.BOARD_RESET:
                onBoardReset(ge as BoardEvent);
                break;
            case GroupCollectionEvent.GROUPS_COLLECTED:
                onGroupCollected(ge as GroupCollectionEvent);
                break;
            case CapacityEvent.CAPACITY_GAINED:
                onCapacityGained(ge as CapacityEvent);
                break;
            case CapacityEvent.CAPACITY_EXECUTED:
                onCapacityExecuted(ge as CapacityEvent);
                break;
        }
    }

    private function onPiss(e:GameEvent):void {
        playSound(PissFX);
    }

    private function onGameOver(e:GameEvent):void {
        playSound(GameOverFX);
    }

    private function onBeerCollected(e:GameEvent):void {
        playSound(StackFX);
    }

    private function onPissLevelChanged(e:PissLevelEvent):void {
        if (e.pissRaise) {
            playSound(PissRaiseFX);
        }
    }

    private function onBoardReset(e:GameEvent):void {
        playSound(BoardResetFX);
    }

    private function onVomit(e:GameEvent):void {
        playSound(VomitFX);
    }

    private function onGroupCollected(e:GroupCollectionEvent):void {
        var group:Group = e.groups[0];
        switch (group.token) {
            case TokenType.BLOND_BEER:
            case TokenType.BROWN_BEER:
            case TokenType.AMBER_BEER:
                playSound(BeerFX);
                break;
            case TokenType.WATER:
                playSound(WaterFX);
                break;
            case TokenType.LIQUOR:
                playSound(LiquorFX);
                break;
            case TokenType.FOOD:
                playSound(FoodFX);
                break;
            case TokenType.TOMATO_JUICE:
                playSound(TomatoFX);
                break;
        }
    }

    private function onCapacityGained(e:CapacityEvent):void {
        playSound(CapaGainFX);
    }

    private function onCapacityExecuted(e:CapacityEvent):void {
        if (e.capacity == Capacity.BIG_BANG) {
            playSound(BigBangFX);
        } else {
            playSound(GenericCapaFX);
        }
    }

    private function playSound(s:Class):void {
        if (_soundEnabled) {
            var fx:Sound = new s();
            fx.play();
        }
    }

    [Bindable]
    public function get soundEnabled():Boolean {
        return _soundEnabled;
    }

    [Bindable]
    public function set soundEnabled(value:Boolean):void {
        _soundEnabled = value;
    }

    private var _soundEnabled:Boolean;

    [Embed(source="../../../assets/sound/pipi.mp3")]
    private static var PissFX:Class;

    [Embed(source="../../../assets/sound/ok-capa.mp3")]
    private static var CapaGainFX:Class;

    [Embed(source="../../../assets/sound/son-montee-pisse.mp3")]
    private static var PissRaiseFX:Class;

    [Embed(source="../../../assets/sound/vomir.mp3")]
    private static var VomitFX:Class;

    [Embed(source="../../../assets/sound/biere.mp3")]
    private static var BeerFX:Class;

    [Embed(source="../../../assets/sound/boisson-a.mp3")]
    private static var WaterFX:Class;

    [Embed(source="../../../assets/sound/boisson-b.mp3")]
    private static var TomatoFX:Class;

    [Embed(source="../../../assets/sound/cahouete.mp3")]
    private static var FoodFX:Class;

    [Embed(source="../../../assets/sound/big-bang.mp3")]
    private static var BigBangFX:Class;

    [Embed(source="../../../assets/sound/liqueur.mp3")]
    private static var LiquorFX:Class;

    [Embed(source="../../../assets/sound/vidange-tableau.mp3")]
    private static var BoardResetFX:Class;

    [Embed(source="../../../assets/sound/bruit-caps.mp3")]
    private static var GenericCapaFX:Class;

    [Embed(source="../../../assets/sound/fin-partie.mp3")]
    private static var GameOverFX:Class;

    [Embed(source="../../../assets/sound/verser-biere.mp3")]
    private static var StackFX:Class;

}
}