/*-****************************************************************************

 * Copyright (C) 2022 Tiago Barroso - <tiago.barroso@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

/* Constants imports */
import "../scripts/Constants.js" as Constants
import "../scripts/Functions.js" as Functions
import "../components/" as Components
//Import C++ defined enums
import eidguiV2 1.0

Item {

    id: menuContainer
    parent: mainWindow.contentItem
    anchors.fill: parent

    property bool reload: false
    property bool hasMandatory: hasMandatoryItem(model_recent)
    property alias popupTitle: title
	signal popupClosed

    Popup {
        id: notificationMenuPopup
        width: 650
        height: 450
        modal: true
        anchors.centerIn: parent
        closePolicy: hasMandatory ? Popup.NoAutoClose : Popup.CloseOnEscape
		onClosed: menuContainer.popupClosed()

        ListModel {
            id: model_recent
        }

        ListModel {
            id: model_read
        }
    
        Component {
            id: delegate

            Rectangle {
                id: notification_box
                width: parent.width
                height: visible ? (model.activated ? add_up_heights() : Constants.SIZE_IMAGE_BOTTOM_MENU * 2) : 0
                color: activeFocus ? Constants.COLOR_MAIN_MIDDLE_GRAY : Constants.COLOR_MAIN_SOFT_GRAY
                visible: !hasMandatory || model.mandatory
                clip: true

                function add_up_heights() {
                    return news.height + update.height + definitions_cmd.height
                        + definitions_cache.height + definitions_telemetry.height
                }

                Rectangle {
                    id: selected_part
                    width: 4
                    height: notification_box.height
                    color: model.read ? Constants.COLOR_GRAY : Constants.COLOR_MAIN_BLUE

                    anchors.left: parent.left
                }

                Image {
                    id: icon
                    width: Constants.SIZE_IMAGE_BOTTOM_MENU 
                    height: Constants.SIZE_IMAGE_BOTTOM_MENU 
                    fillMode: Image.PreserveAspectFit
                    source: chooseIcon(model.category, model.read)

                    anchors.left: selected_part.right
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 10
                }
        
                Text {
                    id: type
                    text: chooseCategory(model.category)
                    maximumLineCount: 1
                    color: model.read ? Constants.COLOR_GRAY : Constants.COLOR_MAIN_BLUE

                    font.family: lato.name
                    font.pixelSize: 10
                    
                    anchors.left: icon.right
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 10
                }

                Text {
                    text: model.title
                    visible: !model.activated
                    width: parent.width - icon.width - 40
                    color: Constants.COLOR_TEXT_BODY
                    elide: Text.ElideRight
                    maximumLineCount: 1

                    font.family: lato.name
                    font.pixelSize: 14

                    anchors.left: icon.right
                    anchors.leftMargin: 10
                    anchors.top: type.bottom
                    anchors.topMargin: 5
                }   

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: openNotification(index, model.read, model.activated)
                } 

                Components.Notification {
                    id: news
                    height: visible ? title.height + description.height + rightButton.height + 75 : 0
                    visible: model.category === "news" && model.activated

                    title.text: model.title
                    description.text: model.text
                    propertyUrl: model.link
                }

                Components.Notification {
                    id: definitions_cache
                    height: visible ? title.height + description.height + activatedCache.height * 2 + rightButton.height + 75 : 0
                    visible: model.category === "definitions_cache" && model.activated

                    title.text: model.title
                    description.text: model.text

                    CheckBox {
                        id: activatedCache
                        text: qsTranslate("main","STR_SET_CACHE_YES")
                        checked: model.checkbox_value == 2
                        onClicked: deactivatedCache.checked = false

                        anchors.top: definitions_cache.description.bottom
                        anchors.topMargin: Constants.SIZE_ROW_V_SPACE 
                        anchors.left: parent.left
                        anchors.leftMargin: Constants.SIZE_IMAGE_BOTTOM_MENU + 2 * 10 

                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_LABEL_FOCUS
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus

                        Keys.enabled: true
                        Keys.onBacktabPressed: definitions_cache.description.forceActiveFocus()
                        Keys.onUpPressed: definitions_cache.description.forceActiveFocus()
                    }

                    CheckBox {
                        id: deactivatedCache
                        text: qsTranslate("main","STR_SET_CACHE_NO")
                        checked: model.checkbox_value == 1
                        onClicked: activatedCache.checked = false

                        anchors.top: activatedCache.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: Constants.SIZE_IMAGE_BOTTOM_MENU + 2 * 10 
                        anchors.right: parent.right
                        anchors.rightMargin: Constants.MARGIN_NOTIFICATION_CENTER

                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_LABEL_FOCUS
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus

                        Keys.enabled: true
                        Keys.onTabPressed: definitions_cache.rightButton.enabled ? definitions_cache.rightButton.forceActiveFocus() : activatedCache.forceActiveFocus()
                        Keys.onDownPressed: definitions_cache.rightButton.enabled ? definitions_cache.rightButton.forceActiveFocus() : activatedCache.forceActiveFocus()
                        Keys.onRightPressed: definitions_cache.rightButton.enabled ? definitions_cache.rightButton.forceActiveFocus() : activatedCache.forceActiveFocus()
                    }

                    rightButton {
                        text: qsTranslate("main","STR_SET_CACHE_PROCEED")
                        enabled: activatedCache.checked || deactivatedCache.checked
                        onClicked: setCacheSettings(index, model, activatedCache.checked)
                    }
                }

                Components.Notification {
                    id: definitions_telemetry
                    height: visible ? title.height + description.height + textItem.height + terms.height + activatedCache.height * 2 + rightButton.height + 75 : 0
                    visible: model.category === "definitions_telemetry" && model.activated

                    title.text: model.title
                    description.text: model.text

                    Image {
                        id: carot

                        anchors.left: parent.left
                        anchors.top: definitions_telemetry.description.bottom
                        anchors.leftMargin: Constants.SIZE_IMAGE_BOTTOM_MENU + 2 * 10 + 4
                        anchors.topMargin: Constants.SIZE_ROW_V_SPACE * 2

                        sourceSize.width: Constants.SIZE_IMAGE_ARROW_ACCORDION
                        sourceSize.height: Constants.SIZE_IMAGE_ARROW_ACCORDION
                        source: '../images/arrow-right_AMA.png'
                        transform: Rotation {
                            origin.x: Constants.SIZE_IMAGE_ARROW_ACCORDION * 0.5
                            origin.y: Constants.SIZE_IMAGE_ARROW_ACCORDION * 0.5
                            angle: terms.visible ? 90 : 0
                            Behavior on angle { NumberAnimation { duration: 150 } }
                        }

                        MouseArea {
                            id: carotMouseArea
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                var isHidden = terms.visible

                                terms.enabled = !isHidden
                                terms.visible = !isHidden

                                terms.height = isHidden ? 0 : terms.implicitHeight
                                terms.anchors.leftMargin = isHidden ? 0 : Constants.SIZE_IMAGE_BOTTOM_MENU + 2 * 10 + 4
                                terms.anchors.topMargin = isHidden ? 0 : Constants.SIZE_ROW_V_SPACE * 2
                            }
                        }
                    }

                    Text {
                        id: textItem
                        text: qsTranslate("main","STR_TELEMETRY_SHOW_TERMS")
                        font.italic: true
                        width: parent.width - Constants.SIZE_IMAGE_BOTTOM_MENU - 40
                        wrapMode: TextEdit.Wrap
                        color: Constants.COLOR_TEXT_BODY
                        horizontalAlignment: Text.AlignJustify
                        elide: Text.ElideRight

                        anchors.top: definitions_telemetry.description.bottom
                        anchors.topMargin: Constants.SIZE_ROW_V_SPACE * 2
                        anchors.left: carot.right
                        anchors.leftMargin: terms.visible ? 10 : Constants.SIZE_TEXT_FIELD * 0.5

                        font.pixelSize: Constants.SIZE_TEXT_LABEL_FOCUS
                        font.bold: activeFocus
                        font.family: lato.name

                        MouseArea {
                            id: mouseAreaText
                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                var isHidden = terms.visible

                                terms.enabled = !isHidden
                                terms.visible = !isHidden

                                terms.height = isHidden ? 0 : terms.implicitHeight
                                terms.anchors.leftMargin = isHidden ? 0 : Constants.SIZE_IMAGE_BOTTOM_MENU + 2 * 10 + 4
                                terms.anchors.topMargin = isHidden ? 0 : Constants.SIZE_ROW_V_SPACE * 2
                            }
                        }
                    }

                    Label {
                        id: terms
                        width: parent.width - Constants.SIZE_IMAGE_BOTTOM_MENU - 40
                        text: qsTranslate("main","STR_TELEMETRY_TERMS")
                        wrapMode: TextEdit.Wrap
                        color: Constants.COLOR_TEXT_BODY
                        lineHeight: 1.5
                        elide: Text.ElideRight
                        visible: false
                        height: 0

                        anchors.top: textItem.bottom
                        anchors.left: parent.left

                        font.pixelSize: Constants.SIZE_TEXT_LABEL_FOCUS
                        font.bold: activeFocus
                        font.family: lato.name

                        Keys.enabled: true
                        Keys.onTabPressed: { nextItemInFocusChain().forceActiveFocus() }
                        Keys.onDownPressed: { nextItemInFocusChain().forceActiveFocus() }
                        Keys.onRightPressed: { nextItemInFocusChain().forceActiveFocus() }
                        KeyNavigation.backtab: definitions_telemetry.title
                        KeyNavigation.up: definitions_telemetry.title
                    }

                    CheckBox {
                        id: activatedTelemetry
                        text: qsTranslate("main","STR_SET_TELEMETRY_YES")
                        checked: model.checkbox_value == 2
                        onClicked: deactivatedTelemetry.checked = false

                        anchors.top: terms.bottom
                        anchors.topMargin: Constants.SIZE_ROW_V_SPACE 
                        anchors.left: parent.left
                        anchors.leftMargin: Constants.SIZE_IMAGE_BOTTOM_MENU + 2 * 10 

                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_LABEL_FOCUS
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus

                        Keys.enabled: true
                        Keys.onBacktabPressed: definitions_telemetry.description.forceActiveFocus()
                        Keys.onUpPressed: definitions_telemetry.description.forceActiveFocus()
                    }

                    CheckBox {
                        id: deactivatedTelemetry
                        text: qsTranslate("main","STR_SET_TELEMETRY_NO")
                        checked: model.checkbox_value == 1
                        onClicked: activatedTelemetry.checked = false

                        anchors.top: activatedTelemetry.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: Constants.SIZE_IMAGE_BOTTOM_MENU + 2 * 10 

                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_LABEL_FOCUS
                        font.capitalization: Font.MixedCase
                        font.bold: activeFocus

                        Keys.enabled: true
                        Keys.onTabPressed: definitions_telemetry.rightButton.enabled ? definitions_telemetry.rightButton.forceActiveFocus() : activatedTelemetry.forceActiveFocus()
                        Keys.onDownPressed: definitions_telemetry.rightButton.enabled ? definitions_telemetry.rightButton.forceActiveFocus() : activatedTelemetry.forceActiveFocus()
                        Keys.onRightPressed: definitions_telemetry.rightButton.enabled ? definitions_telemetry.rightButton.forceActiveFocus() : activatedTelemetry.forceActiveFocus()
                    }

                    rightButton {
                        text: qsTranslate("main","STR_SET_TELEMETRY_PROCEED")
                        enabled: activatedTelemetry.checked || deactivatedTelemetry.checked
                        onClicked: setTelemetrySettings(index, model, activatedTelemetry.checked)
                    }
                }

                Components.Notification {
                    id: definitions_cmd
                    height: visible ? title.height + description.height + rightButton.height + 75 : 0
                    visible: model.category === "definitions_cmd" && model.activated
                    
                    title.text: model.title
                    description.text: model.text
                    propertyUrl: model.link

                    link {
                        propertyText.text: "<a href='" + definitions_cmd.propertyUrl + "'>" + qsTranslate("PageServicesSign","STR_SIGN_CMD_URL")
                    }

                    rightButton {
                        text: qsTranslate("PageDefinitionsApp","STR_REGISTER_CMD_CERT_BUTTON")
                        onClicked: setCmdSettings()
                    }
                }

                Components.Notification {
                    id: update
                    height: visible ? title.height + description.height + rightButton.height + 75 : 0
                    visible: model.category === "update" && model.activated

                    title.text: model.title
                    description.text: model.text

                    rightButton {
                        text: qsTranslate("main", "STR_UPDATE_INSTALL_BUTTON")
                        onClicked: goToUpdate(model.update_type, model.release_notes, model.installed_version, model.remote_version, model.url_list)
                    }
                }

                Keys.onSpacePressed: {
                    openNotification(index, model.read, model.activated)
                    if (model.activated) {
                        if (update.visible) update.forceActiveFocus()
                        else if (definitions_cmd.visible) definitions_cmd.forceActiveFocus()
                        else if (definitions_cache.visible) definitions_cache.forceActiveFocus()
                        else if (definitions_telemetry.visible) definitions_telemetry.forceActiveFocus()
                        else if (news.visible) news.forceActiveFocus()
                    } else {
                        if (!model.read && listView.count == 0) {
                            listView_read.forceActiveFocus()
                        } else {
                            notification_box.forceActiveFocus()
                        }
                    }
                }

                Keys.onTabPressed: focusForward();
                Keys.onDownPressed: focusForward();
                Keys.onBacktabPressed: focusBackward();
                Keys.onUpPressed: focusBackward();

                Accessible.role: Accessible.ListItem
                Accessible.name: qsTranslate("main", "STR_NOTIFICATION")
                Accessible.description: qsTranslate("main", "STR_SPACE_TO_OPEN_NOTIFICATION")

                function focusForward() {
                    if (!model.read) {
                        if (listView.currentIndex == listView.count - 1) {
                            listView.currentIndex = 0
                            read_notification_title.visible ? read_notification_title.forceActiveFocus() : popupTitle.forceActiveFocus()
                        } else {
                            listView.currentIndex++
                        }
                    } else {
                        if (listView_read.currentIndex == listView_read.count - 1) {
                            listView_read.currentIndex = 0
                            popupTitle.forceActiveFocus()
                        } else {
                            listView_read.currentIndex++
                        }
                    }
                }

                function focusBackward() {
                    if (!model.read) {
                        if (listView.currentIndex == 0) {
                            new_notification_title.forceActiveFocus()
                        } else {
                            listView.currentIndex--
                        }
                    } else {
                        if (listView_read.currentIndex == 0) {
                            read_notification_title.forceActiveFocus()
                        } else {
                            listView_read.currentIndex--
                        }
                    }
                }
            }
        }

        Label {
            id: title
            text: qsTranslate("main", "STR_NOTIFICATION_CENTER")
            elide: Label.ElideRight
            wrapMode: Text.WordWrap
            lineHeight: 1.2
            color: Constants.COLOR_MAIN_BLUE

            font.bold: activeFocus
            font.pixelSize: Constants.SIZE_TEXT_TITLE
            font.family: lato.name

            anchors.top: parent.top
            anchors.topMargin: Constants.MARGIN_NOTIFICATION_CENTER

            Keys.enabled: true
            KeyNavigation.tab: new_notification_title.visible ? new_notification_title : read_notification_title
            KeyNavigation.down: new_notification_title.visible ? new_notification_title : read_notification_title
            KeyNavigation.right: new_notification_title.visible ? new_notification_title : read_notification_title
            KeyNavigation.backtab: read_notification_title.visible ? read_notification_title : new_notification_title
            KeyNavigation.up: read_notification_title.visible ? read_notification_title : new_notification_title

            Accessible.role: Accessible.StaticText
            Accessible.name: text
        }

        Image {
            id: exitIcon
            visible: !hasMandatory
            width: Constants.SIZE_IMAGE_BOTTOM_MENU 
            height: Constants.SIZE_IMAGE_BOTTOM_MENU 
            fillMode: Image.PreserveAspectFit
            source: exitArea.containsMouse ?
                "../images/titleBar/quit_hover_blue.png" :
                "../images/titleBar/quit.png"

            anchors.top: title.top
            anchors.right: notificationArea.right

            Accessible.role: Accessible.Button
            Accessible.name: qsTranslate("main", "STR_CLOSE")
        }

        MouseArea {
            id: exitArea
            enabled: !hasMandatory
            anchors.fill: exitIcon
            hoverEnabled: true
            onClicked: close()
        } 

        Flickable {
            id: notificationArea
            width: parent.width
            height: parent.height - title.height - 30
            contentHeight: container_notif.height
            clip: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: title.bottom
            anchors.topMargin: Constants.MARGIN_NOTIFICATION_CENTER 

            ScrollBar.vertical: ScrollBar {
                id: viewScroll
                visible: notificationArea.height < notificationArea.contentHeight
                policy: ScrollBar.AsNeeded
            }

            Item {
                id: container_notif
                height: childrenRect.height
                width: parent.width

                Item {
                    id: container_new_notif
                    height: childrenRect.height
                    width: parent.width

                    visible: listView.model.count > 0

                    Text {
                        id: new_notification_title
                        text: qsTranslate("main", "STR_NOTIFICATION_RECENT")
                        visible: listView.model.count > 0
                        color: Constants.COLOR_GRAY

                        font.bold: activeFocus
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase

                        Keys.enabled: true
                        KeyNavigation.tab: listView
                        KeyNavigation.down: listView
                        KeyNavigation.right: listView

                        Accessible.role: Accessible.StaticText
                        Accessible.name: text
                    }

                    ListView {
                        id: listView
                        width: parent.width - Constants.MARGIN_NOTIFICATION_CENTER * 2
                        height: childrenRect.height
                        clip: true
                        model: model_recent
                        delegate: delegate
                        focus: true
                        spacing: 6
                        interactive: false

                        anchors.top: new_notification_title.bottom
                        anchors.topMargin: Constants.MARGIN_NOTIFICATION_CENTER / 2

                        Keys.forwardTo: delegate
                        onFocusChanged: currentIndex = 0
                    }
                }

                Item {
                    id: container_read_notif
                    height: container_read_notif.visible ? childrenRect.height : 0
                    width: parent.width

                    visible: !hasMandatory && model_read.count > 0

                    anchors.top: listView.model.count > 0 ? container_new_notif.bottom : parent.top
                    anchors.topMargin: visible && listView.model.count > 0 ? Constants.MARGIN_NOTIFICATION_CENTER * 2 : 0

                    Text {
                        id: read_notification_title
                        text: qsTranslate("main", "STR_NOTIFICATION_READ")
                        color: Constants.COLOR_GRAY

                        font.bold: activeFocus
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase

                        Keys.enabled: true
                        KeyNavigation.tab: listView_read
                        KeyNavigation.down: listView_read
                        KeyNavigation.right: listView_read
                        KeyNavigation.backtab: new_notification_title.visible ? new_notification_title : popupTitle
                        KeyNavigation.up: new_notification_title.visible ? new_notification_title : popupTitle

                        Accessible.role: Accessible.StaticText
                        Accessible.name: text
                    }

                    ListView {
                        id: listView_read
                        width: listView.width
                        height: childrenRect.height
                        clip: true
                        model: model_read
                        delegate: delegate
                        focus: true
                        spacing: 6
                        interactive: false

                        anchors.top: read_notification_title.bottom
                        anchors.topMargin: Constants.MARGIN_NOTIFICATION_CENTER / 2

                        Keys.forwardTo: delegate
                        onFocusChanged: currentIndex = 0
                    }
                }
            }
        }

        Text {
            id: no_notifications_message
            text: qsTranslate("main", "STR_NO_NOTIFICATIONS")
            color: Constants.COLOR_GRAY

            visible: model_read.count == 0 && listView.model.count == 0

            font.bold: activeFocus
            font.family: lato.name
            font.pixelSize: Constants.SIZE_TEXT_FIELD
            font.capitalization: Font.MixedCase

            anchors.centerIn: parent

            Accessible.role: Accessible.StaticText
            Accessible.name: text
        }

        onOpened: {
            console.log("Notification center opened")
            popupTitle.forceActiveFocus()
        }
    }

    function open() {
        notificationMenuPopup.open()
    }

    function close() {
        notificationMenuPopup.close()
    }

    function openNotification(id, read, activated) {

        var model = read ? model_read.get(id) : model_recent.get(id)
        
        if (model.mandatory) {
            return;
        }

        model.activated = !model.activated

        if (activated && !read) {
            model.read = true
            insertInModel(model.priority, model)
            listView.model.remove(id)
        }
        else {
            switch (model.category) {
                case "news":
                    controler.updateNewsLog(model.id)
                    break
                case "definitions_cmd":
                    controler.setAskToRegisterCmdCertValue(false)
                    break
                default:
            }
        }
    }

    function addAppNews(news_list) {
        for (var index in news_list) {
            insertInModel(0, {
                "id": news_list[index]["id"],
                "title": news_list[index]["title"],
                "text": news_list[index]["text"],
                "link": news_list[index]["link"],
                "read": news_list[index]["read"],
                "category": "news",
                "priority": 0,
                "checkbox_value": 0,
                "activated": false,
                "mandatory": false
            })

            if (!news_list[index]["read"] && !reload) {
                mainFormID.propertyNotificationMenu.open()
            }
        }
    }

    function addCmdSettings(read) {
        insertInModel(2, {
            "title": qsTranslate("PageDefinitionsApp","STR_REGISTER_CMD_CERT_TITLE"),
            "text": qsTranslate("DialogCMD", "STR_REGISTER_CMD_CERT_DESC"),
            "link": "https://www.autenticacao.gov.pt/cmd-pedido-chave",
            "category": "definitions_cmd",
            "read": read,
            "priority": 2,
            "checkbox_value": 0,
            "activated": false,
            "mandatory": false
        })

        if (!read && !reload) {
            mainFormID.propertyNotificationMenu.open()
        }
    }   

    function setCmdSettings() {
        mainFormID.propertyCmdDialog.open(GAPI.RegisterCert)  
    }   

    function addCacheSettings() {
        insertInModel(3, {
            "title": qsTranslate("main","STR_SET_CACHE_TITLE"),
            "text": qsTranslate("main","STR_SET_CACHE_TEXT") + "<br></br><br></br><b>" + qsTranslate("main","STR_SET_CACHE_TEXT_MANDATORY") + "</b>",
            "link": "",
            "category": "definitions_cache",
            "read": false,
            "priority": 3,
            "checkbox_value": 0,
            "activated": true,
            "mandatory": true
        })

        notificationArea.interactive = true
        mainFormID.propertyNotificationMenu.open()
    }

    function addTelemetrySettings() {
        insertInModel(4, {
            "title": qsTranslate("main","STR_SET_TELEMETRY_TITLE"),
            "text": qsTranslate("main","STR_SET_TELEMETRY_TEXT"),
            "link": "",
            "category": "definitions_telemetry",
            "read": false,
            "priority": 4,
            "checkbox_value": 0,
            "activated": true,
            "mandatory": true
        })

        notificationArea.interactive = true
        mainFormID.propertyNotificationMenu.open()
    }

    function setCacheSettings(index, model, activatedCache) {
        model.mandatory = false
        notificationArea.interactive = true
        //Save which checkbox is selected in the model
        var model_item = model_recent.get(index)
        model_item.checkbox_value = activatedCache ? 2 : 1

        openNotification(index, model.read, model.activated)
        controler.setAskToSetCacheValue(false)
        
        if (activatedCache) {
            controler.setEnablePteidCache(true);
        }
        else {
            controler.setEnablePteidCache(false);
            controler.flushCache();
        }
    }

    function setTelemetrySettings(index, model, activatedTelemetry) {
        model.mandatory = false
        notificationArea.interactive = true
        //Save which checkbox is selected in the model
        var model_item = model_recent.get(index)
        model_item.checkbox_value = activatedTelemetry ? 2 : 1

        openNotification(index, model.read, model.activated)
        controler.setAskToSetTelemetryValue(false)
        if(activatedTelemetry)
            gapi.enableTelemetry()
        gapi.updateTelemetry(GAPI.Startup)
    }

    function addUpdate(release_notes, installed_version, remote_version, url_list, type) {       
        var title = ""
        var text = ""

        if (type == 1) {
            title = qsTranslate("main", "STR_AUTOUPDATE_APP_TITLE")
            text = qsTranslate("PageDefinitionsUpdates", "STR_AUTOUPDATE_TEXT")
        }
        else {
            title = qsTranslate("main", "STR_AUTOUPDATE_CERT_TITLE")
            text = qsTranslate("PageDefinitionsUpdates", "STR_AUTOUPDATE_CERTS_TEXT")
        }
        
        insertInModel(1, {
            "title": title,
            "text": text + "<br><br>" 
                  + qsTranslate("PageDefinitionsUpdates", "STR_AUTOUPDATE_OPEN_TEXT")  + "<br><br>"
                  + qsTranslate("PageDefinitionsUpdates", "STR_DISABLE_AUTOUPDATE_INFO"),
            "link": "",
            "category": "update",
            "read": false,
            "release_notes": release_notes,
            "installed_version": installed_version,
            "remote_version": remote_version,
            "url_list": url_list,
            "update_type": type,
            "priority": 1,
            "activated": false,
            "mandatory": false
        })

        if (!reload) {
            mainFormID.propertyNotificationMenu.open()
        }
    }

    function goToUpdate(type, release_notes, installed_version, remote_version, certs_list) {

        if (controler.getAskToSetCacheValue()) {
            return 
        }

        mainMenuBottomPressed(0)
        mainFormID.propertyPageLoader.source = "../" + 
                mainFormID.propertyMainMenuBottomListView.model.get(0).subdata.get(5).url
        mainFormID.propertySubMenuListView.currentIndex = 5
        mainFormID.propertySubMenuListView.forceActiveFocus()
        mainFormID.propertyNotificationMenu.close() 
        console.log("Source" + mainFormID.propertyPageLoader.source)

        //re-emit signal for PageDefinitionsUpdatesForm
        if(type == GAPI.AutoUpdateApp){
            controler.signalAutoUpdateAvailable(GAPI.AutoUpdateApp,
                                                release_notes,
                                                installed_version,
                                                remote_version,
                                                "")
        }
        if(type == GAPI.AutoUpdateCerts){
            controler.signalAutoUpdateAvailable(GAPI.AutoUpdateCerts,
                                                "",
                                                "",
                                                "",
                                                certs_list)
        }
    }
    
    function insertInModel(priority, item) {
        var index = 0
        var model = item.read ? model_read : model_recent

        while (index < model.count && priority <= model.get(index).priority) {
            index++
        }

        if (index == model.count) {   
            model.append(item)
        }
        else {
            model.insert(index, item)
        }
    }

    function chooseIcon(category, read) {
        switch (category) {
            case "news":
                if (read)
                    return "../images/news_icon.png" 
                else  
                    return "../images/news_icon_selected.png"
            case "update":
                if (read)
                    return "../images/update_icon.png"
                else  
                    return "../images/update_icon_selected.png"
            case "definitions_cmd":
                if (read)
                    return "../images/services_icon.png"
                else  
                    return "../images/services_icon_selected.png"
            case "definitions_cache":
            case "definitions_telemetry":
                if (read)
                    return "../images/definitions_icon.png"
                else  
                    return "../images/definitions_icon_selected_notification.png"
            default:
                return null
        }
    }

    function chooseCategory(category) {
        switch (category) {
            case "news":
                return qsTranslate("main", "STR_NOTIFICATION_NEWS")
            case "update":
                return qsTranslate("main", "STR_NOTIFICATION_UPDATE")
            case "definitions_cmd":
                return qsTranslate("main", "STR_NOTIFICATION_SERVICES")
            case "definitions_cache":
            case "definitions_telemetry":
                return qsTranslate("main", "STR_NOTIFICATION_CONFIG")
            default:
                return null
        }
    }

    function hasMandatoryItem(model) {
        for (var i = 0; i < model.count; ++i) {
            if (model.get(i).mandatory) return true;
        }
        return false;
    }

    function clearModels() {
        reload = true
        while (model_recent.count > 0 && model_recent.get(0).priority > 0) {
            model_recent.remove(0)
        }
        while (model_read.count > 0 && model_read.get(0).priority > 0) {
            model_read.remove(0)
        }
    }
}

