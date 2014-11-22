import QtQuick 2.0
import SialanTools 1.0
import Sigram 1.0
import SigramTypes 1.0

Item {
    id: ac_list
    width: 100
    height: 62

    property alias telegram: cmodel.telegram
    property alias selecteds: list.list

    signal selected(variant cid)

    ContactsModel {
        id: cmodel
        onInitializingChanged: {
            if( initializing )
                indicator.start()
            else
                indicator.stop()
        }
    }

    ListObject {
        id: list
    }

    ListView {
        id: clist
        anchors.fill: parent
        clip: true
        model: cmodel
        spacing: 4*physicalPlatformScale
        delegate: Item {
            width: clist.width
            height: 50*physicalPlatformScale

            property Contact citem: item
            property User user: telegram.user(citem.userId)

            property bool itemSelected: list.contains(citem.userId)

            Rectangle {
                anchors.fill: parent
                color: itemSelected || area.pressed? masterPalette.highlight : "#00000000"
                opacity: 0.5
            }

            Image {
                id: profile_img
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 4*physicalPlatformScale
                width: height
                sourceSize: Qt.size(width,height)
                source: imgPath.length==0? "files/user.png" : imgPath
                asynchronous: true

                property string imgPath: user.photo.photoSmall.download.location
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: profile_img.right
                anchors.right: parent.right
                anchors.margins: 4*physicalPlatformScale
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
                font.family: SApp.globalFontFamily
                font.pixelSize: 9*fontsScale
                text: user.firstName + " " + user.lastName
                color: "#333333"
            }

            MouseArea {
                id: area
                anchors.fill: parent
                onClicked: {
                    var uid = citem.userId
                    if( list.contains(uid) )
                        list.removeOne(uid)
                    else
                        list.append(uid)

                    itemSelected = !itemSelected
                    ac_list.selected(uid)
                }
            }
        }
    }

    NormalWheelScroll {
        flick: clist
    }

    PhysicalScrollBar {
        scrollArea: clist; height: clist.height; width: 6*physicalPlatformScale
        anchors.right: clist.right; anchors.top: clist.top; color: textColor0
    }

    Indicator {
        id: indicator
        anchors.centerIn: parent
        light: false
        modern: true
        indicatorSize: 20*physicalPlatformScale
    }
}
