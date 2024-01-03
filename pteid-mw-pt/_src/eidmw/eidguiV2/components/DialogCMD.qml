/*-****************************************************************************

 * Copyright (C) 2018-2019 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 * Copyright (C) 2018-2020 Adriano Campos - <adrianoribeirocampos@gmail.com>
 * Copyright (C) 2019 José Pinto - <jose.pinto@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

/* Constants imports */
import "../scripts/Constants.js" as Constants
import "../scripts/Functions.js" as Functions

//Import C++ defined enums
import eidguiV2 1.0

Item {
    property var dialogType;
    property bool signSingleFile: true;
    property bool enabledConnections: false
    
    /* #################################################################### *
     * #                             Signals                              # *
    /* #################################################################### */

    Connections {
        enabled: enabledConnections
        target: gapi

        onSignalValidateOtp: {
            console.log("Signal Validate OTP")
            dialogContent.state = Constants.DLG_STATE.VALIDATE_OTP;
            textFieldReturnCode.forceActiveFocus()
        }
        onSignalShowMessage: {
            open(GAPI.ShowMessage)
            showMessage(msg,urlLink)
        }
        onSignalOpenFile: {
            console.log("Signal Open File")
            dialogContent.state = Constants.DLG_STATE.OPEN_FILE;
            dialogContent.forceActiveFocus()
        }
        onSignalUpdateProgressBar: {
            console.log("CMD sign change --> update progress bar with value = " + value)
            progressBar.value = value
        }
        onSignalUpdateProgressStatus: {
            console.log("CMD sign change --> update progress status with text = " + statusMessage)
            open(GAPI.Progress)
            textMessageTop.text = statusMessage
            textMessageTop.forceActiveFocus()
        }
        onSignalShowLoadAttrButton: {
            console.log("Signal show load attributes button")
            dialogContent.state = Constants.DLG_STATE.LOAD_ATTRIBUTES;
        }
    }

    /* #################################################################### *
     * #                                UI                                # *
    /* #################################################################### */
    
    id: dialogContainer
    // This dialog can be instantiated anywhere but the parent will always
    // be the mainWindow so that the dialog is centered
    parent: mainWindow.contentItem
    anchors.fill: parent

    Dialog {
        id: cmdDialog
        width: 600
        height: 300
        font.family: lato.name
        // Center dialog in the main view
        x: parent.width * 0.5 - cmdDialog.width * 0.5
        y: parent.height * 0.5 - cmdDialog.height * 0.5
        modal: true
        closePolicy: Popup.CloseOnEscape
        z: Constants.DIALOG_CASCATE_MIDDLE

        header: Label {
            id: dialogTitle
            visible: true
            elide: Label.ElideRight
            text: qsTranslate("PageServicesSign","STR_SIGN_CMD")
            padding: 24
            bottomPadding: 0
            font.bold: dialogContent.activeFocus
            font.pixelSize: Constants.SIZE_TEXT_MAIN_MENU
            color: Constants.COLOR_MAIN_BLUE
            wrapMode: Text.WordWrap
            lineHeight: 1.2
        }
        contentItem: Item {
            property var next : linkCMD.visible ? linkCMD : labelCMDText.propertyText

            id: dialogContent
            height: parent.height
            Keys.enabled: true
            Keys.onPressed: {
                if(event.key===Qt.Key_Enter || event.key===Qt.Key_Return)
                {
                    confirmDlg()
                }
            }
            Accessible.role: Accessible.AlertMessage
            Accessible.name: qsTranslate("Popup Card","STR_SHOW_WINDOWS")
                             + dialogTitle.text + textMessageTop.text
            KeyNavigation.tab: next
            KeyNavigation.down: next
            KeyNavigation.right: next
            KeyNavigation.backtab: buttonConfirm.enabled ? buttonConfirm : buttonCancel
            KeyNavigation.up: buttonConfirm.enabled ? buttonConfirm : buttonCancel
            KeyNavigation.left: buttonConfirm.enabled ? buttonConfirm : buttonCancel

            Item {
                id: rectMessageTopLogin
                width: parent.width
                height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                Link {
                    id: linkCMD
                    width: parent.width
                    height: 25
                    visible: false
                    propertyText.text: "<a href='https://www.autenticacao.gov.pt/cmd-pedido-chave'>"
                            + qsTranslate("PageServicesSign","STR_SIGN_CMD_URL")
                    propertyText.font.italic: true
                    propertyText.verticalAlignment: Text.AlignVCenter
                    anchors.top: parent.top
                    propertyText.font.pixelSize: Constants.SIZE_TEXT_LINK_LABEL
                    propertyText.font.bold: activeFocus
                    propertyAccessibleText: qsTranslate("PageServicesSign","STR_SIGN_CMD_URL")
                    propertyLinkUrl: 'https://www.autenticacao.gov.pt/cmd-pedido-chave'
                    KeyNavigation.tab: comboBoxMobileNumber.visible ? comboBoxMobileNumber : labelCMDText.propertyText
                    KeyNavigation.down: comboBoxMobileNumber.visible ? comboBoxMobileNumber : labelCMDText.propertyText
                    KeyNavigation.right: comboBoxMobileNumber.visible ? comboBoxMobileNumber : labelCMDText.propertyText
                    KeyNavigation.backtab: dialogContent
                    KeyNavigation.up: dialogContent

                }
                ProgressBar {
                    id: progressBar
                    width: parent.width
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    to: 100
                    value: 0
                    indeterminate: false
                    visible: false
                    z:1
                }
                Text {
                    id: textMessageTop
                    anchors.top: linkCMD.visible ? linkCMD.bottom : progressBar.bottom
                    anchors.topMargin: linkCMD.visible ? Constants.SIZE_ROW_V_SPACE : 3
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                    font.family: lato.name
                    font.bold: ( activeFocus || labelCMDText.propertyText.activeFocus) ? true : false
                    color: Constants.COLOR_TEXT_LABEL
                    width: parent.width
                    wrapMode: Text.WordWrap

                }
                Item {
                    id: rectLabelCMDText
                    width: parent.width
                    anchors.top: textMessageTop.bottom
                    anchors.topMargin: Constants.SIZE_ROW_V_SPACE
                    Link {
                        id: labelCMDText
                        visible: false
                        width: parent.width
                        propertyText.font.pixelSize: Constants.SIZE_TEXT_LINK_LABEL
                        propertyText.color: Constants.COLOR_TEXT_LABEL
                        KeyNavigation.tab: checkboxDontAskAgain.visible ? checkboxDontAskAgain : (buttonCancel.visible ? buttonCancel : buttonConfirm)
                        KeyNavigation.down: checkboxDontAskAgain.visible ? checkboxDontAskAgain : (buttonCancel.visible ? buttonCancel : buttonConfirm)
                        KeyNavigation.right: checkboxDontAskAgain.visible ? checkboxDontAskAgain : (buttonCancel.visible ? buttonCancel : buttonConfirm)      
                        Keys.onEnterPressed: {
                            confirmDlg()
                        }
                        Keys.onReturnPressed: {
                            confirmDlg()
                        }
                    }
                }
            }
            Item {
                id: dataFieldsRect
                anchors.top: rectMessageTopLogin.bottom
                height: parent.height
                width: parent.width
                visible: true
                Item {
                    id: rectMobileNumber
                    width: parent.width
                    height: 50
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false
                    Text {
                        id: textMobileNumber
                        text: qsTranslate("PageServicesSign","STR_SIGN_CMD_MOVEL_NUM")
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Constants.SIZE_TEXT_LABEL
                        font.family: lato.name
                        font.bold: activeFocus
                        color: Constants.COLOR_TEXT_BODY
                        height: parent.height
                        width: parent.width * 0.3
                        anchors.bottom: parent.bottom
                    }
                    PhoneCountriesCodeListModel{id: phoneCountryCodeList}
                    ComboBox {
                        id: comboBoxMobileNumber
                        width: parent.width * 0.4
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        model: phoneCountryCodeList
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.capitalization: Font.MixedCase
                        visible: true
                        popup.z: Constants.DIALOG_CASCATE_MIDDLE
                        anchors.left: textMobileNumber.right
                        anchors.bottom: parent.bottom
                        Accessible.role: Accessible.ComboBox
                        Accessible.name: currentText
                        KeyNavigation.tab: textFieldMobileNumber
                        KeyNavigation.right: textFieldMobileNumber
                        KeyNavigation.backtab: linkCMD
                        KeyNavigation.left: linkCMD
                    }
                    TextField {
                        id: textFieldMobileNumber
                        width: parent.width * 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        font.italic: textFieldMobileNumber.text === "" ? true: false
                        placeholderText: qsTranslate("PageServicesSign","STR_SIGN_CMD_MOVEL_NUM_OP") + "?"
                        validator: RegExpValidator { regExp: /[0-9]+/ }
                        maximumLength: 15
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        clip: false
                        anchors.left: comboBoxMobileNumber.right
                        anchors.leftMargin:  parent.width * 0.05
                        anchors.bottom: parent.bottom
                        onEditingFinished: {
                            // CMD load backup mobile data
                            propertyPageLoader.propertyBackupMobileNumber = textFieldMobileNumber.text
                        }
                        Accessible.role: Accessible.EditableText
                        Accessible.name: textMessageTop.text + textMobileNumber.text
                        KeyNavigation.tab: textFieldPin
                        KeyNavigation.down: textFieldPin
                        KeyNavigation.right: textFieldPin
                        KeyNavigation.up: comboBoxMobileNumber
                    }
                }
                Item {
                    id: rectPin
                    width: parent.width
                    height: 50
                    anchors.top: rectMobileNumber.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false
                    Text {
                        id: textPin
                        text: qsTranslate("PageServicesSign","STR_SIGN_CMD_PIN")
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Constants.SIZE_TEXT_LABEL
                        font.family: lato.name
                        font.bold: activeFocus
                        color: Constants.COLOR_TEXT_BODY
                        height: parent.height
                        width: parent.width * 0.3
                        anchors.bottom: parent.bottom
                    }
                    TextField {
                        id: textFieldPin
                        width: parent.width * 0.7
                        anchors.verticalCenter: parent.verticalCenter
                        font.italic: textFieldPin.text === "" ? true: false
                        placeholderText: qsTranslate("PageServicesSign","STR_SIGN_CMD_PIN_OP") + "?"
                        validator: RegExpValidator { regExp: /[0-9]{4,8}/ }
                        echoMode : TextInput.Normal
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.bold: activeFocus
                        clip: false
                        anchors.left: textPin.right
                        anchors.bottom: parent.bottom
                        Accessible.role: Accessible.EditableText
                        Accessible.name: textPin.text
                        //KeyNavigation.backtab: textFieldMobileNumber
                        //KeyNavigation.up: textFieldMobileNumber
                        onFocusChanged: {
                            if (activeFocus) {
                                // reset PIN text when focus is gained
                                textFieldPin.text = ""
                                textFieldPin.echoMode = TextInput.Normal
                                accessibilityTimer.start()
                            }
                        }

                        Keys.onEnterPressed: {
                            confirmDlg()
                        }
                        Keys.onReturnPressed: {
                            confirmDlg()
                        }
                    }
                    /*
                      Workaround for the problem of the screen-reader not reading the name of the TextField
                      if its echoMode is set to 'Password':
                        set the initial echoMode to 'Normal'.
                        use a timer(delay) to let the screen-reader start reading the TextField's name,
                        then set the echoMode to 'Password' and force the update of the changed property.
                    */
                    Timer {
                        id: accessibilityTimer
                        interval: 100
                        repeat: false
                        running: false
                        onTriggered: {
                            textFieldPin.echoMode = TextInput.Password
                            controler.forceAccessibilityUpdate(textFieldPin)
                        }
                    }
                }
                Item {
                    id: rectReturnCode
                    width: parent.width
                    height: 50
                    anchors.top: parent.top
                    anchors.topMargin: 2 * Constants.SIZE_ROW_V_SPACE
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false
                    Text {
                        id: textReturnCode
                        text: qsTranslate("PageServicesSign","STR_SIGN_CMD_CODE") + ":"
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Constants.SIZE_TEXT_LABEL
                        font.family: lato.name
                        font.bold: activeFocus
                        color: Constants.COLOR_TEXT_BODY
                        height: parent.height
                        width: parent.width * 0.5
                        anchors.bottom: parent.bottom
                    }
                    TextField {
                        id: textFieldReturnCode
                        width: parent.width * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        font.italic: textFieldReturnCode.text === "" ? true: false
                        placeholderText: qsTranslate("PageServicesSign","STR_SIGN_CMD_CODE_OP") + "?"
                        validator: RegExpValidator { regExp: /^[0-9]{6}$/ }
                        font.family: lato.name
                        font.pixelSize: Constants.SIZE_TEXT_FIELD
                        font.bold: activeFocus
                        clip: false
                        anchors.left: textReturnCode.right
                        anchors.bottom: parent.bottom
                        Accessible.role: Accessible.EditableText
                        Accessible.name: textMessageTop.text + textReturnCode.text
                        Keys.onEnterPressed: {
                            confirmDlg()
                        }
                        Keys.onReturnPressed: {
                            confirmDlg()
                        }
                    }
                }
                Rectangle {
                    id: rectSendSMS
                    width: parent.width
                    height: textSendSMS.paintedHeight + cmdDialog.padding
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false
                    color: 'white'
                    
                    Text {
                        id: textSendSMS
                        width: parent.width
                        font.pixelSize: Constants.SIZE_TEXT_LABEL
                        font.family: lato.name
                        anchors.leftMargin: Constants.SIZE_ROW_H_SPACE
                        anchors.rightMargin: Constants.SIZE_ROW_H_SPACE
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTranslate("PageServicesSign","STR_SEND_SMS_DESC")
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignJustify
                    }
                }
            }
            ProgressBar {
                id: progressBarIndeterminate
                width: parent.width
                anchors.top: parent.verticalCenter
                anchors.topMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter
                to: 100
                value: 0
                indeterminate: true
                visible: false
                z:1
            }
            CheckBox {
                id: checkboxDontAskAgain
                text: qsTranslate("main","STR_DONT_ASK_AGAIN")
                height: 25
                visible: false
                font.family: lato.name
                font.pixelSize: Constants.SIZE_TEXT_FIELD
                font.capitalization: Font.MixedCase
                font.bold: activeFocus
                checked: !controler.getAskToRegisterCmdCertValue()
                anchors.top: parent.bottom
                anchors.topMargin: Constants.SIZE_ROW_V_SPACE
                Accessible.role: Accessible.CheckBox
                Accessible.name: text
                KeyNavigation.left: labelCMDText.propertyText
                KeyNavigation.backtab: labelCMDText.propertyText
                KeyNavigation.up: labelCMDText.propertyText
                onClicked: {
                    controler.setAskToRegisterCmdCertValue(!checkboxDontAskAgain.checked)
                }
            }

            states: [
                State {
                    name: Constants.DLG_STATE.REGISTER_FORM
                    PropertyChanges {target: linkCMD; visible: true}
                    PropertyChanges {target: rectMobileNumber; visible: true}
                    PropertyChanges {target: textFieldMobileNumber; visible: true; focus: true}
                    PropertyChanges {target: rectPin; visible: true}
                    PropertyChanges {target: textMessageTop; text: qsTranslate("PageServicesSign","STR_SIGN_INSERT_LOGIN")}
                    PropertyChanges {
                        target: dialogTitle
                        restoreEntryValues : false
                        text: qsTranslate("PageDefinitionsApp","STR_REGISTER_CMD_CERT_TITLE")
                    }
                    PropertyChanges {target: buttonCancel; prev: textFieldPin}
                    PropertyChanges {target: buttonConfirm; enabled: textFieldMobileNumber.acceptableInput && textFieldPin.acceptableInput}
                    PropertyChanges {target: dialogContent; next: linkCMD}
                },
                State {
                    name: Constants.DLG_STATE.PROGRESS
                    PropertyChanges {target: dataFieldsRect; visible: false}
                    PropertyChanges {target: buttonConfirm; visible: false}
                    PropertyChanges {target: progressBar; visible: true}
                    PropertyChanges {target: progressBarIndeterminate; visible: true}
                },
                State {
                    name: Constants.DLG_STATE.VALIDATE_OTP
                    PropertyChanges {target: progressBar; visible: true}
                    PropertyChanges {target: rectSendSMS; visible: true}
                    PropertyChanges {target: rectReturnCode; visible: true}
                    PropertyChanges {target: buttonCancel; prev: textFieldReturnCode}
                    PropertyChanges {target: dialogContent; next: textFieldReturnCode}
                    PropertyChanges {target: buttonConfirm; enabled: textFieldReturnCode.acceptableInput}
                    PropertyChanges {target: buttonSendSMS; enabled: true}
                },
                State {
                    name: Constants.DLG_STATE.LOAD_ATTRIBUTES
                    PropertyChanges {target: buttonConfirm; visible: true; }
                    PropertyChanges {target: buttonConfirm; text: qsTranslate("PageServicesSign","STR_LOAD_SCAP_ATTRIBUTES")}
                    PropertyChanges {target: progressBar; visible: true}
                    PropertyChanges {
                        target: labelCMDText;
                        visible: true;
                        propertyLinkUrl: ""
                        propertyText.text: qsTranslate("Popup File","STR_POPUP_LOAD_SCAP_ATTR");
                        propertyAccessibleText: qsTranslate("Popup File","STR_POPUP_LOAD_SCAP_ATTR");
                    }
                },
                State {
                    name: Constants.DLG_STATE.SHOW_MESSAGE
                    PropertyChanges {
                        target: labelCMDText; visible: true; 
                    }
                    PropertyChanges {target: buttonConfirm; visible: true; }
                    PropertyChanges {target: progressBar; visible: true}
                    PropertyChanges {target: progressBarIndeterminate; visible: false}
                },
                State {
                    name: Constants.DLG_STATE.OPEN_FILE
                    PropertyChanges {target: labelCMDText; visible: true; propertyLinkUrl: ""}
                    PropertyChanges {target: buttonConfirm; text: qsTranslate("Popup File","STR_POPUP_FILE_OPEN")}
                    PropertyChanges {target: buttonConfirm; visible: true}
                    PropertyChanges {target: progressBar; visible: true}
                    PropertyChanges {
                        target: labelCMDText
                        visible: true
                        propertyText.text: signSingleFile ? qsTranslate("PageServicesSign","STR_SIGN_OPEN") :
                                               qsTranslate("PageServicesSign","STR_SIGN_OPEN_MULTI")
                        propertyAccessibleText: signSingleFile ? qsTranslate("PageServicesSign","STR_SIGN_OPEN") :
                                               qsTranslate("PageServicesSign","STR_SIGN_OPEN_MULTI")
                    }
                },
                State {
                    name: Constants.DLG_STATE.OPEN_FILE_ERROR
                    PropertyChanges {target: progressBar; visible: true}
                    PropertyChanges {target: progressBarIndeterminate; visible: false}
                    PropertyChanges {target: buttonCancel; visible: false}
                    PropertyChanges {target: buttonConfirm; visible: true}
                    PropertyChanges {target: buttonConfirm; text: qsTranslate("PageServicesSign","STR_CMD_POPUP_CONFIRM")}
                    PropertyChanges {
                        target: dialogTitle
                        restoreEntryValues : false
                        text: signSingleFile ? qsTranslate("PageServicesSign","STR_SIGN_OPEN_ERROR_TITLE") :
                                               qsTranslate("PageServicesSign","STR_SIGN_OPEN_ERROR_TITLE_MULTI")
                    }
                    PropertyChanges {
                        target: labelCMDText;
                        visible: true;
                        propertyLinkUrl: ""
                        propertyText.text: signSingleFile ? qsTranslate("PageServicesSign","STR_SIGN_OPEN_ERROR") :
                                               qsTranslate("PageServicesSign","STR_SIGN_OPEN_ERROR_MULTI")
                        propertyAccessibleText: signSingleFile ? qsTranslate("PageServicesSign","STR_SIGN_OPEN_ERROR") :
                                               qsTranslate("PageServicesSign","STR_SIGN_OPEN_ERROR_MULTI")
                    }
                }
            ]
        }

        footer: Rectangle {
            id: bottomRow
            height: Constants.HEIGHT_BOTTOM_COMPONENT + Constants.SIZE_ROW_V_SPACE
            
            Button {
                property var prev: checkboxDontAskAgain
                id: buttonCancel
                width: Constants.WIDTH_BUTTON
                height: Constants.HEIGHT_BOTTOM_COMPONENT
                text: qsTranslate("PageServicesSign","STR_CMD_POPUP_CANCEL")
                visible: dialogContent.state != Constants.DLG_STATE.SHOW_MESSAGE
                anchors.left: parent.left
                anchors.leftMargin: cmdDialog.padding
                font.pixelSize: Constants.SIZE_TEXT_FIELD
                font.family: lato.name
                font.capitalization: Font.MixedCase
                highlighted: activeFocus
                onClicked: {
                    dialogContainer.close()
                }
                Keys.onEnterPressed: clicked()
                Keys.onReturnPressed: clicked()
                Accessible.role: Accessible.Button
                Accessible.name: text
                KeyNavigation.tab: buttonSendSMS
                KeyNavigation.down: buttonSendSMS
                KeyNavigation.right: buttonSendSMS
                KeyNavigation.backtab: prev
                KeyNavigation.up: prev
                KeyNavigation.left: prev
            }
            Button {
                id: buttonSendSMS
                visible: rectSendSMS.visible
                width: Constants.WIDTH_BUTTON
                height: Constants.HEIGHT_BOTTOM_COMPONENT
                text: qsTranslate("main","STR_SEND_BY_SMS_BUTTON")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Constants.SIZE_TEXT_FIELD
                font.family: lato.name
                font.capitalization: Font.MixedCase
                highlighted: activeFocus
                onClicked: {
                    buttonSendSMS.enabled = false
                    textFieldReturnCode.forceActiveFocus()
                    gapi.sendSmsCmd(dialogType)
                }
                Keys.onEnterPressed: clicked()
                Keys.onReturnPressed: clicked()
                Accessible.role: Accessible.Button
                Accessible.name: text
                KeyNavigation.tab: buttonConfirm
                KeyNavigation.down: buttonConfirm
                KeyNavigation.right: buttonConfirm
                KeyNavigation.backtab: buttonCancel
                KeyNavigation.up: buttonCancel
                KeyNavigation.left: buttonCancel
            }
            Button {
                id: buttonConfirm
                width: Constants.WIDTH_BUTTON
                height: Constants.HEIGHT_BOTTOM_COMPONENT
                text: qsTranslate("PageServicesSign","STR_CMD_POPUP_CONFIRM")
                anchors.right: parent.right
                anchors.rightMargin: cmdDialog.padding
                font.pixelSize: Constants.SIZE_TEXT_FIELD
                font.family: lato.name
                font.capitalization: Font.MixedCase
                highlighted: activeFocus
                onClicked: {
                    confirmDlg()
                }
                Keys.onEnterPressed: clicked()
                Keys.onReturnPressed: clicked()
                Accessible.role: Accessible.Button
                Accessible.name: text
                KeyNavigation.backtab: buttonSendSMS
                KeyNavigation.up: buttonSendSMS
                KeyNavigation.left: buttonSendSMS
            }
        }

		onOpened: {
			if (dialogContent.state == Constants.DLG_STATE.REGISTER_FORM)
				textFieldMobileNumber.forceActiveFocus();
			else
				dialogContent.forceActiveFocus()
		}
        onRejected: {
            dialogContainer.close()
        }
    }

    /* #################################################################### *
     * #                            Functions                             # *
    /* #################################################################### */

    /* ############## Dialog ############## */
     function isVisible(){
         return cmdDialog.visible
     }

    function enableConnections(){
        enabledConnections = true
    }

    function isSignSingleFile(){
        return signSingleFile
    }

    function setSignSingleFile(singleFile){
        signSingleFile = singleFile
    }

    function open(type) {
        dialogType = type
        mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS

        if (type == GAPI.RegisterCert) {
            dialogContent.state = Constants.DLG_STATE.REGISTER_FORM
        }
        else if (type == GAPI.ShowMessage) {
            dialogContent.state = Constants.DLG_STATE.SHOW_MESSAGE
        }
        else if (type == GAPI.Progress) {
            dialogContent.state = Constants.DLG_STATE.PROGRESS
        }

        else {
            console.log("Error: invalid cmd dialog type: " + type)
            dialogContent.state = Constants.DLG_STATE.SHOW_MESSAGE
            labelCMDText.propertyText.text = qsTranslate("GAPI", "STR_POPUP_ERROR")
        }

        cmdDialog.open()
    }

    function confirmDlg() {
        if (!buttonConfirm.enabled)
            return;
        
        switch(dialogContent.state){
            case Constants.DLG_STATE.REGISTER_FORM:
                registerCMDCertOpen();
                break;
            case Constants.DLG_STATE.VALIDATE_OTP:
                registerCMDCertClose()
                break;
            case Constants.DLG_STATE.LOAD_ATTRIBUTES:
                loadSCAPAttributes()
                break;
            case Constants.DLG_STATE.SHOW_MESSAGE:
                close()
                break;
            case Constants.DLG_STATE.OPEN_FILE:
                openSignedFiles()
                break;
            case Constants.DLG_STATE.OPEN_FILE_ERROR:
                close()
                break;
        }
    }

    function close() {
        clearInputFields()
        cmdDialog.close()
        mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
        mainFormID.propertyPageLoader.forceActiveFocus()
        if(dialogContent.state == Constants.DLG_STATE.PROGRESS && dialogType == GAPI.RegisterCert) {
            gapi.cancelCMDRegisterCert()
        }
        enabledConnections = false
    }

    function clearInputFields() {
        textFieldPin.text = ""
        textFieldReturnCode.text = ""
    }
    /* ############## Register Certificate ############## */

    function registerCMDCertOpen() {
        enabledConnections = true
        dialogContent.state = Constants.DLG_STATE.PROGRESS

        var countryCode = comboBoxMobileNumber.currentText.substring(0, comboBoxMobileNumber.currentText.indexOf(' '));
        var mobileNumber = countryCode + " " + textFieldMobileNumber.text
        var pin = textFieldPin.text
        gapi.registerCMDCertOpen(mobileNumber, pin)
    }

    function registerCMDCertClose() {
        dialogContent.state = Constants.DLG_STATE.PROGRESS

        var otp = textFieldReturnCode.text
        gapi.registerCMDCertClose(otp)
    }

    /* ############## Signature  ############## */

    function openSignedFiles() {
        if (Functions.openSignedFiles() == true){
                close()
            } else {
                dialogContent.state = Constants.DLG_STATE.OPEN_FILE_ERROR
                labelCMDText.propertyText.forceActiveFocus()
            }
    }
    function loadSCAPAttributes(){
        close()
        gapi.startRemovingAttributesFromCache(GAPI.ScapAttrAll)
        jumpToDefinitionsSCAP()
    }
    
    function showMessage(msg,urlLink){
        console.log("Show Message: " + msg)
        dialogContent.state = Constants.DLG_STATE.SHOW_MESSAGE;
        labelCMDText.propertyText.text = msg
        labelCMDText.propertyAccessibleText = textMessageTop.text + Functions.filterText(msg)
        labelCMDText.propertyLinkUrl = urlLink
        labelCMDText.propertyText.forceActiveFocus()
    }
}
