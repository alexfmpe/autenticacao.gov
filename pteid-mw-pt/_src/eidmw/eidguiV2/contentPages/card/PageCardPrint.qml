/*-****************************************************************************

 * Copyright (C) 2017-2019 Adriano Campos - <adrianoribeirocampos@gmail.com>
 * Copyright (C) 2017 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2018-2019 Miguel Figueira - <miguelblcfigueira@gmail.com>
 * Copyright (C) 2018-2019 Veniamin Craciun - <veniamin.craciun@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.6
import QtQuick.Controls 2.1

import "../../scripts/Constants.js" as Constants
import "../../scripts/Functions.js" as Functions
import "../../components" as Components

//Import C++ defined enums
import eidguiV2 1.0

PageCardPrintForm {

    property string outputFile : ""

    Keys.onPressed: {
        console.log("PageCardPrintForm onPressed:" + event.key)
        Functions.detectBackKeys(event.key, Constants.MenuState.SUB_MENU)
    }
    Components.DialogCMD{
        id: dialogSignCMD
    }
    Dialog {
        id: createsuccess_dialog
        width: 400
        height: 200
        visible: false
        font.family: lato.name
        // Center dialog in the main view
        x: - mainMenuView.width - subMenuView.width
           + mainView.width * 0.5 - createsuccess_dialog.width * 0.5
        y: parent.height * 0.5 - createsuccess_dialog.height * 0.5

        header: Label {
            id: createdSuccTitle
            text: qsTr("STR_CREATE_SUCESS")
            elide: Label.ElideRight
            padding: 24
            bottomPadding: 0
            font.bold: activeFocus
            font.pixelSize: Constants.SIZE_TEXT_MAIN_MENU
            color: Constants.COLOR_MAIN_BLUE
            KeyNavigation.tab: openFileText
            KeyNavigation.right: openFileText
            KeyNavigation.down: openFileText
        }

        Item {
            width: createsuccess_dialog.availableWidth
            height: 50

            Keys.enabled: true
            Keys.onPressed: {
                if(event.key===Qt.Key_Enter || event.key===Qt.Key_Return)
                {
                    showCreatedFile()
                }
            }

            Item {
                id: rectLabelText
                width: parent.width
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    id: openFileText
                    text: qsTr("STR_CREATE_OPEN")
                    font.bold: activeFocus
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                    font.family: lato.name
                    color: Constants.COLOR_TEXT_LABEL
                    height: parent.height
                    width: parent.width - 48
                    wrapMode: Text.Wrap
                    KeyNavigation.tab: cancelButton
                    KeyNavigation.right: cancelButton
                    KeyNavigation.down: cancelButton
                    KeyNavigation.backtab: createdSuccTitle
                    KeyNavigation.up: createdSuccTitle
                }
            }
        }
        Item {
            width: createsuccess_dialog.availableWidth
            height: Constants.HEIGHT_BOTTOM_COMPONENT
            y: 80
            Item {
                width: parent.width
                height: Constants.HEIGHT_BOTTOM_COMPONENT
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    id: cancelButton
                    width: Constants.WIDTH_BUTTON
                    height: Constants.HEIGHT_BOTTOM_COMPONENT
                    text: qsTranslate("Popup File","STR_POPUP_FILE_CANCEL")
                    anchors.left: parent.left
                    font.pixelSize: Constants.SIZE_TEXT_FIELD
                    font.family: lato.name
                    font.capitalization: Font.MixedCase
                    KeyNavigation.tab: openButton
                    KeyNavigation.right: openButton
                    KeyNavigation.backtab: openFileText
                    KeyNavigation.up: openFileText
                    highlighted: activeFocus
                    onClicked: {
                        createsuccess_dialog.close()
                        mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
                    }
                    Keys.onEnterPressed: clicked()
                    Keys.onReturnPressed: clicked()
                }
                Button {
                    id: openButton
                    width: Constants.WIDTH_BUTTON
                    height: Constants.HEIGHT_BOTTOM_COMPONENT
                    text: qsTranslate("Popup File","STR_POPUP_FILE_OPEN")
                    anchors.right: parent.right
                    font.pixelSize: Constants.SIZE_TEXT_FIELD
                    font.family: lato.name
                    font.capitalization: Font.MixedCase
                    KeyNavigation.tab: createdSuccTitle
                    KeyNavigation.right: createdSuccTitle
                    KeyNavigation.backtab: cancelButton
                    KeyNavigation.up: cancelButton
                    highlighted: activeFocus
                    onClicked: {
                        showCreatedFile()
                    }
                    Keys.onEnterPressed: clicked()
                    Keys.onReturnPressed: clicked()
                }
            }
        }
        onRejected:{
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
            mainFormID.propertyPageLoader.forceActiveFocus()
        }
        onClosed: {
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
            mainFormID.propertyPageLoader.forceActiveFocus()
        }
    }
    Connections {
        target: gapi
        onSignalGenericError: {
            propertyBusyIndicator.running = false
        }
        onSignalPdfPrintSignSucess: {
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            openFileText.text = qsTr("STR_CREATE_OPEN")
            createsuccess_dialog.visible = true
            createdSuccTitle.forceActiveFocus()
            propertyBusyIndicator.running = false
        }
        onSignalPdfPrintSucess: {
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            openFileText.text = qsTr("STR_CREATE_OPEN")
            createsuccess_dialog.visible = true
            createdSuccTitle.forceActiveFocus()
            propertyBusyIndicator.running = false
        }
        onSignalPdfSignSuccess: {
            // test time stamp
            if (error_code == GAPI.SignMessageTimestampFailed)
            {
                openFileText.text = qsTranslate("PageServicesSign","STR_TIME_STAMP_FAILED")
            }
            else if (error_code == GAPI.SignMessageLtvFailed)
            {
                openFileText.text = qsTranslate("GAPI","STR_LTV_FAILED")
            }
            else 
            { // Sign with time stamp successful
                openFileText.text = qsTr("STR_CREATE_OPEN")
            }
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            createsuccess_dialog.visible = true
            createdSuccTitle.forceActiveFocus()
            propertyBusyIndicator.running = false
        }
        onSignalPdfSignFail: {
            var titlePopup = qsTranslate("PageServicesSign", "STR_SIGN_FAIL")
            var bodyPopup = ""
            if (error_code == GAPI.SignFilePermissionFailed) 
            {
                bodyPopup += qsTranslate("PageServicesSign", "STR_SIGN_FILE_PERMISSION_FAIL")
            } 
            else 
            {
                bodyPopup += qsTranslate("PageServicesSign", "STR_SIGN_GENERIC_ERROR") + " " + error_code
            }
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            propertyBusyIndicator.running = false
        }
        onSignalPdfPrintFail: {
            var titlePopup = qsTr("STR_PRINT_CREATE_PDF")
            var bodyPopup = qsTr("STR_PRINT_CREATE_PDF_FAIL")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            propertyBusyIndicator.running = false
        }
        onSignalPrinterPrintSucess: {
            var titlePopup = qsTr("STR_PRINT_PRINTER")
            var bodyPopup = qsTr("STR_PRINT_PRINTER_SUCESS")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalPrinterPrintFail: {
            console.log("got error on printer print failed "  + error_code)
            var titlePopup = qsTr("STR_PRINT_PRINTER")
            var bodyPopup = ""
            if (error_code == GAPI.NoPrinterAvailable) {
                bodyPopup = qsTr("STR_PRINT_NO_PRINTER_AVAILABLE")
            } else {
                bodyPopup = qsTr("STR_PRINT_PRINTER_FAIL")
            }
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)

        }
        onSignalRemoteAddressError: {
            console.log("PageCardPrint nSignalRemoteAddressError: "+ error_code)
            var titlePopup = qsTr("STR_PRINT_CREATE_PDF") + ": " + qsTranslate("Popup Card","STR_POPUP_ERROR")
            var bodyPopup = ""
            if (error_code == GAPI.AddressConnectionError) {
                bodyPopup = qsTr("STR_REMOTEADDRESS_NETWORK_ERROR")
                    + "<br/><br/>" + qsTranslate("GAPI","STR_VERIFY_PROXY")
                    + "<br/><br/>" + qsTr("STR_REMOTEADDRESS_GENERIC")
            }            
            else if (error_code == GAPI.AddressServerError) {
                bodyPopup = qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_SERVER_ERROR")
                    + "<br/><br/>" + qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_GENERIC")
            }            
            else if (error_code == GAPI.AddressConnectionTimeout) {
                bodyPopup = qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_TIMEOUT_ERROR")
                    + "<br/><br/>" + qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_GENERIC")
            }            
            else if (error_code == GAPI.AddressSmartcardError) {
                bodyPopup = qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_SMARTCARD_ERROR")
                    + "<br/><br/>" + qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_GENERIC")
            }
            else if (error_code == GAPI.AddressServerCertificateError) {
                bodyPopup = qsTranslate("GAPI", "STR_CERTIFICATE_ERROR")
                    + qsTranslate("GAPI", "STR_CERTIFICATE_ERROR_READ_ADDRESS")
                    + "<br/>" + qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_GENERIC")
            }
            else if (error_code == GAPI.CardCertificateError) {
                bodyPopup = qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_CARDCERTIFICATE_ERROR")
            }
            else if (error_code == GAPI.AddressInvalidStateError) {
                bodyPopup = qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_INVALIDSTATE_ERROR")
            }
            else if (error_code == GAPI.AddressUnknownError) {
                bodyPopup = qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_UNKNOWN_ERROR")
                    + "<br/><br/>" + qsTranslate("PageCardAdress", "STR_REMOTEADDRESS_GENERIC")
            }
            else {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_ACCESS_ERROR")
            }
            propertyBusyIndicator.running = false
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, true)
        }
        onSignalCardDataChanged: {
            console.log("Data Card Print --> Data Changed")
            propertyBusyIndicator.running = false

            propertySwitchBasic.enabled = true
            propertySwitchAdditional.enabled = true
            propertySwitchAddress.enabled = true
            propertySwitchNotes.enabled = gapi.isNotesSupported()
            propertySwitchPrintDate.enabled = true
            propertySwitchPdfSign.enabled = true

            mainFormID.propertyPageLoader.propertyGeneralPopUp.close()
            if(mainFormID.propertyPageLoader.propertyForceFocus)
                        propertyTitleSelectData.forceActiveFocus()

        }
        onSignalOperationCanceledByUser: {
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
            propertyBusyIndicator.running = false
        }

        onSignalCardAccessError: {
            console.log("Card Print Page onSignalCardAccessError")
            var titlePopup = qsTranslate("Popup Card","STR_POPUP_ERROR")
            var bodyPopup = ""
            if (error_code == GAPI.NoReaderFound) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_NO_CARD_READER")
                disableComponents()
            }
            else if (error_code == GAPI.NoCardFound) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_NO_CARD")
                disableComponents()
            }
            else if (error_code == GAPI.SodCardReadError) {
                bodyPopup = qsTranslate("Popup Card","STR_SOD_VALIDATION_ERROR")
                    + "<br/><br/>" + qsTranslate("Popup Card","STR_GENERIC_CARD_ERROR_MSG")
                disableComponents()
            }
            else if (error_code == GAPI.CardUserPinCancel) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_PIN_CANCELED")
            }
            else if (error_code == GAPI.CardPinTimeout) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_PIN_TIMEOUT")
            }
            else if (error_code == GAPI.IncompatibleReader) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_INCOMPATIBLE_READER")
            }
            else if (error_code == GAPI.PinBlocked) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_PIN_BLOCKED")
            }
            else {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_ACCESS_ERROR")
            }
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, true)
            propertyBusyIndicator.running = false
        }
        onSignalCardChanged: {
            console.log("Card Print Page onSignalCardChanged")
            var titlePopup = qsTranslate("Popup Card","STR_POPUP_CARD_READ")
            var bodyPopup = ""
            var returnSubMenuWhenClosed = false
            if (error_code == GAPI.ET_CARD_REMOVED) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_REMOVED")
                returnSubMenuWhenClosed = true;
                disableComponents()
            }
            else if (error_code == GAPI.ET_CARD_CHANGED) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_CHANGED")
                propertyBusyIndicator.running = true
                gapi.startCardReading()
            }
            else{
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_READ_UNKNOWN")
                returnSubMenuWhenClosed = true;
                disableComponents()

            }
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, returnSubMenuWhenClosed)
        }
        onSignalTestPinFinished: {
            if (triesLeft != 3) {
                propertySwitchAddress.checked = false
            }
        }

    }

    propertyFileDialogOutput {
        onAccepted: {

            outputFile = propertyFileDialogOutput.file.toString()
            console.log("Output filename on Accepted: " + outputFile)
            
            outputFile = decodeURIComponent(Functions.stripFilePrefix(outputFile))
            /*console.log("Output filename: " + outputFile)*/
            propertyBusyIndicator.running = true
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            gapi.startPrintPDF(outputFile,
                               propertySwitchBasic.checked,
                               propertySwitchAdditional.checked,
                               propertySwitchAddress.checked,
                               propertySwitchNotes.checked,
                               propertySwitchPrintDate.checked,
                               propertySwitchPdfSign.checked,
                               propertySwitchIsTimestamp.checked,
                               propertyCheckboxIsLtv.checked)
        }
    }

    propertySwitchPdfSign {
        onCheckedChanged: {
            if (!propertySwitchPdfSign.checked) {
                propertyCheckboxIsLtv.checked = false
                propertySwitchIsTimestamp.checked = false
            }
        }
    }

    propertySwitchIsTimestamp {
        onCheckedChanged: {
            if (!propertySwitchIsTimestamp.checked) {
                propertyCheckboxIsLtv.checked = false
            }
        }
    }

    ToolTip {
        property var maxWidth: 500
        id: controlToolTip
        contentItem:
            Text {
                id: tooltipText
                text: controlToolTip.text
                font: controlToolTip.font
                color: Constants.COLOR_MAIN_BLACK
                wrapMode: Text.WordWrap
                onTextChanged: {
                    controlToolTip.width = Math.min(controlToolTip.maxWidth, controlToolTip.implicitWidth)
                }
            }

        background: Rectangle {
            border.color: Constants.COLOR_MAIN_DARK_GRAY
            color: Constants.COLOR_MAIN_SOFT_GRAY
        }

        Timer {
            id: tooltipExitTimer
            interval: Constants.TOOLTIP_TIMEOUT_MS
            onTriggered: {
                controlToolTip.close()
                stop()
            }
        }
    }
    
    propertyMouseAreaToolTipIsLTV {
        onEntered: {
            tooltipExitTimer.stop()
            controlToolTip.close()
            controlToolTip.text = qsTranslate("PageServicesSign","STR_LTV_TOOLTIP")
            controlToolTip.x = propertyCheckboxIsLtv.mapToItem(controlToolTip.parent,0,0).x
                    + propertyCheckboxIsLtv.width + Constants.SIZE_IMAGE_TOOLTIP * 0.5
                    - controlToolTip.width * 0.5
            controlToolTip.y = propertyCheckboxIsLtv.mapToItem(controlToolTip.parent,0,0).y
                    - controlToolTip.height - Constants.SIZE_SPACE_IMAGE_TOOLTIP
            controlToolTip.open()
        }
        onExited: {
            tooltipExitTimer.start()
        }
    }

    propertyButtonPdf {
        onClicked: {
            propertyFileDialogOutput.currentFile = propertyFileDialogOutput.folder + (propertySwitchPdfSign.checked ? "/CartaoCidadao_signed.pdf" : "/CartaoCidadao.pdf")
            propertyFileDialogOutput.open()
        }
    }
    propertyButtonPrint {
        onClicked: {
            console.log("Printing file")
            gapi.startPrint("",
                               propertySwitchBasic.checked,
                               propertySwitchAdditional.checked,
                               propertySwitchAddress.checked,
                               propertySwitchNotes.checked,
                               propertySwitchPrintDate.checked,
                               propertySwitchPdfSign.checked)
        }
    }

    propertySwitchAddress{
        onCheckedChanged: {
            if(propertySwitchAddress.checked) {
                if (gapi.doGetTriesLeftAddressPin() === 0) {
                    var titlePopup = qsTranslate("Popup PIN","STR_POPUP_ERROR")
                    var bodyPopup = qsTranslate("Popup PIN","STR_POPUP_CARD_PIN_ADDRESS_BLOCKED")
                    mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, true)
                    propertySwitchAddress.checked = false
                }
                else {
                    gapi.verifyAddressPin("", false)
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("Page Card Print mainWindow Completed")
        propertyBusyIndicator.running = true
        dialogSignCMD.enableConnections()
        gapi.startCardReading()
    }

    function disableComponents(){
        propertySwitchBasic.enabled = false
        propertySwitchAdditional.enabled = false
        propertySwitchAddress.enabled = false
        propertySwitchNotes.enabled = false
        propertySwitchPrintDate.enabled = false
        propertySwitchPdfSign.enabled = false

        propertySwitchBasic.checked = false
        propertySwitchAdditional.checked = false
        propertySwitchAddress.checked = false
        propertySwitchNotes.checked = false
        propertySwitchPrintDate.checked = false
        propertySwitchPdfSign.checked = false
    }
    
    function showCreatedFile() {
        if (Qt.platform.os === "windows") {
            if (outputFile.substring(0, 2) === "//") {
                outputFile = "file:" + outputFile
            } else {
                outputFile = "file:///" + outputFile
            }
        }else{
            outputFile = "file://" + outputFile
        }
        /*console.log("Open Url Externally: " + outputFile)*/
        Qt.openUrlExternally(outputFile)
        createsuccess_dialog.close()
        mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
    }
    function toggleSwitch(element){
        element.checked = !element.checked
    }
}
