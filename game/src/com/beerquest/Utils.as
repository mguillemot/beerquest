package com.beerquest {
public class Utils {
    function Utils() {
    }

    public static function randomizeArray(array:Array):Array {
        var newArray:Array = new Array();
        while (array.length > 0) {
            var obj:Array = array.splice(Math.floor(Math.random() * array.length), 1);
            newArray.push(obj[0]);
        }
        return newArray;
    }
}
}