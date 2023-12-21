/*-****************************************************************************

 * Copyright (C) 2018 Miguel Figueira - <miguelblcfigueira@gmail.com>
 * Copyright (C) 2019 Adriano Campos - <adrianoribeirocampos@gmail.com>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.6
import QtQuick.Controls 2.1

import "../../scripts/Constants.js" as Constants
import "../../scripts/Functions.js" as Functions

//Import C++ defined enums
import eidguiV2 1.0

PageDefinitionsDataForm {

    Keys.onPressed: {
        console.log("PageDefinitionsDataForm onPressed:" + event.key)
        Functions.detectBackKeys(event.key, Constants.MenuState.SUB_MENU)
    }

    Connections {
        target: gapi

        onSignalGenericError: {
            propertyBusyIndicator.running = false
        }
        onSignalCardDataChanged: {
            propertyBusyIndicator.running = false
            updateCacheSize();
        }
        onSignalCardAccessError: {
            console.log("Definitions SCAP Signature --> onSignalCardAccessError")
            propertyBusyIndicator.running = false;
            var titlePopup = qsTranslate("Popup Card","STR_POPUP_ERROR") + controler.autoTr
            var bodyPopup = ""
            if (error_code == GAPI.NoReaderFound) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_NO_CARD_READER") + controler.autoTr
            }
            else if (error_code == GAPI.NoCardFound) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_NO_CARD") + controler.autoTr
            }
            else if (error_code == GAPI.SodCardReadError) {
                bodyPopup = qsTranslate("Popup Card","STR_SOD_VALIDATION_ERROR") 
                    + "<br/><br/>" + qsTranslate("Popup Card","STR_GENERIC_CARD_ERROR_MSG") 
                    + controler.autoTr
            }
            else if (error_code == GAPI.CardUserPinCancel) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_PIN_CANCELED") + controler.autoTr
            }
            else if (error_code == GAPI.CardPinTimeout) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_PIN_TIMEOUT") + controler.autoTr
            }
            else {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_ACCESS_ERROR") + controler.autoTr
            }
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)

            propertyBusyIndicator.running = false
        }
        onSignalCardChanged: {
            console.log("Definitions SCAP Signature --> onSignalCardChanged")
            var titlePopup = qsTranslate("Popup Card","STR_POPUP_CARD_READ") + controler.autoTr
            var bodyPopup = ""
            if (error_code == GAPI.ET_CARD_REMOVED) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_REMOVED") + controler.autoTr
            }
            else if (error_code == GAPI.ET_CARD_CHANGED) {
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_CHANGED") + controler.autoTr
                propertyBusyIndicator.running = true
                gapi.startCardReading()
            }
            else{
                bodyPopup = qsTranslate("Popup Card","STR_POPUP_CARD_READ_UNKNOWN") + controler.autoTr
            }
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalRemoveSCAPAttributesSucess: {
            console.log("Definitions SCAP - Signal SCAP Signal Remove SCAP Attributes Sucess")
            updateCacheSize();
            propertyBusyIndicator.running = false
            var titlePopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE") + controler.autoTr
            var bodyPopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE_SUCC") + controler.autoTr
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalRemoveSCAPAttributesFail: {
            console.log("Definitions SCAP - Signal Remove SCAP Attributes Fail")
            updateCacheSize();
            propertyBusyIndicator.running = false
            var titlePopup = qsTranslate("Popup Card","STR_POPUP_ERROR") + controler.autoTr
            var bodyPopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE_ERROR") + controler.autoTr
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }
        onSignalCacheNotReadable:{
            updateCacheSize();
            propertyBusyIndicator.running = false;
            var titlePopup = qsTranslate("PageDataApp","STR_PERMISSIONS_CACHE")
            var bodyPopup = qsTranslate("PageDataApp","STR_CACHE_NOT_READABLE")
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
        }

		onSignalRemoveCANCacheSucess:{
			console.log("Definitions SCAP - Signal CAN Signal Remove CAN cache Sucess")
			propertyBusyIndicator.running = false;
			var titlePopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE") + controler.autoTr
            var bodyPopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE_SUCC") + controler.autoTr
            mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
		}
    }
    Connections {
        target: controler

        onSignalRemovePteidCacheSuccess:{
            updateCacheSize();
            if (propertyCheckboxEnableCache.checked)
            {
                propertyBusyIndicator.running = false;
                var titlePopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE")
                var bodyPopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE_SUCC")
                mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            }
        }
        onSignalRemovePteidCacheFail:{
            updateCacheSize();
            if (propertyCheckboxEnableCache.checked)
            {
                propertyBusyIndicator.running = false;
                var titlePopup = qsTranslate("PageDataApp","STR_PERMISSIONS_CACHE")
                var bodyPopup = qsTranslate("PageDataApp","STR_CLEAR_CACHE_FAIL")
                mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            }
        }
        onSignalCacheNotReadable:{
            updateCacheSize();
            if (propertyCheckboxEnableCache.checked)
            {
                propertyBusyIndicator.running = false;
                var titlePopup = qsTranslate("PageDataApp","STR_PERMISSIONS_CACHE")
                var bodyPopup = qsTranslate("PageDataApp","STR_CACHE_NOT_READABLE")
                mainFormID.propertyPageLoader.activateGeneralPopup(titlePopup, bodyPopup, false)
            }
        }
        onSignalAppCacheSize:{
            propertyCacheAppSizeTextField.text  = qsTranslate("PageDataApp", "STR_SIZE_OF_CACHE") + " " + cacheSize;
        }
        onSignalScapCacheSize:{
            propertyCacheSCAPSizeTextField.text  = qsTranslate("PageDataApp", "STR_SIZE_OF_CACHE") + " " + cacheSize;
        }
    }

    propertyCheckboxEnableCache{
        onCheckedChanged: {
            var bEnabled = propertyCheckboxEnableCache.checked;
            controler.setEnablePteidCache(bEnabled);
            //clear cache when it is disabled
            if(!bEnabled)
            {
                controler.flushCache();
            }
            propertyButtonRemoveAppCache.enabled = bEnabled;
        }
    }

    propertyButtonRemoveAppCache {
        onClicked: {
            console.log("propertyButtonRemoveAppCache clicked" + propertyButtonRemoveAppCache.enabled);
            if(propertyButtonRemoveAppCache.enabled)
            {
                propertyBusyIndicator.running = true;
                controler.flushCache()
            }

        }
    }
    propertyButtonRemoveSCAPCache {
        onClicked: {
            console.log("propertyButtonRemoveSCAPCache clicked");
            propertyBusyIndicator.running = true;
            gapi.startRemovingAttributesFromCache(GAPI.ScapAttrAll);
        }
    }

    propertyCheckboxEnableCANCache {
        onCheckedChanged: {
            var bEnabled = propertyCheckboxEnableCANCache.checked;
            controler.setEnablePteidCANCache(bEnabled);
			if(!bEnabled){
				gapi.startRemoveCANCache();
			}
			propertyButtonRemoveCANCache.enabled = bEnabled;
        }
    }
    
	propertyButtonRemoveCANCache{
		onClicked: {
            console.log("propertyButtonRemoveCANCache clicked");
            propertyBusyIndicator.running = true;
            gapi.startRemoveCANCache();
		    propertyBusyIndicator.running = false
		}
	}


    Component.onCompleted: {
        propertyMainItem.forceActiveFocus()
        updateCacheSize();

    }

    function updateCacheSize() {
        controler.getPteidCacheSize();
        controler.getScapCacheSize();
    }
}
