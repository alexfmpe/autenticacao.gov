/*-****************************************************************************

 * Copyright (C) 2017-2018 Adriano Campos - <adrianoribeirocampos@gmail.com>
 * Copyright (C) 2017 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2019 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.6

/* Constants imports */
import "../scripts/Constants.js" as Constants

Column {
    width: parent.width
    height: parent.height

    property alias model: columnRepeater.model
    property var dataModel

    Repeater {
        id: columnRepeater
        delegate: accordion
    }

    Component {
        id: accordion
        Column {
            width: parent.width

            Rectangle {
                id: infoRow
                width: parent.width
                height: childrenRect.height +  0.5*Constants.SIZE_TEXT_FIELD
                property bool expanded: true

                MouseArea {
                    anchors.fill: carot
                    onClicked: infoRow.expanded = !infoRow.expanded
                    enabled: modelData.children ? true : false
                }

                Image {
                    id: carot

                    anchors.left: parent.left
                    y: Constants.SIZE_IMAGE_ARROW_ACCORDION * 0.5

                    sourceSize.width: Constants.SIZE_IMAGE_ARROW_ACCORDION
                    sourceSize.height: Constants.SIZE_IMAGE_ARROW_ACCORDION
                    source: '../images/arrow-right_AMA.png'
                    visible: modelData.children ? true : false
                    transform: Rotation {
                        origin.x: Constants.SIZE_IMAGE_ARROW_ACCORDION * 0.5
                        origin.y: Constants.SIZE_IMAGE_ARROW_ACCORDION * 0.5
                        angle: infoRow.expanded ? 90 : 0
                        Behavior on angle { NumberAnimation { duration: 150 } }
                    }
                }

                Text {
                    id: textItem
                    anchors {
                        left: carot.visible ? carot.right : parent.left
                        top: parent.top
                        margins: Constants.SIZE_TEXT_FIELD * 0.5
                    }
                    visible: parent.visible
                    font.pixelSize: Constants.SIZE_TEXT_FIELD
                    font.family: lato.name
                    color: if(checkOptionSelected(modelData)){
                               Constants.COLOR_MAIN_BLUE
                           }else{
                               Constants.COLOR_TEXT_BODY
                           }

                    font.weight: if(checkOptionSelected(modelData)){
                                     Font.Bold
                                 }else{
                                     mouseAreaText.containsMouse ?
                                                 Font.Bold :
                                                 Font.Normal
                                 }
                    text: modelData.entity

                    MouseArea {
                        id: mouseAreaText
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            enabled: modelData.children ? true : false
                            selectOption(modelData)
                        }
                    }
                }
            }

            ListView {
                id: subentryColumn
                x: 20
                width: parent.width - x
                height: childrenRect.height * opacity
                visible: opacity > 0
                opacity: infoRow.expanded ? 1 : 0
                delegate: accordion
                model: modelData.children ? modelData.children : []
                interactive: true
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

    }
    function checkOptionSelected(modelData){

        if(textEntity.propertyDateField.text === modelData.entity &&
                textAuth.propertyDateField.text === modelData.auth &&
                textValid.propertyDateField.text === modelData.valid  &&
                textUntil.propertyDateField.text === modelData.until &&
                textKey.propertyDateField.text === modelData.key &&
                textSerialNumber.propertyDateField.text === modelData.serial &&
                textStatus.propertyDateField.text === modelData.status
                ){
            return true

        }else{
            return false
        }
    }
    function selectOption(modelData){
        dataModel = modelData
        textEntity.propertyDateField.text= modelData.entity
        textAuth.propertyDateField.text  = modelData.auth
        textValid.propertyDateField.text = modelData.valid 
        textUntil.propertyDateField.text = modelData.until
        textKey.propertyDateField.text   = modelData.key
        textSerialNumber.propertyDateField.text = modelData.serial
        textStatus.propertyDateField.text= modelData.status
    }
}
