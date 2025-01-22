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

    enum EnrollType{
        Face = 0,
        Finger = 1,
        Iris = 2
    }

    DccTitleObject {
        name: "BiometricAuthenticationTitle"
        parentName: objParentName
        weight: 10
        displayName: qsTr("生物认证")
    }

    DccRepeater {
        id: rep
        model: [
            {authTitle: "人脸", authDescription: "最多可以录入5个人脸数据", authIcon: "user_biometric_face", authType: BiometricAuth.EnrollType.Face, max: 5},
            {authTitle: "指纹", authDescription: "通过对指纹的扫描进行用户身份的识别", authIcon: "user_biometric_fingerprint", authType: BiometricAuth.EnrollType.Finger, max: 10},
            {authTitle: "虹膜", authDescription: "通过扫描虹膜进行身份识别", authIcon: "user_biometric_iris", authType: BiometricAuth.EnrollType.Iris, max: 10}
        ]
        property var listDatas: [dccData.biometricCtl.model.facesList, dccData.biometricCtl.model.thumbsList, dccData.faceModel]
        delegate: DccObject {
        id: faceAuthenticationGroupView
        name: loginMethodTitle.parentName + "FaceAuthenticationGroupView"
        parentName: root.objParentName
        weight: 20
        pageType: DccObject.Item
        page: DccGroupView {}


        DccObject {
            id: faceRepeaterHeaderView
            name: "FaceRepeaterHeaderView"
            parentName: loginMethodTitle.parentName + "FaceAuthenticationGroupView"
            description: modelData.authDescription
            displayName: modelData.authTitle
            icon: modelData.authIcon
            backgroundType: DccObject.Normal
            property bool listVisible: false
            property real iconSize: 30
            weight: 20
            pageType: DccObject.Editor
            page: RowLayout {
                D.DciIcon {
                    Layout.rightMargin: 5
                    name: "arrow_ordinary_up"
                    sourceSize: Qt.size(12, 12)
                    rotation: faceRepeaterHeaderView.listVisible ? 0 : 180

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
                    faceRepeaterHeaderView.listVisible = !faceRepeaterHeaderView.listVisible
                }
            }
        }
        DccRepeater {
            id: itemRep
            property var authType: modelData.authType
            model: faceRepeaterHeaderView.listVisible ? rep.listDatas[index] : []
            delegate: DccObject {
                name: modelData
                parentName: faceAuthenticationGroupView.name
                displayName: modelData
                pageType: DccObject.Item
                weight: 30 + index
                page: RowLayout {
                    id: layout

                    function requestRename(id, newName) {
                        switch(itemRep.authType) {
                            case BiometricAuth.EnrollType.Face:
                                dccData.biometricCtl.renameFace(id, newName)
                                break
                            case BiometricAuth.EnrollType.Finger:
                                dccData.biometricCtl.requestRenameFinger(id, newName)
                                break
                            case BiometricAuth.EnrollType.Iris:
                                // dccData.startEnrollIris()
                                break
                        }
                    }

                    function requestDelete(id) {
                        switch(itemRep.authType) {
                            case BiometricAuth.EnrollType.Face:
                                dccData.biometricCtl.removeFace(id)
                                break
                            case BiometricAuth.EnrollType.Finger:
                                dccData.biometricCtl.requestRemoveFinger(id)
                                break
                            case BiometricAuth.EnrollType.Iris:
                                // dccData.startEnrollIris()
                                break
                        }
                    }

                    TextInput {
                        id: textInputItem
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
                            if (modelData !== textInputItem.text) {
                                layout.requestRename(modelData, text)
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
                            textInputItem.readOnly = false
                            textInputItem.focus = true
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
                            layout.requestDelete(modelData)
                        }
                    }

                    HoverHandler {
                        id: hoverHandler
                    }
                }
            }
        }

        DccObject {
            name: loginMethodTitle.parentName + "FaceAuthentication"
            visible: faceRepeaterHeaderView.listVisible && rep.listDatas[index].length < modelData.max
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
                    text: qsTr("添加新的") + modelData.authTitle + "..."
                    font: D.DTK.fontManager.t6
                    background: Item {}
                    onClicked: {
                        startEnrollByType(modelData.authType)
                    }

                    function startEnrollByType(type) {
                        switch(type) {
                            case BiometricAuth.EnrollType.Face:
                                addFaceDialogLoader.active = true
                                addFaceDialogLoader.item.show()
                                break
                            case BiometricAuth.EnrollType.Finger:
                                addFingerDialogLoader.active = true
                                addFingerDialogLoader.item.show()
                                break
                            case BiometricAuth.EnrollType.Iris:
                                dccData.startEnrollIris()
                                break
                        }
                    }

                    Loader {
                        id: addFaceDialogLoader
                        active: false
                        sourceComponent: AddFaceinfoDialog {
                            onClosing: function (close) {
                                addFaceDialogLoader.active = false
                            }
                        }
                    }

                    Loader {
                        id: addFingerDialogLoader
                        active: false
                        sourceComponent: AddFingerDialog {
                            onClosing: function (close) {
                                addFingerDialogLoader.active = false
                            }
                        }
                    }

                    Loader {
                        id: addIrisDialogLoader
                        active: false
                        sourceComponent: AddFaceinfoDialog {
                            onClosing: function (close) {
                                addIrisDialogLoader.active = false
                            }
                        }
                    }
                }
            }
        }
    }
    }
}
