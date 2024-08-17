include(MaterialIcons)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Svg)
find_package(MaterialRally)
find_package(QtAppBase)
find_package(PkgConfig)
find_library(libUsb NAMES libusb libusb-1.0 usb usb-1.0)
find_path(libUsbInclude NAMES libusb.h)

qt_add_library(pTouch STATIC
        libpTouch/gettext.h
        libpTouch/ptouch.h
        libpTouch/ptouchwrapper.h
        libpTouch/ptouchwrapper.c
        libpTouch/libptouch.c
)

target_include_directories(pTouch PUBLIC ${libUsbInclude})
target_link_libraries(pTouch PUBLIC ${libUsb})
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    pkg_check_modules(libudev REQUIRED libudev)
    target_include_directories(pTouch PRIVATE ${libudev_INCLUDE_DIRS})
    target_link_libraries(pTouch PUBLIC ${libudev_LDFLAGS})
endif ()

qt_add_executable(pLabels
        main.cpp
)

qt_add_qml_module(pLabels
        URI
        pTouch

        SOURCES
        PrinterManager.cpp
        PrinterManager.h
        TapeModel.cpp
        TapeModel.h
        Roles.h
        Helper.h
        FontfamiliesModel.cpp
        FontfamiliesModel.h
        PrinterImage.h
        PrinterImage.cpp

        QML_FILES
        pTouch/Main.qml
        pTouch/ResizableRectangle.qml
        pTouch/ResizeGrabber.qml
        pTouch/Editor.qml
        pTouch/Landingpage.qml
        pTouch/TapeSelectDialog.qml
        pTouch/PrintDialog.qml
        pTouch/Viewport.qml
        pTouch/TextComponent.qml
        pTouch/SaveDialog.qml
        pTouch/OpenFileDialog.qml
        pTouch/ContinueDialog.qml
        pTouch/EditorToolBar.qml
        pTouch/PrinterInfoDialog.qml
)

add_material_icon_theme_resource(pLabels THEME_NAME material ICONS
        file
        file-document
        file-question
        folder-open
        content-save
        content-save-settings
        printer
        printer-check
        printer-off
        printer-alert
        alert
        delete
        text
        qrcode
        barcode
        shape
        script
        image
        close
        plus
        rotate-left-variant
        rotate-right-variant
        format-italic
        format-bold
        format-underline
        format-align-center
        format-align-left
        format-align-right
)

target_link_qml_module(pLabels PRIVATE MaterialRally)

target_include_directories(pLabels PRIVATE "libpTouch")

target_link_libraries(pLabels PRIVATE Qt6::Core PRIVATE Qt6::Gui PRIVATE Qt6::Qml PRIVATE Qt6::Quick PRIVATE Qt6::QuickControls2 PRIVATE Qt6::Svg PRIVATE QtAppBase PRIVATE pTouch)

install_app(pLabels)
