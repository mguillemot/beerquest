/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 18/10/10
 * Time: 22:58
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest {
public class I18n {

    private static var _lang:String = "en";

    private static const _strings:Object = {
        fr: {
            "capacity.none.name": "?",
            "capacity.none.tooltip": "",
            "capacity.blond-furybar.name": "Fury Bar",
            "capacity.blond-furybar.tooltip": "Récolte toutes les bières blondes du plateau, et les ajoute à ton score.",
            "capacity.brown-furybar.name": "Fury Bar",
            "capacity.brown-furybar.tooltip": "Récolte toutes les bières brunes du plateau, et les ajoute à ton score.",
            "capacity.amber-furybar.name": "Fury Bar",
            "capacity.amber-furybar.tooltip": "Récolte toutes les bières ambrées du plateau, et les ajoute à ton score.",
            "capacity.divine-peanuts.name": "Divine Peanuts",
            "capacity.divine-peanuts.tooltip": "Transforme la liqueur en eau.",
            "capacity.big-bang.name": "Big Bang",
            "capacity.big-bang.description": "Choisis un type d'objets sur le plateau et détruis les tous.",
            "capacity.waterfall.name": "Waterfall",
            "capacity.waterfall.tooltip": "Nettoie tout le vomito du plateau.",
            "capacity.bloody-mary.name": "Bloody Mary",
            "capacity.bloody-mary.tooltip": "Te fait gagner 5 tours supplémentaires au prix d'un peu de vomito. Burp !",
            "turns-bar.tooltip": "Tours de jeu restant. Buvez du jus de tomate pour tenir le coup !",
            "vomit-bar.tooltip": "Attention, à 100% : vomito (bloque 5 cases) ! Mangez des Cahouètes !",
            "piss-bar.tooltip": "Attention, à partir de 80% : innondation (bloque les lignes du fond) !",
            "score.tooltip": "Ton score. Il augmente de 1 pour chaque bière bue.",
            "tokens.tooltip": "Collecte 3 capsules de la même couleur pour gagner 5 de score supplémentaire !",
            "quality-button.tooltip": "Active/désactive le mode haute qualité.",
            "sound-button.tooltip": "Active/désactive les sons.",
            "start.play-button": "JOUER",
            "start.goal": "Objectif",
            "start.start-challenge": "Relancer le défi",
            "start.how-much-more.1": "Combien de bières en plus vous pensez",
            "start.how-much-more.2": "être capable de boire en 40 coups ?",
            "": ""
        },
        en: {
            "capacity.none.name": "?",
            "capacity.none.tooltip": "",
            "capacity.blond-furybar.name": "Fury Bar",
            "capacity.blond-furybar.tooltip": "Collects all blond beers on the board, and add them to your score.",
            "capacity.brown-furybar.name": "Fury Bar",
            "capacity.brown-furybar.tooltip": "Collects all brown beers on the board, and add them to your score.",
            "capacity.amber-furybar.name": "Fury Bar",
            "capacity.amber-furybar.tooltip": "Collects all amber beers on the board, and add them to your score.",
            "capacity.divine-peanuts.name": "Divine Peanuts",
            "capacity.divine-peanuts.tooltip": "Transforms the liquor into water.",
            "capacity.big-bang.name": "Big Bang",
            "capacity.big-bang.description": "Choose something on the board, and destroy everything of the same type.",
            "capacity.waterfall.name": "Waterfall",
            "capacity.waterfall.tooltip": "Cleans all vomito on the board.",
            "capacity.bloody-mary.name": "Bloody Mary",
            "capacity.bloody-mary.tooltip": "Gain 5 additional turns for the small price of some vomito. Burp!",
            "turns-bar.tooltip": "Remaining game turns. Drink tomato juice to keep up!",
            "vomit-bar.tooltip": "Warning! At 100%: vomito (blocks 5 cells). Eat something to decrease this bar.",
            "piss-bar.tooltip": "Warning! From 80% and upwards, \"strange\" floods are expected!",
            "score.tooltip": "Your score. Increase by 1 for each beer you drink.",
            "tokens.tooltip": "Collect 3 consecutive caps from the same color to increase your score by 5.",
            "quality-button.tooltip": "Enable/disable high quality mode.",
            "sound-button.tooltip": "Enable/disable sounds.",
            "start.play-button": "PLAY",
            "start.goal": "Goal",
            "start.start-challenge": "Start the challenge",
            "start.how-much-more.1": "How much more beers you think you can",
            "start.how-much-more.2": "drink in 40 turns?",
            "": ""
        }
    };

    public static function t(key:String):String {
        return _strings[_lang][key];
    }

    public static function get lang():String {
        return _lang;
    }

    public static function set lang(value:String):void {
        _lang = value;
    }

    function I18n() {
    }
}
}
