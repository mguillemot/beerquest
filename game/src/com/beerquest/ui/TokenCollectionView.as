package com.beerquest.ui {
import com.beerquest.*;

import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.events.CollectionEvent;

public class TokenCollectionView extends UIComponent {
    public function TokenCollectionView() {
        graphics.clear();
        graphics.lineStyle(1, 0x0);
        graphics.drawRect(0, 0, 170, 30);
    }

    [Bindable]
    public function set collection(value:ArrayCollection):void {
        if (_collection != null) {
            _collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
        }
        _collection = value;
        _collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
    }

    private function onCollectionChange(e:CollectionEvent):void {
        switch (e.kind) {
            case "add":
                for each(var token:Object in e.items) {
                    var t:Token = new Token(token.type);
                    t.width = t.height = (token.big) ? 25 : 10;
                    t.x = _cursorX;
                    _cursorX += t.width;
                    addChild(t);
                }
                break;
        }
    }

    private var _collection:ArrayCollection;
    private var _cursorX:int = 0;
}
}