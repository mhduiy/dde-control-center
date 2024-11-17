// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D
import org.deepin.dtk.style 1.0 as DS

DccObject {
    DccObject {
        name: "filefolderViewGroup"
        parentName: "privacy/filefolder"
        weight: 100
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            name: "title"
            weight: 1
            parentName: "privacy/filefolder/filefolderViewGroup"
            pageType: DccObject.Editor
            displayName: "允许下面的应用访问您的文件和文件夹"
        }

        DccRepeater {
            model: 18
            delegate: DccObject {
                name: "plugin" + model.itemKey
                property real iconSize: 16
                parentName: "privacy/filefolder/filefolderViewGroup"
                weight: 10 + index * 10
                hasBackground: true
                icon: "deepin-terminal"
                displayName: "终端"
                pageType: DccObject.Item
                page: ColumnLayout {
                    id: layout
                    property bool isExpaned: false
                    Layout.bottomMargin: 10

                    transitions: [
                        Transition {
                            RotationAnimation { duration: 200; }
                        }
                    ]

                    RowLayout {
                        implicitHeight: DS.Style.itemDelegate.height
                        D.DciIcon {
                            sourceSize: Qt.size(24, 24)
                            name: "deepin-terminal"
                        }
                        DccLabel {
                            text: "终端"
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        D.IconButton {
                            id: rightCheckBtn
                            flat: true
                            icon.name: "arrow-down"
                            icon.width: 16
                            icon.height: 16
                            transitions: [
                                Transition {
                                    RotationAnimation { duration: 200; }
                                }
                            ]
                            onClicked: {
                                layout.isExpaned = !layout.isExpaned
                            }
                            state: layout.isExpaned ? "opened" : "closed"
                            states: [
                                State {
                                    name: "opened"
                                    PropertyChanges { target: rightCheckBtn.contentItem; rotation: 180 }
                                },

                                State {
                                    name: "closed"
                                    PropertyChanges { target: rightCheckBtn.contentItem; rotation: 0 }
                                }
                            ]
                        }
                    }

                    Repeater {
                        id: rep
                        model: layout.isExpaned ? ["文档", "图片", "桌面", "视频", "音乐", "下载"] : []
                        delegate: D.ItemDelegate {
                            Layout.fillWidth: true
                            cascadeSelected: true
                            checkable: false
                            contentFlow: true
                            corners: getCornersForBackground(index, rep.model.count)
                            content: RowLayout {
                                DccLabel {
                                    Layout.fillWidth: true
                                    text: "\"" + modelData + "\"" + "文件夹"
                                }
                                Control {
                                    Layout.alignment: Qt.AlignRight
                                    Layout.rightMargin: 10
                                    contentItem: DccCheckIcon {

                                    }
                                }
                            }
                            background: DccItemBackground {
                                separatorVisible: true
                                highlightEnable: false
                            }
                        }
                    }
                }
            }
        }
    }
}
