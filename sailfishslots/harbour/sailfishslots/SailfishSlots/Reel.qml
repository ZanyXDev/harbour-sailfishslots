import harbour.sailfishslots.SailfishSlots 1.0
import harbour.sailfishslots.SailfishWidgets.Utilities 3.3
import "../QmlLogger/Logger.js" as Console
import QtQuick 2.2
import Sailfish.Silica 1.0

Column  {
    id: reelColumn
    signal spin(int duration)

    property variant symbols: []
    property variant reelSize: Orientation.Portrait ? UIConstants.PORTRAIT_SYMBOL : UIConstants.LANDSCAPE_SYMBOL

    move: Transition {
         NumberAnimation {
             id: number;
             properties: "x,y";
             duration: UIConstants.spinSpeedMs
         }
    }

    Component {
        id: symbolTemplate
        Text {
            property int duration

            id: txt
            width: reelColumn.width
            height: reelColumn.height
            x: reelColumn.x
            y: reelColumn.y
            text: UIConstants.symbols[0]
            font.pixelSize: parent.width
            color: Theme.highlightColor

        }
    }

    DynamicLoader {
        id: loader
        onObjectCompleted: {
            symbols.push(object)
        }
    }

    Timer {
        id: spinTimer
        triggeredOnStart: true
        interval: UIConstants.spinSpeedMs
        repeat: true

        property int cur: 0
        property int duration

        onTriggered: {
            symbols.pop().destroy()
            createSymbols()

            cur += interval
            if(cur >= duration)
                stop()
        }
    }

    onSpin: {
        Console.log("Duration " + duration)
        spinTimer.duration = duration
        spinTimer.start()
    }

    function createSymbols() {
        Console.debug("here")
        var randSymbolIndex = 0
        var curSymbol = 0
        var randSymbol = Math.random()

        for (var i = 0; i < UIConstants.ratios.length; i++) {
            Console.debug("curSymbol: " + curSymbol + " Rand Symbol " + randSymbol)
            curSymbol += UIConstants.ratios[i];
            if(curSymbol >= randSymbol) {
                randSymbolIndex = i
                break;
            }
        }

        var ch = UIConstants.symbols[randSymbolIndex]
        Console.debug("current symbol: " + randSymbolIndex + " " + ch)

        loader.create(symbolTemplate, reelColumn, {text: ch })
    }

    function getSelectedComponent() {
        return Math.floor(symbols.size() / 2)
    }

    Component.onCompleted: {
        Console.LOG_PRIORITY = Console.VERBOSE
        Console.info("Creating initial components")
        Console.debug("Reel size: " + reelSize)
        for(var i = 0; i < reelSize; i++)
          createSymbols()
    }
}