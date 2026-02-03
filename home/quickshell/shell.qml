import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        id: bar
        
        anchors {
            top: true
            left: true
            right: true
        }
        
        height: 32
        color: "#1e1e2e"
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
                
                Text {
                    text: "niri"
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
            
            Row {
                anchors.centerIn: parent
                spacing: 10
                
                Text {
                    id: clock
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: {
                            clock.text = Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
                        }
                    }
                }
            }
            
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
                
                Text {
                    text: "󰕾"
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
    }
}
