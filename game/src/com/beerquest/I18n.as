/**
 * Created by IntelliJ IDEA.
 * User: Erhune
 * Date: 18/10/10
 * Time: 22:58
 * To change this template use File | Settings | File Templates.
 */
package com.beerquest {
import mx.core.FlexGlobals;

public class I18n {

    private static var _lang:String = "";

    private static const _strings:Object = {
        fr: {
            "capacity.none.name": "?",
            "capacity.none.tooltip": "",
            "capacity.blond-furybar.name": "Fury Bar",
            "capacity.blond-furybar.tooltip": "Vidange toutes les bières blondes du plateau, et les ajoute à ton score",
            "capacity.brown-furybar.name": "Fury Bar",
            "capacity.brown-furybar.tooltip": "Vidange toutes les bières brunes du plateau, et les ajoute à ton score",
            "capacity.amber-furybar.name": "Fury Bar",
            "capacity.amber-furybar.tooltip": "Vidange toutes les bières ambrées du plateau, et les ajoute à ton score",
            "capacity.divine-peanuts.name": "Divine Peanuts",
            "capacity.divine-peanuts.tooltip": "Miracle ! Transforme la liqueur en eau",
            "capacity.big-bang.name": "Big Bang",
            "capacity.big-bang.description": "Choisis un type d'objets sur le plateau et détruis-les tous",
            "capacity.waterfall.name": "Waterfall",
            "capacity.waterfall.tooltip": "Nettoie tout les vomis du plateau",
            "capacity.bloody-mary.name": "Bloody Mary",
            "capacity.bloody-mary.tooltip": "Fait gagner 5 tours supplémentaires au prix d'un peu de vomi. Burp !",
            "turns-bar.tooltip": "Tours de jeu restant. Bois du jus de tomate pour tenir le coup !",
            "vomit-bar.tooltip": "Attention, à 100% : vomito (bloque 5 cases) ! Mange des Cahouètes !",
            "piss-bar.tooltip": "Attention, à partir de 80% : innondation (bloque les lignes du fond) !",
            "score.tooltip": "Augmente ton score de 1 pour chaque bière bue.",
            "tokens.tooltip": "Collecte 3 capsules de la même couleur pour gagner 5 de score supplémentaire !",
            "quality-button.tooltip": "Active/désactive le mode haute qualité.",
            "sound-button.tooltip": "Active/désactive les sons.",
            "start.play-button": "JOUER",
            "start.goal": "Objectif",
            "start.start-challenge": "Relancer le défi",
            "start.how-much-more.1": "Combien de bières en plus tu comptes",
            "start.how-much-more.2": "t'enquiller en 40 coups ?",
            "end.congratulations": "BRAVO !",
            "end.score": "Score",
            "end.solo.game-over": "Partie Terminée",
            "end.solo.bad-score.1": "C'est un score assez minable, mais si tu n'as",
            "end.solo.bad-score.2": "honte de rien, tu peux toujours t'en vanter...",
            "end.solo.personal-record": "Nouveau record perso",
            "end.solo.bar-record": "Nouveau record du bar",
            "end.solo.boast-button.1": "S'la péter",
            "end.solo.boast-button.2": "(malgré tout)",
            "end.solo.boast-button.3": "(pour de bon)",
            "end.solo.provoke-button": "Provoquer mes amis",
            "end.solo.play-again-button.1": "JOUER",
            "end.solo.play-again-button.2": "Encore",
            "end.vs.you-loose": "T'as perdu !",
            "end.vs.boast-button.1": "Vante",
            "end.vs.boast-button.2": "Toi !",
            "end.vs.provoke-button.1": "Provoque",
            "end.vs.provoke-button.2": "ton ami !",
            "end.vs.play-again-button.1": "Relancer",
            "end.vs.play-again-button.2": "un Défi",
            "end.vs.play-again-button.3": "...et me ridiculiser encore plus",
            "end.vs.wall-of-shame-button.1": "Mur de la",
            "end.vs.wall-of-shame-button.2": "HONTE",
            "end.vs.wall-of-shame-button.3": "Publier ma défaite sur mon mur",
            "end.vs.loose-explaination.1": "T'as eu les yeux plus gros que le ventre...",
            "end.vs.loose-explaination.2": "Bouh, quelle honte !",
            "end.vs.success-explaination.1a": "Tu as gagné ce round en ",
            "end.vs.success-explaination.1b": " coups !",
            "end.vs.success-explaination.2": "Ton ami arrivera-t-il à faire mieux ?",
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
            "end.congratulations": "GRATZ!",
            "end.score": "Score",
            "end.solo.game-over": "Game Over",
            "end.solo.bad-score.1": "That's pretty bad, but if you're dhameless,",
            "end.solo.bad-score.2": "you can still brag 'bout it...",
            "end.solo.personal-record": "New personal record",
            "end.solo.bar-record": "New bar record",
            "end.solo.boast-button.1": "Show them",
            "end.solo.boast-button.2": "how bad I am",
            "end.solo.boast-button.3": "I'm the best",
            "end.solo.provoke-button": "Provoke your friend!",
            "end.solo.play-again-button.1": "PLAY",
            "end.solo.play-again-button.2": "Again",
            "end.vs.you-loose": "You Loose!",
            "end.vs.boast-button.1": "Let's",
            "end.vs.boast-button.2": "brag!",
            "end.vs.provoke-button.1": "Provoke",
            "end.vs.provoke-button.2": "your friend!",
            "end.vs.play-again-button.1": "Start new",
            "end.vs.play-again-button.2": "challenge",
            "end.vs.play-again-button.3": "...and get even more ridiculous",
            "end.vs.wall-of-shame-button.1": "WALL OF",
            "end.vs.wall-of-shame-button.2": "SHAME",
            "end.vs.wall-of-shame-button.3": "Publish this on my wall",
            "end.vs.loose-explaination.1": "You were damn too pretentions on this one.",
            "end.vs.loose-explaination.2": "Shame on you!",
            "end.vs.success-explaination.1a": "You've won this round in ",
            "end.vs.success-explaination.1b": " turns.",
            "end.vs.success-explaination.2": "Will your friend be able to beat this one?",
            "": ""
        }
    };

    // Static initializer
    {
        _lang = FlexGlobals.topLevelApplication.parameters.lang;
        if (_lang != "fr" && _lang != "en") {
            trace("WARN: Wrong language code '" + _lang + "', defaulting to 'en'");
            _lang = "en";
            // _lang = "fr"; // for test only
        }
        trace("Language is set to: " + _lang);
    }

    public static function t(key:String):String {
        return _strings[_lang][key];
    }

    public static function get lang():String {
        return _lang;
    }

    function I18n() {
    }
}
}
