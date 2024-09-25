// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccObject {
        name: "accentColorTitle"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("活动用色")
        weight: 1
        hasBackground: false
        pageType: DccObject.Item
        page: Label {
            font: DccUtils.copyFont(D.DTK.fontManager.t4, { "bold": true })
            text: dccObj.displayName
        }
    }

    DccObject {
        name: "accentColor"
        parentName: "personalization/colorAndIcons"
        weight: 100
        pageType: DccObject.Item
        hasBackground: true
        page: ListView {
            id: listview
            property var colors: ["#D8316C", "#FF5D00", "#F8CB00", "#89C32B", "#00C433", "#00A49E", "#1F6EE7", "#5624DA", "#7C1AC2", "#E564C9", "#4D4D4D", "CUSTOM"]
            // implicitWidth: 300
            implicitHeight: 60
            leftMargin: 10
            clip: true
            model: colors.length
            orientation: ListView.Horizontal
            layoutDirection: Qt.LeftToRight
            spacing: 12

            delegate: Item {
                anchors.verticalCenter: parent.verticalCenter
                property string activeColor: dccData.model.activeColor
                property string currentColor: listview.colors[index]
                width: 30
                height: 30
                Rectangle {
                    anchors.fill: parent
                    border.width: 2
                    visible: activeColor === currentColor || (currentColor == "CUSTOM" && listview.colors.indexOf(activeColor) === -1)
                    border.color: currentColor == "CUSTOM" ? activeColor : currentColor
                    radius: width / 2
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: width / 2
                    color: listview.colors[index] === "CUSTOM" ? "transparent" : listview.colors[index]
                    anchors.centerIn: parent

                    Canvas {
                        anchors.fill: parent
                        visible: listview.colors[index] === "CUSTOM"
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = Math.min(width, height) / 2;

                            var gradient = ctx.createConicalGradient(centerX, centerY, 0, centerX, centerY, radius);

                            gradient.addColorStop(0.0, "red");
                            gradient.addColorStop(0.167, "yellow");
                            gradient.addColorStop(0.333, "green");
                            gradient.addColorStop(0.5, "cyan");
                            gradient.addColorStop(0.667, "blue");
                            gradient.addColorStop(0.833, "magenta");
                            gradient.addColorStop(1.0, "red");

                            ctx.fillStyle = gradient;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.closePath();
                            ctx.fill();
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dccData.worker.setActiveColor(listview.colors[index])
                            // console.warn("------", dccData.)
                            // colorDialog.show()
                        }
                    }

                    // 颜色选择对话框
                    // Window {
                    //     D.DWindow.enabled: true
                    //     color: "transparent"
                    //     id: colorDialog
                    //     width: 500
                    //     height: 500
                    //     ColorDialog {
                    //         visible: true
                    //         title: "选择颜色"
                    //     }
                    //     D.StyledBehindWindowBlur {
                    //         control: parent
                    //         anchors.fill: parent
                    //     }
                    // }
                }
            }
        }
    }


    DccObject {
        name: "iconSettingsTitle"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("图标设置")
        weight: 200
        hasBackground: false
        pageType: DccObject.Item
        page: Label {
            font: DccUtils.copyFont(D.DTK.fontManager.t4, { "bold": true })
            text: dccObj.displayName
        }
    }

    DccObject {
        name: "iconTheme"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("图标主题")
        description: qsTr("自定义您的主题图标")
        icon: "theme_icon"
        weight: 300
        hasBackground: true
        pageType: DccObject.MenuEditor
        page: Label {
            text: dccData.model.iconModel.currentTheme
        }

        DccObject {
            name: "iconThemeSelect"
            parentName: "personalization/colorAndIcons/iconTheme"
            weight: 1
            hasBackground: false
            DccObject {
                name: "cursorThemeSelect"
                parentName: "personalization/colorAndIcons/iconTheme/iconThemeSelect"
                weight: 1
                hasBackground: false
                pageType: DccObject.Item
                page: IconThemeGridView {
                    model: dccData.iconThemeViewModel
                    onRequsetSetTheme: (id)=> {
                        dccData.requestSetIconTheme(id)
                    }
                }
            }
        }
    }
    DccObject {
        name: "cursorTheme"
        parentName: "personalization/colorAndIcons"
        displayName: qsTr("光标主题")
        description: qsTr("自定义您的主题光标")
        icon: "topic_cursor"
        weight: 400
        hasBackground: true
        pageType: DccObject.MenuEditor
        page: Label {
            text: dccData.model.cursorModel.currentTheme
        }

        DccObject {
            name: "cursorThemeSelect"
            parentName: "personalization/colorAndIcons/cursorTheme"
            weight: 1
            hasBackground: false
            DccObject {
                name: "cursorThemeSelect"
                parentName: "personalization/colorAndIcons/cursorTheme/cursorThemeSelect"
                weight: 1
                hasBackground: false
                pageType: DccObject.Item
                page: IconThemeGridView {
                    model: dccData.cursorThemeViewModel
                    onRequsetSetTheme: (id)=> {
                        dccData.requestSetCursorTheme(id)
                    }
                }
            }
        }
    }
}
