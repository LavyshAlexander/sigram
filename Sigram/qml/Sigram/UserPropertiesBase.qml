import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Item {
    id: up_base
    height: row.height + 2*frameMargins

    property Dialog currentDialog
    property bool isChat: currentDialog.peer.chatId != 0
    property User user: telegramObject.user(currentDialog.peer.userId)
    property Chat chat: telegramObject.chat(currentDialog.peer.chatId)
    property variant dId: isChat? currentDialog.peer.chatId : currentDialog.peer.userId

    property bool signalBlocker: false
    property real frameMargins: 8*physicalPlatformScale

    property bool particianMode: false

    onParticianModeChanged: {
        if( particianMode )
            BackHandler.pushHandler(particians_frame, particians_frame.back)
        else
            BackHandler.removeHandler(particians_frame)
    }

    onDIdChanged: {
        if( dId == 0 )
            return
        if( signalBlocker )
            return

        signalBlocker = true
        favorite_check.checked = telegramObject.userData.isFavorited(dId)
        mute_check.checked = telegramObject.userData.isMuted(dId)
        love_check.checked = (telegramObject.userData.value("love")==dId)
        signalBlocker = false
    }

    onChatChanged: {
        if(chat==telegramObject.nullChat)
            return

        telegramObject.getFile(chat.photo.photoBig)
    }

    onUserChanged: {
        if(user==telegram.nullUserg)
            return

        telegramObject.getFile(user.photo.photoBig)
    }

    Connections {
        target: telegramObject.userData
        onFavoriteChanged: {
            if( id != dId )
                return

            favorite_check.checked = telegramObject.userData.isFavorited(dId)
        }
        onMuteChanged: {
            if( id != dId )
                return

            mute_check.checked = telegramObject.userData.isMuted(dId)
        }
        onValueChanged: {
            if( key != "love" )
                return

            love_check.checked = (telegramObject.userData.value("love")==dId)
        }
    }

    Item {
        id: particians_frame
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: frameMargins
        anchors.left: row.right
        visible: isChat

        Button {
            id: pback_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 30*physicalPlatformScale
            icon: "files/back.png"
            iconHeight: 22*physicalPlatformScale
            onClicked: BackHandler.back()
        }

        UserPropertiesChatParticipants {
            id: participants
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: pback_btn.right
            anchors.right: parent.right
            currentDialog: up_base.currentDialog
        }

        function back() {
            particianMode = false
        }
    }

    Row {
        id: row
        width: parent.width
        x: particianMode? -width : 0
        anchors.top: parent.top
        anchors.margins: frameMargins
        spacing: 8*physicalPlatformScale

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Image {
            width: 192*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            smooth: true
            asynchronous: true
            source: {
                var res = ""
                if( isChat ) {
                    res = chat.photo.photoBig.download.location
                    if( res.length == 0 ) {
                        res = chat.photo.photoSmall.download.location
                    }
                } else {
                    res = user.photo.photoBig.download.location
                    if( res.length == 0 ) {
                        res = user.photo.photoSmall.download.location
                    }
                }

                if( res.length == 0 )
                    res = "files/user.png"

                return res
            }
        }

        Item { width: 20*physicalPlatformScale; height: 1 }

        Column {
            id: col1
            anchors.top: parent.top
            anchors.margins: 20*physicalPlatformScale

            Text {
                id: phone_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Phone Number")
                visible: !isChat
            }

            Text {
                id: favorite_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Favorite")
            }

            Text {
                id: love_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Love")
            }

            Text {
                id: mute_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Mute")
            }

            Text {
                id: participants_lbl
                font.family: SApp.globalFontFamily
                font.pixelSize: 13*fontsScale
                color: masterPalette.highlight
                text: qsTr("Participants")
                visible: isChat
            }
        }

        Column {
            id: col2
            anchors.top: parent.top
            anchors.margins: 20*physicalPlatformScale

            Text {
                height: phone_lbl.height
                font.family: SApp.globalFontFamily
                font.pixelSize: 11*fontsScale
                verticalAlignment: Text.AlignVCenter
                color: "#333333"
                text: user.phone
                visible: !isChat
            }

            Item {
                height: favorite_lbl.height
                width: favorite_check.width

                CheckBox {
                    id: favorite_check
                    height: 20*physicalPlatformScale
                    width: 30*physicalPlatformScale
                    color: checked? masterPalette.highlight : "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    labels: false
                    onCheckedChanged: {
                        if( signalBlocker )
                            return
                        if( checked )
                            telegramObject.userData.addFavorite(dId)
                        else
                            telegramObject.userData.removeFavorite(dId)
                    }
                }
            }

            Item {
                height: love_lbl.height
                width: love_check.width

                CheckBox {
                    id: love_check
                    height: 20*physicalPlatformScale
                    width: 30*physicalPlatformScale
                    color: checked? masterPalette.highlight : "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    labels: false
                    onCheckedChanged: {
                        if( signalBlocker )
                            return
                        telegramObject.userData.setValue("love", checked?dId:"")
                    }
                }
            }

            Item {
                height: mute_lbl.height
                width: mute_check.width

                CheckBox {
                    id: mute_check
                    height: 20*physicalPlatformScale
                    width: 30*physicalPlatformScale
                    color: checked? masterPalette.highlight : "#333333"
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    labels: false
                    onCheckedChanged: {
                        if( signalBlocker )
                            return
                        if( checked )
                            telegramObject.userData.addMute(dId)
                        else
                            telegramObject.userData.removeMute(dId)
                    }
                }
            }

            Item {
                height: participants_lbl.height
                width: particians_button.width
                visible: isChat

                Button {
                    id: particians_button
                    anchors.verticalCenter: parent.verticalCenter
                    textColor: press? masterPalette.highlightedText : masterPalette.highlight
                    textFont.family: SApp.globalFontFamily
                    textFont.pixelSize: 11*fontsScale
                    textFont.bold: false
                    text: qsTr("Show List")
                    onClicked: particianMode = true
                }
            }
        }
    }
}
