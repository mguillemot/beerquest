package com.beerquest {
public class Utils {
    function Utils() {
    }

    public static function randomizeArray(array:Array, rand:MersenneTwister = null):Array {
        if (rand == null) {
            rand = MersenneTwister.generate();
        }
        var newArray:Array = new Array();
        while (array.length > 0) {
            var obj:Array = array.splice(rand.nextInt(0, array.length - 1), 1);
            newArray.push(obj[0]);
        }
        return newArray;
    }
}
}