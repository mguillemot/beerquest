package com.beerquest.ui {
import com.beerquest.*;

import flash.display.DisplayObject;

import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.events.CollectionEvent;

public class TokenCollectionView extends UIComponent {

    public function TokenCollectionView() {
        width = 170;
        height = 30;
        graphics.clear();
        graphics.lineStyle(1, 0x0);
        graphics.drawRect(0, 0, width, height);
    }

    [Bindable]
    public function set collection(value:ArrayCollection):void {
        if (_collection != null) {
            _collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        }
        _collection = value;
        _collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        compact();
    }

    private function onCollectionChange(e:CollectionEvent):void {
        switch (e.kind) {
            case "add":
                for each(var token:Object in e.items) {
                    var t:Token = new Token(token.type);
                    token.token = t;
                    t.width = t.height = (token.big) ? 20 : 10;
                    addChild(t);
                }
                compact();
                break;
        }
    }

    private function compact():void {
        for (var i:int = 0; i < _collection.length - 2; i++) {
            var type:TokenType = _collection.getItemAt(i).type;
            if (!_collection.getItemAt(i).big
                    && _collection.getItemAt(i + 1).type == type && !_collection.getItemAt(i + 1).big
                    && _collection.getItemAt(i + 2).type == type && !_collection.getItemAt(i + 1).big) {
                var x:Number = _collection.getItemAt(i).token.x;
                for (var k:int; k < 3; k++) {
                    var item:Object = _collection.removeItemAt(i);
                    removeChild(item.token);
                }
                var collectedBig:Object = {type:type, big:true};
                _collection.addItemAt(collectedBig, i);
                compact();
                return;
            }
        }
        recomputeCoords();
    }

    private function recomputeCoords():void {
        var cursorX:Number = 0;
        var cursorY:Number = 0;
        for (var i:int = 0; i < _collection.length; i++) {
            var token:DisplayObject = _collection.getItemAt(i).token;
            if (cursorX + token.width > width) {
                cursorX = 0;
                cursorY += 20;
            }
            token.x = cursorX;
            token.y = cursorY;
            cursorX += token.width;
        }
    }

    private var _collection:ArrayCollection;
}
}