// SPDX-FileCopyrightText: 2024 UnionTech Software Technology Co., Ltd.
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Window
import QtQml.Models 2.1
import QtQuick.Layouts 1.15
import org.deepin.dtk 1.0 as D
import org.deepin.dtk.style 1.0 as DS
import org.deepin.dcc 1.0

// 每次显示的时候回到第一页
// 看能不能设置完成之后再增加一页
// 取消授权之后取消对话框的显示

D.DialogWindow {
    id: dialog
    width: 360
    height: 500
    minimumWidth: width
    maximumWidth: minimumWidth
    modality: Qt.WindowModal
    title: qsTr("Enroll Face")

    D.ListView {
        id: listview
        implicitWidth: dialog.width - DS.Style.dialogWindow.contentHMargin * 2
        implicitHeight: 500 - DS.Style.dialogWindow.titleBarHeight - 10
        spacing: DS.Style.dialogWindow.contentHMargin
        model: itemModel
        orientation: ListView.Horizontal
        layoutDirection: Qt.LeftToRight
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 400
        interactive: false

        ObjectModel {
            id: itemModel
            ColumnLayout {
                height: ListView.view.implicitHeight
                width: ListView.view.implicitWidth

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: dialog.title
                    font.bold: true
                }

                Item {
                    Layout.preferredHeight: 50
                }

                D.DciIcon {
                    name: "user_biometric_face_add"
                    Layout.alignment: Qt.AlignCenter
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    font: D.DTK.fontManager.t8
                    wrapMode: Text.WordWrap
                    text: qsTr("Make sure all parts of your face are not covered by objects and are clearly visible. Your face should be well-lit as well.")
                    horizontalAlignment: Text.AlignHCenter
                }

                Item {
                    Layout.preferredHeight: 80
                }

                Row {
                    Layout.alignment: Qt.AlignCenter
                    CheckBox {
                        id: agreeCheckbox
                    }
                    Label {
                        text: qsTr("I have read and agree to the ")
                    }
                    Label {
                        textFormat: Text.RichText
                        text: qsTr('<a href="test">Disclaimer</a>')
                        onLinkActivated: link => {
                            console.log("Todo: Show disclaimer dialog");
                        }
                    }
                }

                D.RecommandButton {
                    spacing: 10
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    Layout.bottomMargin: 0
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    Layout.fillWidth: true
                    text: qsTr("Next")
                    enabled: agreeCheckbox.checked
                    onClicked: {
                        dccData.biometricCtl.startFaceEnroll();
                        listview.incrementCurrentIndex()
                    }
                }
            }

            ColumnLayout {
                height: ListView.view.implicitHeight
                width: ListView.view.implicitWidth

                Label {
                    text: dialog.title
                    font.bold: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                }

                Item {
                    id: facePreviewItem
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 250

                    D.DciIcon {
                        id: faceImg
                        anchors.centerIn: parent
                        name: ""
                        sourceSize: Qt.size(210, 210)
                    }

                    Timer {
                        repeat: true
                        running: true
                        interval: 50
                        onTriggered: {
                            loaderControl.rotation = loaderControl.rotation + 360 / 49
                        }
                    }

                    Control {
                        id: loaderControl
                        contentItem: D.DciIcon {
                            id: shortProgressCircle
                            anchors.fill: parent
                            sourceSize: Qt.size(250, 250)
                            name: "scan_loader"
                            palette: D.DTK.makeIconPalette(loaderControl.palette)
                        }
                    }
                    
                }

                Label {
                    id: enrollResultLabel
                    visible: false
                    Layout.alignment: Qt.AlignCenter
                    text: dccData.biometricCtl.enrollFaceSuccess ? qsTr("Face enrolled") : qsTr("Failed to enroll your face")
                }

                Text {
                    id: tips
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    font: D.DTK.fontManager.t8
                    wrapMode: Text.WordWrap
                    text: dccData.biometricCtl.enrollFaceTips
                    horizontalAlignment: Text.AlignHCenter
                }

                Item {
                    Layout.minimumHeight: 60
                    Layout.fillHeight: true
                }

                RowLayout {
                    id: successBtnLayout
                    visible: false
                    spacing: 10
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    Layout.bottomMargin: 10
                    Layout.leftMargin: 10
                    Layout.rightMargin: 20

                    Button {
                        Layout.fillWidth: true
                        text: qsTr("Done")
                        onClicked: {
                            dccData.biometricCtl.stopFaceEnroll()
                            close()
                        }
                    }
                }

                RowLayout {
                    id: failedBtnLayout
                    visible: false
                    spacing: 10
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    Layout.bottomMargin: 10
                    Layout.leftMargin: 10
                    Layout.rightMargin: 20

                    Button {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        onClicked: {
                            close();
                        }
                    }
                    D.RecommandButton {
                        Layout.fillWidth: true
                        text: qsTr("Retry Enroll")
                        onClicked: {
                            dccData.biometricCtl.startFaceEnroll();
                            successBtnLayout.visible = false;
                            failedBtnLayout.visible = false;
                            enrollResultLabel.visible = false;
                            shortProgressCircle.visible = true;
                            faceImg.name = "";
                        }
                    }
                }

                Connections {
                    target: dccData.biometricCtl
                    function onEnrollCompleted() {
                        console.log("onEnrollCompleted called");
                        faceImg.name = dccData.biometricCtl.enrollFaceSuccess ? "user_biometric_face_success" : "user_biometric_face_lose";
                        if (dccData.biometricCtl.enrollFaceSuccess) {
                            successBtnLayout.visible = true;
                            failedBtnLayout.visible = false;
                        } else {
                            successBtnLayout.visible = false;
                            failedBtnLayout.visible = true;
                        }

                        enrollResultLabel.visible = true;
                        shortProgressCircle.visible = false;
                    }
                    function onFaceImgContentChanged() {
                        faceImg.name = dccData.biometricCtl.faceImgContent;
                    }
                }
            }
        }

    }
}
