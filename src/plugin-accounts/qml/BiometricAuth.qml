// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Window 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

import org.deepin.dcc 1.0
import org.deepin.dtk 1.0 as D
import org.deepin.dtk.style 1.0 as DS

DccObject {
    id: root
    property var objParentName: ""

    DccTitleObject {
        name: "BiometricAuthenticationTitle"
        parentName: objParentName
        weight: 10
        displayName: qsTr("生物认证")
    }

    DccObject {
        id: faceAuthenticationGroupView
        name: loginMethodTitle.parentName + "FaceAuthenticationGroupView"
        parentName: root.objParentName
        displayName: qsTr("FaceAuthenticationGroupView")
        description: qsTr("Face Authentication Settings")
        weight: 20
        pageType: DccObject.Item
        page: DccGroupView {}

        DccObject {
            id: faceRepeaterHeaderView
            name: "FaceRepeaterHeaderView"
            parentName: loginMethodTitle.parentName + "FaceAuthenticationGroupView"
            description: qsTr("最多可以录入5个人脸数据")
            displayName: qsTr("人脸")
            icon: "user_biometric_face"
            property bool faceVisible: false
            backgroundType: DccObject.Normal
            property real iconSize: 30
            weight: 20
            pageType: DccObject.Editor
            page: RowLayout {
                D.DciIcon {
                    Layout.rightMargin: 5
                    name: "arrow_ordinary_up"
                    sourceSize: Qt.size(12, 12)
                    rotation: faceRepeaterHeaderView.faceVisible ? 0 : 180

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
            }

            Connections {
                target: faceRepeaterHeaderView.parentItem
                function onClicked() {
                    faceRepeaterHeaderView.faceVisible = !faceRepeaterHeaderView.faceVisible
                }
            }
        }
        DccRepeater {
            id: faceRepeater
            model: faceRepeaterHeaderView.faceVisible ? dccData.faceModel.facesList : []
            delegate: DccObject {
                name: modelData
                parentName: faceAuthenticationGroupView.name
                displayName: modelData
                pageType: DccObject.Item
                weight: 30 + index
                page: RowLayout {
                    TextInput {
                        id: faceItem
                        text: modelData
                        Layout.leftMargin: 10
                        Layout.preferredHeight: DS.Style.itemDelegate.height
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        focus: false
                        wrapMode: Text.NoWrap
                        readOnly: true
                        focusPolicy: Qt.NoFocus
                        onEditingFinished: {
                            focus = false
                            if (modelData !== faceItem.text) {
                                dccData.renameFace(modelData, faceItem.text)
                            }
                        }
                        onFocusChanged: {
                            if (!focus)
                                readOnly = true;
                        }
                        Keys.onEnterPressed: {
                            focus = false
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    D.ToolButton {
                        id: editButton
                        visible: hoverHandler.hovered
                        icon.name: "edit"
                        background: Rectangle {
                            color: "transparent"
                        }
                        onClicked: {
                            faceItem.readOnly = false
                            faceItem.focus = true
                        }
                    }
                    D.ToolButton {
                        id: deleteButton
                        visible: hoverHandler.hovered
                        icon.name: "delete"
                        background: Rectangle {
                            color: "transparent"
                        }
                        onClicked: {
                            dccData.removeFace(modelData)
                        }
                    }

                    HoverHandler {
                        id: hoverHandler
                    }
                }
            }
        }

        DccObject {
            id: addFaceLabel
            name: loginMethodTitle.parentName + "FaceAuthentication"
            visible: faceRepeaterHeaderView.faceVisible && dccData.faceModel.facesList.length < 5
            parentName: faceAuthenticationGroupView.name
            pageType: DccObject.Item
            weight: 50
            page: RowLayout {
                D.ToolButton {
                    implicitHeight: DS.Style.itemDelegate.height
                    Layout.leftMargin: 5
                    textColor: D.Palette {
                        normal {
                            common: D.DTK.makeColor(D.Color.Highlight)
                        }
                        normalDark: normal
                        hovered {
                            common: D.DTK.makeColor(D.Color.Highlight).lightness(+30)
                        }
                        hoveredDark: hovered
                    }
                    text: "添加人脸..."
                    background: Item {}
                    onClicked: {
                        addFaceDialog.show()
                    }
                    AddFaceinfoDialog {
                        id: addFaceDialog
                    }
                }
            }

            
        }
    }
}
