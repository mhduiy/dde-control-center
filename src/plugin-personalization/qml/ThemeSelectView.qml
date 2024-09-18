// SPDX-FileCopyrightText: 2024 - 2027 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D

ListView {
    id: listview
    // 132 = 130 + itemBorderWidth
    readonly property int itemWidth: 132
    readonly property int itemHeight: 107
    readonly property int itemBorderWidth: 2
    readonly property int itemSpacing: 50
    readonly property int imageRectH: 86
    readonly property int imageRectW: itemWidth

    readonly property int gridMaxColumns: Math.floor(listview.width / (itemWidth + itemSpacing))
    readonly property int gridMaxRows: 2
    model: Math.ceil(listViewModel.count / (2 * gridMaxColumns))
    spacing: 0
    clip: true
    orientation: ListView.Horizontal
    layoutDirection: Qt.LeftToRight
    snapMode: ListView.SnapOneItem
    boundsBehavior: Flickable.StopAtBounds
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightMoveDuration: 400

    delegate: Item {
        width: listview.width
        height: listview.height
        D.SortFilterModel {
            id: sortedModel
            model: listViewModel
            property int pageIndex: index
            property int maxCount: listview.gridMaxColumns * listview.gridMaxRows
            lessThan: function(left, right) {
                return left.index < right.index
            }
            filterAcceptsItem: function(item) {
                return item.index >= index * maxCount && item.index < (index + 1) * maxCount
            }
            onMaxCountChanged: {
                sortedModel.update()
            }

            delegate: Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                ColumnLayout {
                    width: listview.itemWidth
                    height: listview.itemHeight
                    anchors.centerIn: parent

                    Item {
                        Layout.preferredHeight: listview.imageRectH
                        Layout.preferredWidth: listview.imageRectW

                        Rectangle {
                            anchors.fill: parent
                            // visible: isCurrentItem
                            border.width: listview.itemBorderWidth
                            border.color: D.DTK.platformTheme.activeColor
                            radius: 7
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: listview.itemBorderWidth + 1
                            color: "lightGray"
                            radius: 7
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: "主题" + index
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: D.DTK.platformTheme.activeColor
                    }
                }
            }
        }
        GridLayout {
            anchors.left: parent.left
            width: repeater.count < columns ? repeater.count * (itemWidth + itemSpacing) : parent.width
            height: repeater.count <= columns ? parent.height / 2 : parent.height
            rowSpacing: 0
            columnSpacing: 0
            rows: listview.gridMaxRows
            columns: listview.gridMaxColumns
            Repeater {
                id: repeater
                model: sortedModel
            }
        }
    }
    ListModel {
        id: listViewModel
        ListElement { color: "red"; text: "主题1" }
        ListElement { color: "blue"; text: "主题2" }
        ListElement { color: "yelow"; text: "主题3" }
        ListElement { color: "red"; text: "主题4" }
        ListElement { color: "blue"; text: "主题5" }
        ListElement { color: "yelow"; text: "主题6" }
        ListElement { color: "red"; text: "主题7" }
        ListElement { color: "blue"; text: "主题8" }
        ListElement { color: "yelow"; text: "主题9" }
        ListElement { color: "red"; text: "主题10" }
        ListElement { color: "blue"; text: "主题11" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
        ListElement { color: "yelow"; text: "主题12" }
    }
}
