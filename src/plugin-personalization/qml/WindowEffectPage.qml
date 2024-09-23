// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

DccObject {
    DccObject {
        name: "interfaceAndEffectTitle"
        parentName: "personalization/windowEffect"
        displayName: qsTr("界面和效果")
        weight: 10
        hasBackground: false
        pageType: DccObject.Item
        page: Label {
            font: DccUtils.copyFont(D.DTK.fontManager.t4, { "bold": true })
            text: dccObj.displayName
        }
    }

    DccObject {
        name: "interfaceAndEffect"
        parentName: "personalization/windowEffect"
        weight: 100
        pageType: DccObject.Item
        page: InterfaceEffectListview {

        }
    }

    DccObject {
        name: "windowSettingsTitle"
        parentName: "personalization/windowEffect"
        displayName: qsTr("窗口设置")
        weight: 200
        hasBackground: false
        pageType: DccObject.Item
        page: Label {
            font: DccUtils.copyFont(D.DTK.fontManager.t4, { "bold": true })
            text: dccObj.displayName
        }
    }

    DccObject {
        name: "windowSettingsGroup"
        parentName: "personalization/windowEffect"
        weight: 300
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "roundedEffect"
            parentName: "personalization/windowEffect/windowSettingsGroup"
            displayName: qsTr("窗口圆角")
            weight: 1
            pageType: DccObject.Item
            page: ColumnLayout {
                Layout.fillHeight: true
                Label {
                    id: speedText
                    Layout.topMargin: 10
                    font: D.DTK.fontManager.t7
                    text: dccObj.displayName
                    Layout.leftMargin: 10
                }

                ListView {
                    id: listview
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    Layout.margins: 10
                    clip: true
                    property var tips: ["无", "小", "中", "大"]
                    property var icons: ["corner_none", "corner_small", "corner_middle", "corner_big"]

                    model: tips.length
                    orientation: ListView.Horizontal
                    layoutDirection: Qt.LeftToRight
                    spacing: 12
                    delegate: ColumnLayout {
                        id: layout
                        property bool checked : dccData.model.windowRadius === 6 * index
                        width: 112
                        height: 104
                        Item {
                            Layout.preferredHeight: 77
                            Layout.fillWidth: true
                            Rectangle {
                                anchors.fill: parent
                                radius: 7
                                color: "transparent"
                                visible: layout.checked
                                border.width: 2
                                border.color: D.DTK.platformTheme.activeColor
                            }
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                color: Qt.rgba(0, 0, 0, 0.05)
                                radius: 7
                                D.DciIcon{
                                    sourceSize: Qt.size(parent.width, parent.height)
                                    name: listview.icons[index]
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    dccData.worker.setWindowRadius(6 * index)
                                }
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: listview.tips[index]
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: layout.checked ? D.DTK.platformTheme.activeColor : this.palette.windowText
                        }
                    }
                }
            }
        }

        DccObject {
            name: "enableTransparentWhenMoveWindow"
            parentName: "personalization/windowEffect/windowSettingsGroup"
            displayName: qsTr("窗口移动时启用透明特效")
            weight: 2
            pageType: DccObject.Editor
            page: D.Switch {
                onCheckedChanged: {

                }
            }
        }

        DccObject {
            name: "minimizeEffect"
            parentName: "personalization/windowEffect/windowSettingsGroup"
            displayName: qsTr("最小化时效果")
            weight: 3
            pageType: DccObject.Editor
            page: D.ComboBox {
                flat: true
                currentIndex: dccData.model.miniEffect
                model: [qsTr("Scale"), qsTr("Magic Lamp")]
                onCurrentIndexChanged: {
                    dccData.worker.setMiniEffect(currentIndex)
                }
            }
        }

    }

    DccObject {
        name: "computerSuspendsAfter"
        parentName: "personalization/windowEffect"
        displayName: qsTr("不透明度调节")
        weight: 600
        pageType: DccObject.Item
        hasBackground: true
        page: ColumnLayout {
            Layout.fillHeight: true
            Label {
                Layout.topMargin: 10
                font: D.DTK.fontManager.t7
                text: dccObj.displayName
                Layout.leftMargin: 10
            }

            D.TipsSlider {
                readonly property var tips: [qsTr("低"), (""), qsTr("高")]
                Layout.alignment: Qt.AlignCenter
                Layout.margins: 10
                Layout.fillWidth: true
                tickDirection: D.TipsSlider.TickDirection.Back
                slider.handleType: Slider.HandleType.ArrowBottom
                slider.value: dccData.model.opacity * 100
                slider.from: 20
                slider.to: 100
                slider.live: true
                slider.stepSize: 1
                slider.snapMode: Slider.SnapAlways
                ticks: [
                    D.SliderTipItem {
                        text: doubleClickSlider.tips[0]
                    },
                    D.SliderTipItem {
                        text: doubleClickSlider.tips[1]
                    },
                    D.SliderTipItem {
                        text: doubleClickSlider.tips[2]
                    }
                ]
                slider.onValueChanged: {
                    dccData.worker.setOpacity(slider.value)
                }
            }
        }
    }

    DccObject {
        name: "scrollBar"
        parentName: "personalization/windowEffect"
        displayName: qsTr("滚动条")
        weight: 700
        hasBackground: true
        pageType: DccObject.Editor
        page: D.ComboBox {
            flat: true
            model: [qsTr("滚动时显示"), qsTr("始终显示")]
        }
    }

    DccObject {
        name: "scrollBar"
        parentName: "personalization/windowEffect"
        displayName: qsTr("紧凑模式")
        weight: 700
        hasBackground: true
        pageType: DccObject.Editor
        page: D.Switch {
            onCheckedChanged: {

            }
        }
    }

    DccObject {
        name: "scrollBar"
        parentName: "personalization/windowEffect"
        displayName: qsTr("标题栏高度")
        weight: 700
        hasBackground: true
        pageType: DccObject.Editor
        page: D.ComboBox {
            flat: true
            model: [qsTr("滚动时显示"), qsTr("始终显示")]
        }
    }
}
