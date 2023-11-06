/*-****************************************************************************

 * Copyright (C) 2017 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2017-2021 Adriano Campos - <adrianoribeirocampos@gmail.com>
 * Copyright (C) 2019 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

import QtQuick 2.6
import QtQuick.Window 2.2

/* Constants imports */
import "../scripts/Constants.js" as Constants

Rectangle {
    id: pdfPreview

    signal updateSealData()

    property real propertyFontSize: 0
    property real propertyFontMargin: 0

    property alias propertyBackground: background_image
    property alias propertyDragSigRect: dragSigRect
    property alias propertyDragSigReasonText: sigReasonText
    property alias propertyDragSigSignedByText: sigSignedByText
    property alias propertyDragSigSignedByNameText: sigSignedByNameText
    property alias propertyDragSigNumIdText: sigNumIdText
    property alias propertyDragSigDateText: sigDateText
    property alias propertyDragSigLocationText: sigLocationText
    property alias propertyDragSigImg: dragSigImage
    property alias propertyDragSigWaterImg: dragSigWaterImage
    property alias propertyDragSigCertifiedByText: sigCertifiedByText
    property alias propertyDragSigAttributesText: sigAttributesText
    property alias propertycontainerMouseMovCalcBottom: containerMouseMovCalcBottom
    property alias propertycontainerMouseMovCalcRight: containerMouseMovCalcRight

    property real propertySigLineHeight: dragSigRect.height * 0.1
    property bool propertyReducedChecked: false

    property alias propertyCoordX: dragTarget.coord_x
    property alias propertyCoordY: dragTarget.coord_y

    // Properties used to convert to postscript points
    property real propertyConvertPtsToPixel:  (1/72.0) * 300.0

    property real propertySealWidthTemp: 0 
    property real propertySealHeightTemp: 0 

    property real propertySigWidthDefault: Constants.SIG_WIDTH_DEFAULT * propertyConvertPtsToPixel
    property real propertySigWidthReducedDefault: Constants.SIG_WIDTH_DEFAULT * propertyConvertPtsToPixel
    property real propertySigHeightDefault: Constants.SIG_HEIGHT_DEFAULT * propertyConvertPtsToPixel
    property real propertySigHeightReducedDefault: Constants.SIG_HEIGHT_REDUCED * propertyConvertPtsToPixel

    property real propertySigWidthMin: Constants.SIG_WIDTH_MINIMUM * propertyConvertPtsToPixel
    property real propertySigHeightMin: Constants.SIG_HEIGHT_MINIMUM * propertyConvertPtsToPixel

    property real propertyPDFScaleFactor: 0
    property real propertyLastPDFScaleFactor: 0

    // The files used in preview seal and draw seal are not the same so we have some differences.
    // From Catalog.cc: 
    // #define HEIGHT_WATER_MARK_IMG   32  // Round up 31.5
    // #define HEIGHT_SIGN_IMG         31.0      // Round up 30.87 (CC) or 31.00 (CMD)
    property real propertyWaterMarkImgHeight:   31.5 * propertyConvertPtsToPixel
    property real propertySignImgHeight:        30.87 * propertyConvertPtsToPixel

    property real propertySigFontSizeBig: 8 * propertyConvertPtsToPixel * propertyPDFScaleFactor
    property real propertySigFontSizeSmall: 6 * propertyConvertPtsToPixel * propertyPDFScaleFactor
    property real propertyCurrentAttrsFontSize: 8 * propertyConvertPtsToPixel * propertyPDFScaleFactor

    //Properties to store Pdf original size
    property real propertyPdfOriginalWidth: 0
    property real propertyPdfOriginalHeight: 0

    property real stepSizeX : width * 0.1
    property real stepSizeY : height * 0.1

    property bool sealHasChanged: false
    property bool smallFile: false
    property bool loaded_persistent_options: false
    property bool isSignReduced: false
    property string propertyFileName: ""

    color: Constants.COLOR_MAIN_SOFT_GRAY

    FontLoader {
        id: myriad
        name: "MyriadPro"
        source: controler.getFontFile("myriad")
    }

    Keys.onUpPressed: {
        moveUp(stepSizeY)
        toggleFocus()
    }

    Keys.onDownPressed: {
        moveDown(stepSizeY)
        toggleFocus()
    }

    Keys.onLeftPressed: {
        moveLeft(stepSizeX)
        toggleFocus()
    }

    Keys.onRightPressed: {
        moveRight(stepSizeX)
        toggleFocus()
    }

    Text {
        id: positionText
        text: "X " + Math.round(dragTarget.coord_x*100) + "% " + "Y " + Math.round(dragTarget.coord_y*100) + "%"
        visible: false
        Accessible.role: Accessible.StaticText
        Accessible.name: text
    }

    Accessible.role: Accessible.Canvas
    Accessible.name: qsTranslate("PageServicesSign", "STR_SIGN_NAV_FILE_PREVIEW")
                     + propertyFileName + "."
                     + qsTranslate("PageServicesSign", "STR_SIGN_NAV_DESCRIPTION")

    DropArea {
        id: dragTarget
        width: parent.width
        height: parent.height

        //Properties to store current signature position
        property real coord_x : 0
        property real coord_y : 0

        //Properties to store last signature positions
        property real lastCoord_x : 0
        property real lastCoord_y : 0

        //Properties to store last screen size
        property real lastScreenWidth : 0
        property real lastScreenHeight : 0

        //Properties to store last screen size
        property real lastWidth : 0
        property real lastHeight : 0
        Rectangle {
            id: smallFileWarning
            width: parent.width
            height: Constants.SIZE_TEXT_BODY * 3
            color: Constants.COLOR_LINE_SUB_MENU
            z: 1
            visible: smallFile

            Text {
                width: parent.width
                height: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.bold: true
                font.pixelSize: Constants.SIZE_TEXT_BODY
                font.family: lato.name
                color: Constants.COLOR_TEXT_LABEL
                text: qsTranslate("PageServicesSign","STR_SIGN_NOT_PREVIEW_PDF_TOO_SMALL")
            }
        }

        Image {
            id: background_image
            sourceSize.width: dragTarget.width
            sourceSize.height: dragTarget.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            asynchronous: true

            onStatusChanged: if (background_image.status == Image.Ready) {
                propertyLastPDFScaleFactor = propertyPDFScaleFactor
                propertyPDFScaleFactor = background_image.width / propertyPdfOriginalWidth 
                if (loaded_persistent_options) {
                    dragSigRect.width = propertySealWidthTemp * propertyConvertPtsToPixel * propertyPDFScaleFactor 
                    dragSigRect.height = propertySealHeightTemp * propertyConvertPtsToPixel * propertyPDFScaleFactor
                    loaded_persistent_options = false
                }

                var new_x = propertyPageLoader.propertyBackupCoordX * background_image.width
                var new_y = (propertyPageLoader.propertyBackupCoordY * background_image.height)
                setSignPreview(new_x, Math.max(new_y, 0))

                updateSealPreview()
                dragTarget.lastScreenWidth = background_image.width
                dragTarget.lastScreenHeight = background_image.height
            }

            Rectangle {
                width: dragSigRect.width + 2 * Constants.FOCUS_BORDER
                height: dragSigRect.height + 2 * Constants.FOCUS_BORDER
                x: dragSigRect.x - Constants.FOCUS_BORDER
                y: dragSigRect.y - Constants.FOCUS_BORDER
                border.width: Constants.FOCUS_BORDER
                border.color: pdfPreview.activeFocus || positionText.activeFocus ? Constants.COLOR_MAIN_DARK_GRAY
                             : Constants.COLOR_GREY_BUTTON_BACKGROUND
                color: "transparent"
                visible: width >= Constants.FOCUS_BORDER && background_image.status != Image.Null && dragSigRect.visible
            }
            Item {
                id: dragSigRect
                width: propertyReducedChecked ? propertySigWidthReducedDefault * propertyPDFScaleFactor : propertySigWidthDefault * propertyPDFScaleFactor
                height: propertyReducedChecked ? propertySigHeightReducedDefault * propertyPDFScaleFactor : propertySigHeightDefault * propertyPDFScaleFactor
                visible: propertyCheckSignShow.checked && !smallFile && propertyRadioButtonPADES.checked
                Drag.active: dragArea.drag.active
                opacity: background_image.status == Image.Ready ? 1.0 : 0.0

                Item {
                    id: containerMouseMovCalcRight
                    z:10
                    width: Constants.FOCUS_BORDER; height: parent.height
                    anchors.left: parent.right
                    clip: false
                    enabled: !propertyCheckSignReduced.checked

                    MouseArea {
                        id: mouseRegioncontainerMouseMovCalcRight
                        anchors.fill: parent

                        property variant lastPos: ""

                        cursorShape: Qt.SizeHorCursor

                        onPressed: lastPos = controler.getCursorPos()

                        onPositionChanged: {

                            var newPos = controler.getCursorPos()
                            var delta = Qt.point(newPos.x-lastPos.x, newPos.y-lastPos.y)

                            var diff = (background_image.width - background_image.width) / 2
                            if (dragSigRect.x + dragSigRect.width + delta.x > background_image.width) {
                                dragSigRect.width = dragSigRect.width
                            }
                            else if(dragSigRect.width+delta.x > (propertySigWidthMin) * propertyPDFScaleFactor){
                                dragSigRect.width = dragSigRect.width+delta.x
                            }
                            else {
                                dragSigRect.width = (propertySigWidthMin) * propertyPDFScaleFactor
                            }
                            lastPos = newPos;
                        }

                        onReleased: {
                            pdfPreview.updateSealData();
                        }
                    }
                }

                Item {
                    id: containerMouseMovCalcBottom
                    z:10
                    width: parent.width ; height: Constants.FOCUS_BORDER
                    anchors.top: dragSigRect.bottom
                    clip: false
                    enabled: !propertyCheckSignReduced.checked

                    MouseArea {
                        id: mouseRegioncontainerMouseMovCalcBottom
                        anchors.fill: parent

                        property variant lastPos: ""

                        cursorShape: Qt.SizeVerCursor

                        onPressed: lastPos = controler.getCursorPos()
                            
                        onPositionChanged: {

                            var newPos = controler.getCursorPos()
                            var delta = Qt.point(newPos.x-lastPos.x, newPos.y-lastPos.y)

                            if (dragSigRect.y + dragSigRect.height + delta.y > background_image.height) {
                                dragSigRect.height = dragSigRect.height
                            }
                            else if(dragSigRect.height+delta.y > (propertySigHeightMin) * propertyPDFScaleFactor){
                                dragSigRect.height = (dragSigRect.height+delta.y)
                            }else{
                                dragSigRect.height = (propertySigHeightMin) * propertyPDFScaleFactor
                            }

                            dragSigImage.visible = dragSigRect.height >= dragSigImage.height + dragSigWaterImage.height

                            lastPos = newPos;
                        }

                        onReleased: {
                            pdfPreview.updateSealData();
                        }
                    }
                }

                Item {
                    id: clippableArea
                    height: parent.height; width: parent.width
                    anchors.fill: parent
                    clip: true

                    Image {
                        id: dragSigWaterImage
                        height: propertyWaterMarkImgHeight * propertyPDFScaleFactor
                        fillMode: Image.PreserveAspectFit
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        source: "qrc:/images/pteid_signature_watermark.jpg"
                        x: 1
                    }

                    Image {
                        id: dragSigImage
                        height: propertyReducedChecked ? 0 : propertySignImgHeight * propertyPDFScaleFactor
                        fillMode: Image.PreserveAspectFit
                        anchors.top: dragSigWaterImage.bottom
                        anchors.topMargin: parent.height - dragSigWaterImage.height - dragSigImage.height
                        cache: false
                        visible: false
                        x: 1
                        Rectangle {
                            color: "white"
                            height: parent.height
                            width: parent.width
                            anchors.fill: parent
                            z: parent.z - 1 
                        }
                    }

                    Text {
                        id: sigReasonText
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        font.italic: true
                        height: sigReasonText.contentWidth == 0
                                ? 0
                                : (sigReasonText.lineCount > 1
                                ? 2 * font.pixelSize + Constants.SIZE_SIGN_SEAL_TEXT_V_SPACE
                                : font.pixelSize + Constants.SIZE_SIGN_SEAL_TEXT_V_SPACE)
                        width: parent.width - 4
                        clip: true
                        font.family: myriad.name
                        color: Constants.COLOR_TEXT_LABEL
                        text: ""
                        anchors.top: parent.top
                        anchors.topMargin: propertyFontMargin
                        x: 2
                        wrapMode: Text.Wrap 
                    }

                    Text {
                        id: sigSignedByText
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        height: font.pixelSize + Constants.SIZE_SIGN_SEAL_TEXT_V_SPACE
                        font.family: myriad.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: propertyReducedChecked ? parent.top : sigReasonText.bottom
                        anchors.topMargin: propertyReducedChecked ? propertyFontMargin : 0
                        clip: true
                        text: ""
                        x: 2
                    }
                    Text {
                        id: sigSignedByNameText
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        font.family: myriad.name
                        width: parent.width
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: propertyReducedChecked ? parent.top : sigReasonText.bottom 
                        anchors.topMargin: propertyReducedChecked ? propertyFontMargin : 0
                        anchors.left: sigSignedByText.right
                        clip: true
                        text: ""
                        x: 2
                    }
                    Text {
                        id: sigNumIdText
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        height: font.pixelSize + Constants.SIZE_SIGN_SEAL_TEXT_V_SPACE
                        width: parent.width - 4
                        clip: true
                        font.family: myriad.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigSignedByNameText.bottom
                        text: ""
                        x: 2
                    }
                    Text {
                        id: sigDateText
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        height: font.pixelSize + Constants.SIZE_SIGN_SEAL_TEXT_V_SPACE
                        width: parent.width - 4
                        clip: true
                        font.family: myriad.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigNumIdText.visible ? sigNumIdText.bottom : sigSignedByNameText.bottom
                        text: qsTranslate("PageServicesSign", "STR_SIGN_DATE") + ": " + getData()
                        x: 2
                    }
                    Text {
                        id: sigLocationText
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        width: parent.width - 4
                        clip: true
                        font.family: myriad.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigDateText.visible ? sigDateText.bottom : sigNumIdText.visible ? sigNumIdText.bottom : sigSignedByNameText.bottom
                        text: ""
                        x: 2
                    }
                    Text {
                        id: sigCertifiedByText
                        width: parent.width
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        visible: false
                        font.family: myriad.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigLocationText.text != "" ? sigLocationText.bottom : sigDateText.visible ? sigDateText.bottom : sigNumIdText.visible ? sigNumIdText.bottom : sigSignedByNameText.bottom
                        clip: true
                        text: qsTranslate("PageServicesSign","STR_SCAP_CERTIFIED_BY")
                        x: 2
                    }
                    Text {
                        id: sigAttributesText
                        width: parent.width
                        font.pixelSize: propertyFontSize * propertyConvertPtsToPixel * propertyPDFScaleFactor
                        lineHeight: 0.8 // smaller line spacing to match real seal
                        visible: false
                        font.family: myriad.name
                        color: Constants.COLOR_TEXT_BODY
                        anchors.top: sigCertifiedByText.bottom
                        anchors.bottom: parent.bottom
                        clip: true
                        text: qsTranslate("PageServicesSign","STR_SCAP_CERTIFIED_ATTRIBUTES")
                        x: 2
                    }
                }

                MouseArea {
                    id: dragArea
                    width: dragSigRect.width + dragSigMoveImage.width * 0.5
                    height: dragSigRect.height + dragSigMoveImage.height * 0.5
                    onReleased: {
                        parent.Drag.drop()
                        saveSealPosition()
                    }
                    drag.target: parent
                    drag.axis: Drag.XAndYAxis
                    drag.minimumX: 0
                    drag.maximumX: background_image.width - dragSigRect.width
                    drag.minimumY: 0
                    drag.maximumY: background_image.height - dragSigRect.height
                }
                onHeightChanged: {
                    dragTarget.coord_x = (dragSigRect.x) / background_image.width
                    dragTarget.coord_y = (dragSigRect.y + dragSigRect.height) / background_image.height

                    if ((dragSigRect.x + dragSigRect.width) > background_image.width
                            || (dragSigRect.y + dragSigRect.height) > background_image.height) {
                        dragSigRect.x = background_image.width - dragSigRect.width
                        dragSigRect.y = background_image.height - dragSigRect.height
                    }

                    if (propertyReducedChecked) {
                        propertySigLineHeight = propertyDragSigRect.height * 0.2
                    } else {
                        propertySigLineHeight = propertyDragSigRect.height * 0.1
                    }
                }
            }

            Image {
                id: dragSigMoveImage
                height: Constants.SIZE_IMAGE_SEAL_MOVE
                width: Constants.SIZE_IMAGE_SEAL_MOVE
                anchors.verticalCenter: dragSigRect.bottom
                anchors.horizontalCenter: dragSigRect.left

                visible: fileLoaded && dragSigRect.visible
                source: "qrc:/images/icons-move.png"
            }

            Image {
                id: dragSigResizeImage
                height: Constants.SIZE_IMAGE_SEAL_RESIZE
                width: Constants.SIZE_IMAGE_SEAL_RESIZE
                anchors.verticalCenter: dragSigRect.bottom
                anchors.horizontalCenter: dragSigRect.right

                visible: fileLoaded && dragSigRect.visible
                enabled: !propertyCheckSignReduced.checked
                source: enabled ? "qrc:/images/icons-resize.png" : "qrc:/images/icons-resize-disabled.png"
            }

            onWidthChanged: {
                dragSigRect.x = dragTarget.lastCoord_x / dragTarget.lastScreenWidth * background_image.width
                dragSigRect.y = dragTarget.lastCoord_y / dragTarget.lastScreenHeight * background_image.height

                propertyPageLoader.propertyBackupBackgroundWidth = background_image.width
                propertyPageLoader.propertyBackupBackgroundHeight = background_image.height
            }
        }
    }

    //TODO: check for small files
    //TODO: check minimum seal size
    function updateSealPreview() {
        if (!sealHasChanged || isSignReduced) {
            dragSigRect.width = propertyReducedChecked ? propertySigWidthReducedDefault * propertyPDFScaleFactor : propertySigWidthDefault * propertyPDFScaleFactor
            dragSigRect.height = propertyReducedChecked ? propertySigHeightReducedDefault * propertyPDFScaleFactor : propertySigHeightDefault * propertyPDFScaleFactor
            sealHasChanged = true
            isSignReduced = false
        }

        if (background_image.width != 0 && background_image.height != 0) {
            if (dragTarget.lastScreenWidth != 0 && dragTarget.lastScreenHeight != 0) {
                dragSigRect.width *= (propertyPDFScaleFactor / propertyLastPDFScaleFactor)
                dragSigRect.height *= (propertyPDFScaleFactor / propertyLastPDFScaleFactor)
            }

            dragSigRect.width = Math.min(dragSigRect.width, background_image.width)
            dragSigRect.height = Math.min(dragSigRect.height, background_image.height)
            
            dragSigImage.visible = dragSigRect.height >= dragSigImage.height + dragSigWaterImage.height
        }
        
        saveSealPosition()
        updateSealData()
    }

    function saveSealPosition() {
        dragTarget.coord_x = (dragSigRect.x) / background_image.width
        dragTarget.coord_y = (dragSigRect.y + dragSigRect.height) / background_image.height

        propertyPageLoader.propertyBackupCoordX = dragTarget.coord_x
        propertyPageLoader.propertyBackupCoordY = dragSigRect.y / background_image.height

        dragTarget.lastCoord_x = dragSigRect.x
        dragTarget.lastCoord_y = dragSigRect.y
    }

    function setSignPreview(droped_x, droped_y){
        dragSigRect.x = droped_x
        dragSigRect.y = droped_y
    }

    function moveUp(positions) {
        var x = dragSigRect.x
        var y = dragSigRect.y

        var outOfBounds = y - positions < 0
        var diff = outOfBounds ? Math.abs(Math.floor(0 - y)) : positions
        if (diff === 0 || y === 0) {
            return
        }

        y = y - diff
        setSignPreview(x, y)
        saveSealPosition()
    }

    function moveDown(positions) {
        var pos = dragSigRect.y + dragSigRect.height
        var outOfBounds = pos >= background_image.height

        // move down number of positions or the difference between current position and bottom of the page
        var diff = outOfBounds ? 0 : Math.min(positions, Math.floor(background_image.height - pos))
        
        // nothing to update return
        if (diff === 0) {
            return
        }

        var x = dragSigRect.x
        var y = dragSigRect.y + diff
        setSignPreview(x, y)
        saveSealPosition()
    }

    function moveLeft(positions) {
        var x = dragSigRect.x
        var y = dragSigRect.y
        var outOfBounds = x - positions < 0
        var diff = outOfBounds ? Math.abs(Math.floor(0 - x)) : positions

        if (diff === 0 || x === 0) {
            return
        }

        x = x - diff
        setSignPreview(x, y)
        saveSealPosition()
    }

    function moveRight(positions) {
        var pos = dragSigRect.x + dragSigRect.width

        var outOfBounds = pos >= background_image.width
        
        // move to the right positions or difference between current position and right side of a page
        var diff = outOfBounds ? 0 : Math.min(positions, Math.floor(background_image.width - pos))
        
        if (diff === 0) {
            return
        }

        var x = dragSigRect.x + diff
        var y = dragSigRect.y
        setSignPreview(x, y)
        saveSealPosition()
    }

    // this is a hack to make screen reader say x and y positions
    // after the user changed the position of the signature seal.
    // Other approaches included using a Slider Component
    // or Text component with Accessible.role: Accessible.Indicator however the screen reader
    // does not automatically utter the change so we had to fallback to change the focus with a Timer to utter the position
    function toggleFocus() {
        dummyText.forceActiveFocus()
        console.log("Signature Preview: " + positionText.text)
    }
    Timer {
        id: delayFocusPositionText
        interval: 20
        repeat: false
        running: false
        onTriggered: {
            positionText.forceActiveFocus()
        }
    }
    Text {
        id: dummyText
        text: ""
        visible: false
        Accessible.name: text
        onFocusChanged: if (activeFocus) delayFocusPositionText.start()
    }

    function getData(){
        var time = Qt.formatDateTime(new Date(), "yyyy.MM.dd hh:mm:ss")

        function pad(number, length){
            var str = "" + number
            while (str.length < length) {
                str = '0'+str
            }
            return str
        }

        var offset = new Date().getTimezoneOffset()
        offset = ((offset<0? '+':'-')+ // Note the reversed sign!
                  pad(parseInt(Math.abs(offset/60)), 2)+
                  pad(Math.abs(offset%60), 2))

        time += " " + offset

        return time
    }
}
