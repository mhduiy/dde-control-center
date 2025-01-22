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
import org.deepin.dcc.account.biometric 1.0

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
    title: qsTr("Enroll Finger")

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
        highlightMoveDuration: 0
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
                    name: "user_biometric_fingerprint_add"
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
                    text: qsTr("将要录入的手指放入指纹传感器里面并从下往上移动手指，完成动作后请抬起你的手指")
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
                            listview.currentIndex = 2
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
                        dccData.biometricCtl.requestStartFingerEnroll();
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
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 200

                    D.DciIcon {
                        id: loaderIcon
                        anchors.centerIn: parent
                        name: dccData.biometricCtl.fingertipImagePath
                        retainWhileLoading: true
                        sourceSize: Qt.size(100, 100)
                    }
                }

                Label {
                    Layout.fillWidth: true
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    text: dccData.biometricCtl.fingerTitleTip
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    text: dccData.biometricCtl.fingerMsgTip
                }


                Item {
                    Layout.minimumHeight: 60
                    Layout.fillHeight: true
                }

                RowLayout {
                    id: successBtnLayout
                    visible: dccData.biometricCtl.addStage === CharaMangerModel.Success
                    spacing: 10
                    Layout.bottomMargin: 5
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5

                    Button {
                        Layout.fillWidth: true
                        text: qsTr("Done")
                        onClicked: {
                            dialog.close()
                        }
                    }
                }

                RowLayout {
                    id: failedBtnLayout
                    visible: dccData.biometricCtl.addStage === CharaMangerModel.Fail
                    spacing: 10
                    Layout.bottomMargin: 5
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5

                    Button {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        onClicked: {
                            dccData.biometricCtl.requestStopFingerEnroll()
                            dialog.close()
                        }
                    }
                    D.RecommandButton {
                        Layout.fillWidth: true
                        text: qsTr("Retry Enroll")
                        onClicked: {
                            listview.currentIndex = 0
                        }
                    }
                }

                RowLayout {
                    id: processBtnLayout
                    visible: dccData.biometricCtl.addStage === CharaMangerModel.Processing
                    spacing: 10
                    Layout.bottomMargin: 5
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5

                    Button {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        onClicked: {
                            dccData.biometricCtl.requestStopFingerEnroll()
                            dialog.close()
                        }
                    }
                }
            }

            ColumnLayout {
                height: ListView.view.implicitHeight
                width: ListView.view.implicitWidth
                spacing: 5

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "用户免责说明"
                    font.bold: true
                }

                ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    D.Label {
                        width: scrollView.availableWidth
                        wrapMode: Text.WordWrap
                        text:`使用人脸识别功能前，请注意以下事项：
1.您的电脑可能会被容貌、外形与您相近的人或物品解锁。
2.人脸识别的安全性低于数字密码、混合密码。
3.在暗光、强光、逆光或角度过大等场景下，人脸识别的解锁成功率会有所降低。
4.请务将设备随意交给他人使用，避免人脸识别功能被恶意利用。
5.除以上场景外，您需注意其他可能影响人脸识别功能正常使用的情况。
为更好使用人脸识别，录入面部数据时请注意以下事项：
1.请保证光线充足，避免阳光直射并避免其他人出现在录入的画面中。
2.请注意录入数据时的面部状态，避免衣帽、头发、墨镜、口罩、浓妆等遮挡面部信息。
3.请避免仰头、低头、闭眼或仅露出侧脸的情况，确保脸部正面清晰完整的出现在提示框内。
若您同意本声明并录入面部数据（面部数据将在您对设备本地加密保存），系统将会开启人脸识别功能。您可前往“登录选项”>"人脸识别"，删除录入的人脸数据。`
                    }
                }


                RowLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5

                    Button {
                        Layout.fillWidth: true
                        text: qsTr("取消")
                        onClicked: {
                            listview.currentIndex = 0
                            agreeCheckbox.checked = false
                        }
                    }
                    D.RecommandButton {
                        Layout.fillWidth: true
                        text: qsTr("同意")
                        onClicked: {
                            listview.currentIndex = 0
                            agreeCheckbox.checked = true
                        }
                    }
                }
            }
        }
        Connections {
            target: dccData.biometricCtl.model
            function onEnrollResult(res) {
                switch(res) {
                    case CharaMangerModel.Enroll_Success:
                        listview.currentIndex = 1
                }
            }
        }
    }
}
