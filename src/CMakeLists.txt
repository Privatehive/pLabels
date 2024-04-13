include(MaterialIcons)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Svg)
find_package(MaterialRally)
find_package(QtAppBase)
find_package(PkgConfig)
pkg_check_modules(libusb REQUIRED libusb-1.0)

include(AppImage)

qt_add_library(pTouch STATIC
        libpTouch/gettext.h
        libpTouch/ptouch.h
        libpTouch/ptouchwrapper.h
        libpTouch/ptouchwrapper.c
        libpTouch/libptouch.c
)

target_include_directories(pTouch PRIVATE ${libusb_INCLUDE_DIRS})
target_link_libraries(pTouch PUBLIC ${libusb_LDFLAGS})

qt_add_executable(pTouchPrint
        main.cpp
)

qt_add_qml_module(pTouchPrint
        URI
        pTouch

        SOURCES
        PrinterManager.cpp
        PrinterManager.h
        TapeModel.cpp
        TapeModel.h
        Roles.h
        Helper.h

        QML_FILES
        pTouch/main.qml
        pTouch/ResizableRectangle.qml
        pTouch/ResizeGrabber.qml
        pTouch/Editor.qml
        pTouch/Landingpage.qml
        pTouch/TapeSelectDialog.qml
        pTouch/PrintDialog.qml
        pTouch/Viewport.qml
)

add_material_icon_theme_resource(pTouchPrint THEME_NAME material ICONS
        folder-open
        content-save
        printer
        printer-check
        printer-off
        printer-alert
        alert
        text
        file
        qrcode
        barcode
        shape
        image
        close
        plus
)

target_link_qml_module(pTouchPrint PRIVATE MaterialRally)

target_include_directories(pTouchPrint PRIVATE "libpTouch")

target_link_libraries(pTouchPrint PRIVATE Qt6::Core PRIVATE Qt6::Gui PRIVATE Qt6::Qml PRIVATE Qt6::Quick PRIVATE Qt6::QuickControls2 PRIVATE Qt6::Svg PRIVATE QtAppBase PRIVATE pTouch)

install_app(pTouchPrint)
