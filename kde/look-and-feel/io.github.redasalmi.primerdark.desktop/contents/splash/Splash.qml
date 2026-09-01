/*
    SPDX-FileCopyrightText: 2026 Reda Salmi
    SPDX-License-Identifier: MIT
*/

import QtQuick
import org.kde.kirigami 2 as Kirigami

Rectangle {
    id: root
    color: "#010409"

    property int stage

    onStageChanged: {
        if (stage === 2) {
            reveal.restart()
        } else if (stage === 5) {
            finish.restart()
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Column {
            anchors.centerIn: parent
            spacing: Kirigami.Units.gridUnit

            Row {
                id: mark
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Kirigami.Units.gridUnit * 0.8

                Repeater {
                    model: 3

                    Rectangle {
                        required property int index
                        width: Kirigami.Units.gridUnit * 0.9
                        height: width
                        radius: width / 2
                        color: index === 1 ? "#4493F8" : "#1F6FEB"

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: Kirigami.Units.longDuration > 1
                            PauseAnimation { duration: index * 130 }
                            NumberAnimation { from: 0.35; to: 1; duration: 320; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1; to: 0.35; duration: 320; easing.type: Easing.InOutQuad }
                            PauseAnimation { duration: (2 - index) * 130 }
                        }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Primer Dark")
                color: "#F0F6FC"
                font.pixelSize: Kirigami.Units.gridUnit * 1.25
                font.weight: Font.DemiBold
            }
        }
    }

    OpacityAnimator {
        id: reveal
        target: content
        from: 0
        to: 1
        duration: Kirigami.Units.veryLongDuration
        easing.type: Easing.InOutQuad
    }

    OpacityAnimator {
        id: finish
        target: content
        from: 1
        to: 0
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
    }
}
