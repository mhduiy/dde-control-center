cmake_minimum_required(VERSION 3.18)
set(Personalization_Name personalization)
file(GLOB_RECURSE Personalization_SRCS
    "operation/*.cpp"
    "operation/*.h"
    "operation/qrc/personalization.qrc"
)

add_library(${Personalization_Name} MODULE
    ${Personalization_SRCS}
)

set(Personalization_Libraries
    ${DTK_NS}::Gui
    ${QT_NS}::DBus
    ${QT_NS}::Concurrent
)

target_link_libraries(${Personalization_Name} PRIVATE
    ${Personalization_Libraries}
)

dcc_install_plugin(NAME ${Personalization_Name} TARGET ${Personalization_Name})
