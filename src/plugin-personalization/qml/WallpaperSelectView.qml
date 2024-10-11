// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

ColumnLayout {
    id: root
    property var model
    readonly property int imageRectH: 120
    readonly property int imageRectW: 180
    readonly property int imageSpacing: 10
    property bool isExpand: false

    onIsExpandChanged: {
        sortedModel.update()
    }

    RowLayout {
        id: titleLayout
        Layout.preferredHeight: 50
        Layout.fillWidth: true
        Label {
            Layout.leftMargin: 10
            font: D.DTK.fontManager.t4
            text: dccObj.displayName
        }
        Item {
            Layout.fillWidth: true
        }
        D.ToolButton {
            text: isExpand ? "收起" : `显示全部-${model}张`
            font: D.DTK.fontManager.t6
            flat: true
            onClicked: {
                isExpand = !isExpand
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: containter.height

        // animation used
        Rectangle {
            id: containter
            width: parent.width
            height: layout.height
            color: "transparent"
            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuart
                }
            }
        }

        D.SortFilterModel {
            id: sortedModel
            model: root.model
            property int maxCount: Math.floor((layout.width + imageSpacing) / (imageRectW + imageSpacing)) * 2
            lessThan: function(left, right) {
                return left.index < right.index
            }
            filterAcceptsItem: function(item) {
                return isExpand ? true : item.index < maxCount
            }
            onMaxCountChanged: {
                sortedModel.update()
            }

            delegate: Rectangle {
                width: root.imageRectW
                height: root.imageRectH
                color: "transparent"

                Image {
                    anchors.fill: parent
                    id: image
                    source: "file:///home/zhangnkun/Pictures/b15415ced7bb11b63e9bee2d0e06f19b.jpg"
                    visible: false
                    fillMode: Image.PreserveAspectCrop
                }

                OpacityMask {
                    anchors.fill: parent
                    source: image
                    maskSource: Rectangle {
                        implicitWidth: image.width
                        implicitHeight: image.height
                        radius: 8
                    }
                }
            }
        }
        Flow {
            id: layout
            width: parent.width
            spacing: imageSpacing
            bottomPadding: imageSpacing

            move: Transition {
            }

            Repeater {
                model: sortedModel
            }
        }
    }
}
