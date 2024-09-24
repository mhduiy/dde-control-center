// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15

import org.deepin.dtk 1.0 as D
import org.deepin.dcc 1.0

Rectangle {
    id: root
    property alias model: repeater.model
    property bool backgroundVisible: true
    signal clicked(int index, bool checked)

    enum WindowEffectType {
        Default = 0,
        Best,
        Better,
        Good,
        Normal,
        Compatible
    }

    color: "transparent"
    implicitHeight: layoutView.height
    Layout.fillWidth: true

    ColumnLayout {
        id: layoutView
        width: parent.width
        clip: true
        spacing: 0
        Repeater {
            id: repeater
            model: listModel
            delegate: D.ItemDelegate {
                Layout.fillWidth: true
                leftPadding: 10
                rightPadding: 10
                cascadeSelected: true
                checkable: false
                contentFlow: true
                corners: getCornersForBackground(index, powerModeModel.count)
                icon.name: model.icon
                content: RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        Layout.leftMargin: 5
                        Layout.fillWidth: true
                        DccLabel {
                            Layout.fillWidth: true
                            text: model.title
                        }
                        DccLabel {
                            Layout.fillWidth: true
                            visible: text !== ""
                            font: D.DTK.fontManager.t8
                            text: model.description
                            opacity: 0.5
                        }
                    }
                    Control {
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 10
                        contentItem: DccCheckIcon {
                            visible: model.value === dccData.model.windowEffectType
                        }
                    }
                }
                background: DccListViewBackground {
                    separatorVisible: true
                    highlightEnable: false
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.warn("-------", model.value)
                        dccData.worker.setWindowEffect(model.value)
                    }
                }
            }
        }
    }

    ListModel {
        id: listModel

        ListElement {
            value: InterfaceEffectListview.WindowEffectType.Normal
            title: qsTr("最佳性能")
            icon: "optimum_performance"
            description: qsTr("关闭所有界面和窗口特效，保障系统高效运行")
        }

        ListElement {
            value: InterfaceEffectListview.WindowEffectType.Better
            title: qsTr("均衡")
            icon: "balance"
            description: qsTr("限制部分窗口特效，保障出色的视觉效果，同时维持整体流畅运行")
        }

        ListElement {
            value: InterfaceEffectListview.WindowEffectType.Best
            title: qsTr("最佳视觉")
            icon: "best_vision"
            description: qsTr("开启所有界面和窗口特效，体验最佳视觉效果")
        }
    }
}
