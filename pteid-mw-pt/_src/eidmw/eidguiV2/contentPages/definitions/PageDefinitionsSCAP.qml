/*-****************************************************************************

 * Copyright (C) 2017 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2017-2021 Adriano Campos - <adrianoribeirocampos@gmail.com>
 * Copyright (C) 2018-2019 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 * Copyright (C) 2019 José Pinto - <jose.pinto@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.6
import QtQuick.Controls 2.1

//Import C++ defined enums
import eidguiV2 1.0

import "../../scripts/Constants.js" as Constants
import "../../scripts/Functions.js" as Functions

PageDefinitionsSCAPForm {

    property bool isCardPresent: false
    property bool isLoadingAttributes: false
    property bool isLoadingCache: false
    property bool isTabSelected: true

    Keys.onRightPressed: {
        if(propertylinkScapEntities.activeFocus
                || propertylinkScapCompanies.activeFocus)
            returnToSignaturePage()
    }
    Keys.onSpacePressed: {
        if(propertylinkScapEntities.activeFocus
                || propertylinkScapCompanies.activeFocus)
            returnToSignaturePage()
    }
    Keys.onReturnPressed: {
        if(propertylinkScapEntities.activeFocus
                || propertylinkScapCompanies.activeFocus)
            returnToSignaturePage()
    }

    Keys.onPressed: {
        var index = propertyStackLayout.currentIndex
        var isOnEntitiesTab = index === 0
        var isOnEntityTab = index === 1


        if ((event.key == Qt.Key_Escape || event.key == Qt.Key_Left)
                    && isOnEntitiesTab && isTabSelected === false) {
            propertyTabButtonEntities.forceActiveFocus()
            isTabSelected = true
        } else if ((event.key == Qt.Key_Escape || event.key == Qt.Key_Left)
                            && isOnEntityTab && isTabSelected === false) {
            propertyTabButtonCompanies.forceActiveFocus()
            isTabSelected = true
        } else {
            Functions.detectBackKeys(event.key, Constants.MenuState.SUB_MENU)
        }
    }

    Connections {
        target: gapi
        onSignalGenericError: {
            propertyBusyIndicator.running = false
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
        }
        onSignalCardDataChanged: {
            console.log("Definitions SCAP Signature --> Data Changed")
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
            propertyBusyIndicator.running = false
            isCardPresent = true
            propertyButtonLoadEntityAttributes.enabled =
                    !isLoadingCache && isCardPresent && isAnyEntitySelected()
            propertyButtonLoadCompanyAttributes.enabled =
                    !isLoadingCache && isCardPresent
        }
        onSignalCardAccessError: {
            console.log("Definitions SCAP Signature --> onSignalCardAccessError")
            isCardPresent = false
            var titlePopup = qsTranslate("Popup Card","STR_POPUP_ERROR")
            var bodyPopup = ""
            if (error_code == GAPI.NoReaderFound) {
                return;
            }
            else if (error_code == GAPI.NoCardFound) {
                return;
            }
            else if (error_code == GAPI.CardUnknownCard) {
                return;
            }
            else if (error_code == GAPI.SodCardReadError) {
                bodyPopup = qsTranslate("Popup Card","STR_SOD_VALIDATION_ERROR") 
                    + "<br/><br/>" + qsTranslate("Popup Card","STR_GENERIC_CARD_ERROR_MSG") 
                   
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
            else {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_ACCESS_ERROR")
            }
            propertyButtonLoadEntityAttributes.enabled =
                    !isLoadingCache && isCardPresent && isAnyEntitySelected()
            propertyButtonLoadCompanyAttributes.enabled =
                    !isLoadingCache && isCardPresent
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            propertyBusyIndicatorAttributes.running = false
            propertyBusyIndicator.running = false
            propertyTabButtonEntities.forceActiveFocus()
        }
        onSignalCardChanged: {
            console.log("Definitions SCAP Signature --> onSignalCardChanged")
            var titlePopup = qsTranslate("Popup Card","STR_POPUP_CARD_READ")
            var bodyPopup = ""
            if (error_code == GAPI.ET_CARD_REMOVED) {
                isCardPresent = false
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_REMOVED")
            }
            else if (error_code == GAPI.ET_CARD_CHANGED) {
                isCardPresent = true
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_CHANGED")
                propertyBusyIndicator.running = true
                gapi.startCardReading()
            }
            else{
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_READ_UNKNOWN")
            }
            propertyButtonLoadEntityAttributes.enabled =
                    !isLoadingCache && isCardPresent && isAnyEntitySelected()
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalSCAPServiceFail: {
            isLoadingAttributes = false
            console.log("Definitions SCAP - Signal SCAP service fail Code = "
                        + pdfsignresult + " isCompany = " + isCompany)
            cmdLoadDialog.close()

            var titlePopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ERROR")
            var bodyPopup = ""
            var linkUrl = ""
            var accessibleText = ""
            if(isCompany === true){
                if(pdfsignresult == GAPI.ScapAttributesExpiredError){
                    console.log("ScapAttributesExpiredError")
                    bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_COMPANY_ATTRIBUTES_EXPIRED")
                            + " "
                            + "<a href=\"https://www.autenticacao.gov.pt/a-autenticacao-de-profissionais\">"
                            + "https://www.autenticacao.gov.pt/a-autenticacao-de-profissionais"
                    linkUrl = 'https://www.autenticacao.gov.pt/a-autenticacao-de-profissionais'
                    accessibleText = qsTranslate("PageDefinitionsSCAP","STR_SCAP_COMPANY_ATTRIBUTES_EXPIRED")
                            + " "
                            + "https://www.autenticacao.gov.pt/a-autenticacao-de-profissionais"
                }else if(pdfsignresult == GAPI.ScapZeroAttributesError){
                    console.log("ScapZeroAttributesError")
                    linkUrl = qsTranslate("PageDefinitionsSCAP", "STR_SCAP_COMPANY_ZERO_ATTRIBUTES_LINK_URL")
                    bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_COMPANY_ZERO_ATTRIBUTES").arg(linkUrl)
                    accessibleText = qsTranslate("PageDefinitionsSCAP","STR_SCAP_COMPANY_ZERO_ATTRIBUTES").arg(linkUrl)
                }else {
                    console.log("ScapGenericError")
                    show_generic_scap_error_message()
                    return
                }
            }else{
                var attributeList = getSelectedEntityNames()

                var popupMsg = ""
                var separator = ""
                for (var i = 0; i < attributeList.length; i++) {
                    popupMsg += separator + attributeList[i]
                    separator = (i == attributeList.length - 1) ? " e " : ", "
                }
                console.log("popupMsg: " + popupMsg)

                if(pdfsignresult == GAPI.ScapMultiEntityError){
                    titlePopup = qsTranslate("PageDefinitionsSCAP","STR_WARNING")
                    bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_MULTI_ENTITIES_FIRST")
                            + " " + popupMsg + " "
                            + "<b>" + qsTranslate("PageDefinitionsSCAP","STR_SCAP_MULTI_ENTITIES_SECOND") + "</b>"
                            + "<br><br>"
                            + qsTranslate("PageDefinitionsSCAP","STR_SCAP_MULTI_ENTITIES_THIRD")
                }else if(pdfsignresult == GAPI.ScapAttributesExpiredError){
                    bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITIES_ATTRIBUTES_EXPIRED_FIRST")
                            + " " + popupMsg + " "
                            + "<b>" + qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITIES_ATTRIBUTES_EXPIRED_SECOND") + "</b>"
                            + "<br><br>"
                            + qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITIES_ATTRIBUTES_EXPIRED_THIRD")
                            + " " + popupMsg + "."
                }else if(pdfsignresult == GAPI.ScapZeroAttributesError){
                    console.log("ScapZeroAttributesError")
                    bodyPopup = "<b>" + qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITIES_ZERO_ATTRIBUTES_FIRST") + "</b>"
                            + " " + popupMsg + "."
                            + "<br><br>"
                            + qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITIES_ZERO_ATTRIBUTES_SECOND")
                            + " " + popupMsg + "."
                }else {
                    console.log("ScapGenericError")
                    show_generic_scap_error_message()
                    return
                }
            }

            popupMsg = ""
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false, linkUrl, accessibleText)

            propertyBusyIndicatorAttributes.running = false
            propertyBusyIndicator.running = false
        }

        onSignalSCAPIncompleteResponse: {
            console.log("ScapIncompleteResponse")

            var titlePopup = qsTranslate("PageServicesSign","STR_SCAP_WARNING")
            var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_INCOMPLETE_RESPONSE_FIRST") + "<br>"
                + "<ul><li>" + failed_providers.join("</li><li>") + "</li></ul>"

            show_error_message(titlePopup, bodyPopup)
        }

        onSignalSCAPConnectionFailed: {
            console.log("Scap connection failed")

            var titlePopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ERROR")
            var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_SERVICE_FAIL_FIRST") + "<br>"
                + qsTranslate("PageDefinitionsSCAP", "STR_SCAP_PING_FAIL_SECOND")

            show_error_message(titlePopup, bodyPopup)
        }

        onSignalSCAPProxyAuthRequired: {
            console.log("Scap proxy auth required")

            var titlePopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ERROR")
            var bodyPopup = qsTranslate("GAPI","STR_PROXY_AUTH_FAILED")

            show_error_message(titlePopup, bodyPopup)
        }

        onSignalSCAPPossibleProxyMisconfigured: {
            console.log("Scap possible misconfiguration of proxy")

            var titlePopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ERROR")
            var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_SERVICE_FAIL_FIRST") + "<br>"
                + qsTranslate("PageDefinitionsSCAP", "STR_SCAP_PING_FAIL_SECOND") + "<br><br>"
                + qsTranslate("GAPI","STR_VERIFY_PROXY")

            show_error_message(titlePopup, bodyPopup)
        }

        onSignalSCAPNoAttributesResponse: {
            console.log("Scap No Attributes")

            var titlePopup = qsTranslate("PageServicesSign","STR_SCAP_WARNING")
            var bodyPopup = ""
            var linkUrl = ""
            var accessibleText = ""
            if (enterprise) {
                linkUrl = qsTranslate("PageDefinitionsSCAP", "STR_SCAP_COMPANY_ZERO_ATTRIBUTES_LINK_URL")
                bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_COMPANY_ZERO_ATTRIBUTES").arg(linkUrl)
                accessibleText = qsTranslate("PageDefinitionsSCAP","STR_SCAP_COMPANY_ZERO_ATTRIBUTES").arg(linkUrl)
            } else {
                bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITIES_ZERO_ATTRIBUTES_FIRST")
                    + "<ul><li>" + failed_providers.join("</li><li>") + "</li></ul>"
                    + qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITIES_ZERO_ATTRIBUTES_SECOND")
            }

            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false, linkUrl, accessibleText)
        }

        onSignalSCAPBadCredentials: {
            console.log("Scap Bad Credentials")

            var titlePopup = qsTranslate("PageServicesSign","STR_SCAP_ERROR")
            var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_BAD_CREDENTIALS")

            show_error_message(titlePopup, bodyPopup)
        }

        onSignalCacheRemovedLegacy: {
            console.log("Scap Removed Legacy cache files")

            var titlePopup = qsTranslate("PageServicesSign","STR_SCAP_WARNING")
            var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_LEGACY_CACHE")

            show_error_message(titlePopup, bodyPopup)
        }

        onSignalEntityAttributesLoadedError: {
            isLoadingAttributes = false
            console.log("Definitions SCAP - Signal SCAP entities loaded error")
            var titlePopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ERROR")
            var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_LOAD_ENTITIES_ERROR")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            if(propertyBar.currentIndex == 0)
                propertyBusyIndicatorAttributes.running = false
            propertyListViewEntities.forceActiveFocus()
        }
        onSignalCompanyAttributesLoadedError: {
            isLoadingAttributes = false
            console.log("Definitions SCAP - Signal SCAP company loaded error")
            var titlePopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ERROR")
            var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_LOAD_COMPANY_ERROR")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            if(propertyBar.currentIndex == 1)
                propertyBusyIndicatorAttributes.running = false
        }
        onSignalSCAPEntitiesLoaded: {
            console.log("Definitions SCAP - Signal SCAP entities loaded")
            entityAttributesModel.clear()
            for (var i = 0; i < entitiesList.length; i++)
            {
                entityAttributesModel.append({
                                                 entityName: entitiesList[i],
                                                 attribute: "",
                                                 checkBoxAttr: false
                                             });
            }

            // Load attributes from cache (Entities, ShortDescription)
            isLoadingCache = true
            gapi.startLoadingAttributesFromCache(true)
            propertyBusyIndicator.running = false
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
            propertyBusyIndicatorAttributes.running = false
        }
        onSignalAttributesLoaded: {
            console.log("Definitions SCAP - Signal SCAP Entity attributes loaded")
            isLoadingCache = false
            cmdLoadDialog.close()

            update_entity_attributes(institution_attributes)
            update_company_attributes(enterprise_attributes)

            propertyBusyIndicatorAttributes.running = false
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
        }
        onSignalAttributesPossiblyExpired: {
            var titlePopup = qsTranslate("PageServicesSign","STR_SCAP_WARNING")
            var bodyPopup = qsTranslate("PageServicesSign","STR_SCAP_ATTRS_POSSIBLY_EXPIRED") + "<br>"
            for (var i = 0; i < expiredSuppliers.length; i++) {
                bodyPopup += "<br> - " + expiredSuppliers[i]
            }
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalRemoveSCAPAttributesSucess: {
            console.log("Definitions SCAP - Signal SCAP Signal Remove SCAP Attributes Sucess")
            if (isLoadingAttributes == false) {
                propertyBusyIndicatorAttributes.running = false
                var titlePopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE")
                var bodyPopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE_SUCC")
                mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            }
            gapi.startGettingEntities()
        }
        onSignalRemoveSCAPAttributesFail: {
            console.log("Definitions SCAP - Signal Remove SCAP Attributes Fail")
            propertyBusyIndicatorAttributes.running = false
            var titlePopup = qsTranslate("PageDataApp","STR_PERMISSIONS_CACHE")
            var bodyPopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE_FAIL")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            gapi.startGettingEntities()
        }
        onSignalCacheNotReadable:{
            propertyBusyIndicatorAttributes.running = false;
            var titlePopup = qsTranslate("PageDataApp","STR_PERMISSIONS_CACHE")
            var bodyPopup = qsTranslate("PageDataApp","STR_CACHE_NOT_READABLE")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            gapi.startGettingEntities()
            propertyBusyIndicator.running = true
        }
        onSignalCacheNotWritable:{
            propertyBusyIndicatorAttributes.running = false;
            var titlePopup = qsTranslate("PageDataApp","STR_PERMISSIONS_CACHE")
            var bodyPopup = qsTranslate("PageDataApp","STR_CACHE_NOT_WRITABLE")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalCacheFolderNotCreated:{
            propertyBusyIndicatorAttributes.running = false;
            var titlePopup = qsTranslate("PageDataApp","STR_PERMISSIONS_CACHE")
            var bodyPopup = qsTranslate("PageDataApp","STR_CACHE_FOLDER_NOT_CREATED")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalEndOAuth: {
            cmdLoadDialog.close()

            switch (oauthResult){
                case 0://OAuthTimeoutError
                    var titlePopup = qsTranslate("Popup Card","STR_POPUP_ERROR")
                    var bodyPopup = qsTranslate("OAuth","STR_OAUTH_TIMEOUT")
                    break;
                case 1://OAuthGenericError
                    var titlePopup = qsTranslate("Popup Card","STR_POPUP_ERROR")
                    var bodyPopup = qsTranslate("OAuth","STR_OAUTH_GENERIC_ERROR")
                case 2://OAuthConnectionError
                    var titlePopup = qsTranslate("Popup Card","STR_POPUP_ERROR")
                    var bodyPopup = qsTranslate("OAuth","STR_OAUTH_CONNECTION_ERROR")
                    break;
                case 3://OAuthCancelled
                    console.log("OAuth - cancelled")
                    return;
            }
            propertyBusyIndicatorAttributes.running = false
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
    }

    Component {
        id: attributeListDelegateEntities
        Rectangle {
            id: container
            width: parent.width - propertyEntitiesListViewScroll.width
                   - Constants.SIZE_ROW_H_SPACE * 0.5
            height: columnItem.height + 10
            Keys.onSpacePressed: {
                checkboxSel.focus = true
            }
            Keys.onTabPressed: {
                focusForward();
            }
            Keys.onDownPressed: {
                focusForward();
            }
            Keys.onBacktabPressed: {
                focusBackward();
            }
            Keys.onUpPressed: {
                focusBackward();
            }
            color:  propertyListViewEntities.currentIndex === index && propertyListViewEntities.focus
                    ? Constants.COLOR_MAIN_DARK_GRAY : Constants.COLOR_MAIN_SOFT_GRAY

            Accessible.role: Accessible.CheckBox
            Accessible.name: Functions.filterText(entityText.text + attrTitle.text
                                                  + (attrText.text.length > 0 ? attrText.text : qsTranslate("GAPI","STR_EMPTY_FIELD"))
                                                  )
            CheckBox {
                id: checkboxSel
                height: 25
                width: 50
                font.family: lato.name
                font.pixelSize: Constants.SIZE_TEXT_FIELD
                font.capitalization: Font.MixedCase
                anchors.top: parent.top
                onCheckedChanged: {
                    entityAttributesModel.get(index).checkBoxAttr = checkboxSel.checked
                    propertyButtonLoadEntityAttributes.enabled =
                            !isLoadingCache && isCardPresent && isAnyEntitySelected()
                    propertyButtonLoadEntityAttributesOAuth.enabled =
                            !isLoadingCache && isAnyEntitySelected()
                    propertyListViewEntities.currentIndex = index
                }
                onFocusChanged: {
                    if(focus) propertyListViewEntities.currentIndex = index
                }
            }
            Column {
                id: columnItem
                anchors.left: checkboxSel.right
                width: parent.width - checkboxSel.width - Constants.SIZE_ROW_H_SPACE * 0.5
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id: entityText
                    text: '<b>' + qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITY") + '</b> ' + entityName
                    font.family: lato.name
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: attrTitle
                    text: '<b>'+ qsTranslate("PageDefinitionsSCAP","STR_SCAP_ATTR") + '</b>'
                    font.family: lato.name
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: attrText
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: attribute
                    font.family: lato.name
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                }
            }
            function focusForward(){
                checkboxSel.focus = true
                if(propertyListViewEntities.currentIndex == propertyListViewEntities.count -1){
                    propertylinkScapEntities.visible
                        ? propertylinkScapEntities.forceActiveFocus()
                        : propertyButtonRemoveEntityAttributes.forceActiveFocus()
                }else{
                    propertyListViewEntities.currentIndex++
                }
            }
            function focusBackward(){
                checkboxSel.focus = true
                if(propertyListViewEntities.currentIndex == 0){
                    propertyEntitiesText.forceActiveFocus()
                }else{
                    propertyListViewEntities.currentIndex--
                }
            }
        }
    }
    propertyListViewCompanies{
        onFocusChanged: {
            if(propertyListViewCompanies.focus)propertyListViewCompanies.currentIndex = 0
        }
    }
    Component {
        id: attributeListDelegateCompanies
        Rectangle {
            id: container
            width: parent.width - propertyCompaniesListViewScroll.width
                   - Constants.SIZE_ROW_H_SPACE * 0.5
            height: columnItem.height + 10
            Keys.onTabPressed: {
                if(propertyListViewCompanies.currentIndex == propertyListViewCompanies.count -1){
                    propertylinkScapCompanies.visible == true
                        ? propertylinkScapCompanies.forceActiveFocus()
                        : propertyButtonRemoveCompanyAttributes.forceActiveFocus()
                }else{
                    propertyListViewCompanies.currentIndex++
                }
            }
            Keys.onBacktabPressed: {
                if(propertyListViewCompanies.currentIndex == 0){
                    propertyCompaniesText.forceActiveFocus()
                }else{
                    propertyListViewCompanies.currentIndex--
                }
            }
            color:  propertyListViewCompanies.currentIndex === index && propertyListViewCompanies.focus
                    ? Constants.COLOR_MAIN_DARK_GRAY : Constants.COLOR_MAIN_SOFT_GRAY
            Accessible.role: Accessible.CheckBox
            Accessible.name: Functions.filterText(entityText.text + attrTitle.text
                                                  + (attrText.text.length > 0 ? attrText.text : qsTranslate("GAPI","STR_EMPTY_FIELD"))
                                                  )
            Column {
                id: columnItem
                width: parent.width - Constants.SIZE_ROW_H_SPACE
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    id: entityText
                    text: '<b>' + qsTranslate("PageDefinitionsSCAP","STR_SCAP_ENTITY") + '</b> ' + entityName
                    font.family: lato.name
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: attrTitle
                    text: '<b>'+ qsTranslate("PageDefinitionsSCAP","STR_SCAP_ATTR") + '</b>'
                    font.family: lato.name
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: attrText
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: attribute
                    font.family: lato.name
                    font.pixelSize: Constants.SIZE_TEXT_LABEL
                }
            }

        }
    }

    ListModel {
        id: companyAttributesModel
    }

    ListModel {
        id: entityAttributesModel
    }

    Dialog {
        id: cmdLoadDialog
        width: 400
        height: 200
        font.family: lato.name
        // Center dialog in the main view
        x: - mainMenuView.width - subMenuView.width
           + mainView.width * 0.5 - width * 0.5
        y: parent.height * 0.5 - height * 0.5
        modal: true

        header: Label {
            id: labelTextTitle
            visible: true
            text: qsTranslate("OAuth","STR_OAUTH")
            elide: Label.ElideRight
            padding: 24
            bottomPadding: 0
            font.bold: activeFocus
            font.pixelSize: Constants.SIZE_TEXT_MAIN_MENU
            color: Constants.COLOR_MAIN_BLUE
            KeyNavigation.tab: textContinueInBrowser
            KeyNavigation.down: textContinueInBrowser
        }

        Item {
            width: parent.width
            height: parent.height

            Item {
                id: rectMessage
                width: parent.width
                height: 50

                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    id: textContinueInBrowser
                    text: qsTranslate("OAuth","STR_CONTINUE_IN_BROWSER")
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: activeFocus ? Constants.SIZE_TEXT_LABEL_FOCUS : Constants.SIZE_TEXT_LABEL
                    font.bold: activeFocus
                    font.family: lato.name
                    color: Constants.COLOR_TEXT_LABEL
                    height: parent.height
                    width: parent.width
                    anchors.bottom: parent.bottom
                    wrapMode: Text.WordWrap
                    KeyNavigation.tab: closeCmdLoadDialogButton
                    KeyNavigation.down: closeCmdLoadDialogButton
                }
            }
        }
        Button {
            id: closeCmdLoadDialogButton
            width: Constants.WIDTH_BUTTON
            height: Constants.HEIGHT_BOTTOM_COMPONENT
            font.pixelSize: Constants.SIZE_TEXT_FIELD
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTranslate("OAuth","STR_ABORT_AUTH")
            font.capitalization: Font.MixedCase
            KeyNavigation.tab: labelTextTitle
            KeyNavigation.down: labelTextTitle
            highlighted: activeFocus
            onClicked: {
                cmdLoadDialog.close()
                gapi.abortSCAPWithCMD()
                propertyBusyIndicatorAttributes.running = false

            }
            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()
        }
        onOpened: {
            labelTextTitle.forceActiveFocus()
        }
        onRejected: {
            cmdLoadDialog.open()
        }
        onClosed: {
            mainFormID.opacity = Constants.OPACITY_MAIN_FOCUS
            propertyTabButtonEntities.forceActiveFocus()
        }

    }

    propertyButtonLoadCompanyAttributes {
        onClicked: {
            console.log("ButtonLoadCompanyAttributes clicked!")
            isLoadingAttributes = true
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            propertyBusyIndicatorAttributes.running = true
            gapi.startGettingCompanyAttributes(false)
        }
    }
    propertyButtonLoadCompanyAttributesOAuth {
        onClicked: {
            console.log("ButtonLoadCompanyAttributesOAuth clicked!")
            isLoadingAttributes = true
            propertyBusyIndicatorAttributes.running = true
            gapi.startGettingCompanyAttributes(true)
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            cmdLoadDialog.open()
        }
    }

    propertyButtonLoadEntityAttributes {
        onClicked: {
            console.log("ButtonLoadEntityAttributes clicked!")
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            propertyBusyIndicatorAttributes.running = true
            isLoadingAttributes = true
            var attributeList = getSelectedEntityNames()
            console.log("QML AttributeList: ", attributeList)
            gapi.startGettingEntityAttributes(attributeList, false)
        }
    }
    propertyButtonLoadEntityAttributesOAuth {
        onClicked: {
            console.log("ButtonLoadEntityAttributesOAuth clicked!")
            propertyBusyIndicatorAttributes.running = true
            isLoadingAttributes = true
            var attributeList = getSelectedEntityNames()
            console.log("QML AttributeList: ", attributeList)
            gapi.startGettingEntityAttributes(attributeList, true)
            mainFormID.opacity = Constants.OPACITY_POPUP_FOCUS
            cmdLoadDialog.open()
        }
    }
    propertyButtonRemoveCompanyAttributes {
        onClicked: {
            console.log("propertyButtonRemoveCompanyAttributes clicked!")
            isLoadingAttributes = isLoadingCache = false
            companyAttributesModel.clear()
            entityAttributesModel.clear()
            propertyBusyIndicatorAttributes.running = true
            gapi.startRemovingAttributesFromCache()
        }

    }

    propertyButtonRemoveEntityAttributes {
        onClicked: {
            console.log("propertyButtonRemoveEntityAttributes clicked!")
            isLoadingAttributes = isLoadingCache = false
            companyAttributesModel.clear()
            entityAttributesModel.clear()
            propertyButtonLoadEntityAttributes.enabled = false
            propertyButtonLoadEntityAttributesOAuth.enabled = false
            propertyBusyIndicatorAttributes.running = true
            gapi.startRemovingAttributesFromCache()
        }
    }

    propertyMouseArealinkScapEntities {
        onClicked: {
            console.log("propertyMouseArealinkScapEntities clicked!")
            returnToSignaturePage()
        }
    }

    propertyMouseArealinkScapCompanies {
        onClicked: {
            console.log("propertyMouseArealinkScapCompanies clicked!")
            returnToSignaturePage()
        }
    }
    propertyBar{
        onCurrentIndexChanged: {
            propertyStackLayout.currentIndex = propertyBar.currentIndex
            if(propertyStackLayout.currentIndex == 0
                    && entityAttributesModel.count == 0
                    || isLoadingCache == true)
                gapi.startGettingEntities()
        }
    }
    Component.onCompleted: {
        console.log("Page Definitions SCAP Completed")
        propertyBusyIndicator.running = true
        gapi.startCardReading()
        propertyBusyIndicatorAttributes.running = true
        isLoadingAttributes = false
        propertyTabButtonEntities.forceActiveFocus()
        gapi.startGettingEntities()
    }

    function update_entity_attributes(attributes) {
        if (entityAttributesModel.count == 0) {
            for (var provider in attributes) {
                entityAttributesModel.set(j, {
                    "entityName": provider,
                    "attribute": "<ul><li>" + attributes[provider].join("</li><br><li>") + "</li></ul>",
                    checkBoxAttr: false
                })
            }
        } else {
            for (var provider in attributes) {
                for (var j = 0; j < entityAttributesModel.count; j++) {
                    if (entityAttributesModel.get(j).entityName === provider) {
                        entityAttributesModel.set(j, {
                            "entityName": entityAttributesModel.get(j).entityName,
                            "attribute": "<ul><li>" + attributes[provider].join("</li><br><li>") + "</li></ul>"
                        })
                    }
                }
            }
        }
    }

    function update_company_attributes(attributes) {
        companyAttributesModel.clear()
        for (var provider in attributes) {
            // Let's see if company already exists and in what index
            var companyIndex
            for (companyIndex = 0; companyIndex < companyAttributesModel.count; companyIndex++) {
                if (companyAttributesModel.get(companyIndex).entityName === provider) {
                    break
                }
            }
            if (companyAttributesModel.count>0 && companyIndex < companyAttributesModel.count) {
                companyAttributesModel.set(companyIndex,
                {
                    entityName: provider,
                    attribute: companyAttributesModel.get(companyIndex).attribute
                              + "<ul><li>" + attributes[provider].join("</li><br><li>") + "</li></ul>"
                });
            } else {
                companyAttributesModel.append(
                {
                  entityName: provider,
                  attribute: "<ul><li>" + attributes[provider].join("</li><br><li>") + "</li></ul>",
                  checkBoxAttr: false
                });
            }
        }
    }

    function show_generic_scap_error_message() {
        var titlePopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_ERROR")
        var bodyPopup = qsTranslate("PageDefinitionsSCAP","STR_SCAP_PING_FAIL_FIRST")

        if (controler.isProxyConfigured()) {
            bodyPopup += "<br><br>" + qsTranslate("GAPI","STR_VERIFY_PROXY")
        }
        show_error_message(titlePopup, bodyPopup)
    }

    function show_error_message(title, body) {
        mainFormID.propertyPageLoader.activateGeneralPopup(title, body, false)

        propertyBusyIndicator.running = false
        propertyBusyIndicatorAttributes.running = false
    }

    function returnToSignaturePage() {
        propertyPageLoader.propertyBackupFromSignaturePage = false
        mainFormID.state = Constants.MenuState.EXPAND
        mainFormID.propertySubMenuListView.model.clear()
        mainFormID.propertyMainMenuListView.currentIndex = Constants.MAIN_MENU_SIGN_PAGE_INDEX
        mainFormID.propertyMainMenuBottomListView.currentIndex = -1
        mainFormID.propertySubMenuListView.currentIndex = -1
        mainFormID.propertyPageLoader.source = "../../" + Constants.SIGNATURE_PAGE_URL
        mainFormID.propertyPageLoader.item.propertySwitchAddAttributes.checked = true
    }

    function isAnyEntitySelected() {
        for (var i = 0; i < entityAttributesModel.count; i++){
            if(entityAttributesModel.get(i).checkBoxAttr === true){
                return true
            }
        }
        return false
    }

    function getSelectedEntityNames() {
        var entities = []
        for (var i = 0; i < entityAttributesModel.count; i++) {
            if (entityAttributesModel.get(i).checkBoxAttr == true) {
                entities.push(entityAttributesModel.get(i).entityName)
            }
        }

        return entities
    }

    function toTitleCase(str) {
        return str.replace(/\w\S*/g, function(txt){
            return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        });
    }
    function tabDetectKeys(key) {
        if(propertyTabButtonEntities.focus)
            if(key===Qt.Key_Return || key===Qt.Key_Space || key===Qt.Key_Right){
                propertyStackLayout.currentIndex = propertyBar.currentIndex = 0
                propertyEntitiesText.forceActiveFocus()
                isTabSelected = false
            }
        if(propertyTabButtonCompanies.focus)
            if(key===Qt.Key_Return || key===Qt.Key_Space || key===Qt.Key_Right){
                propertyStackLayout.currentIndex = propertyBar.currentIndex = 1
                propertyCompaniesText.forceActiveFocus()
                isTabSelected = false
            }
    }
}
