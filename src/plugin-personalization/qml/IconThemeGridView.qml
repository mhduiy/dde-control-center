// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

GridLayout {
    Layout.fillHeight: true
    Layout.margins: 10
    columns: width / 250
    rowSpacing: 10
    Repeater {
        model: 17
        Item {
            Layout.preferredHeight: 97
            Layout.fillWidth: true
            Rectangle {
                anchors.fill: parent
                color: "transparent"
            }
            Rectangle {
                id: rect
                anchors.centerIn: parent
                width: 245
                height: 97
                radius: 8
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    RowLayout {
                        Layout.preferredHeight: 30
                        Layout.fillWidth: true
                        Text {
                            text: "bloom"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 28
                            height: 28
                            color: "green"
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        color: palette.window
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        border.color: "gray"
                    }
                }
            }
        }
    }
}
