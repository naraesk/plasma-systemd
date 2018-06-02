/*
 * Copyright (C) 2018 by David Baum <david.baum@naraesk.eu>
 *
 * This file is part of plasma-systemd.
 *
 * plasma-systemd is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * plasma-systemd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with plasma-systemd.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3

Item {
    property var cfg_services: []

    id: root

    Component.onCompleted: {
        var list = plasmoid.configuration.services
        cfg_services = []
        for(var i in list) {
            addService( JSON.parse(list[i]) )
        }
    }

    function up(index, name) {
        serviceModel.move(index, index-1,1)
        var object = cfg_services.splice(index,1)
        cfg_services.splice(index-1, 0, object )
    }

    function down(index, name) {
        serviceModel.move(index, index+1,1)
        var object = cfg_services.splice(index,1)
        cfg_services.splice(index+1, 0, object)
    }

    function addService(object) {
        serviceModel.append( object )
        cfg_services.push( JSON.stringify(object) )
    }

    function removeService(index) {
        if(serviceModel.count > 0) {
            serviceModel.remove(index)
            cfg_services.splice(index,1)
        }
    }
    ColumnLayout {
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            id: layout

            Label {
                text: i18n('Service name')
                Layout.alignment: Qt.AlignRight
            }

            TextField {
                id: name
                Layout.fillWidth: true
                placeholderText: "Service name"
            }

            Label {
                text: i18n('User unit')
                Layout.alignment: Qt.AlignRight
            }

            CheckBox {
                id: userunit
            }

            Button {
                iconName: "list-add"
                text: i18n('Add service')
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    var object = ({'userunit': userunit.checked, 'service': name.text})
                    addService(object)
                    name.text = ""
                    userunit.checked = false
                }
            }
        }

        ListModel {
            id: serviceModel
        }

        TableView {
            model: serviceModel
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true
            sortIndicatorVisible: false

            TableViewColumn {
                role: "service"
                title: i18n("Service name")
                width: parent.width * 0.8
                horizontalAlignment: Text.AlignHCenter
                delegate: Component {
                    id: nameDelegate
                    Text {
                        text: styleData.value
                        color: styleData.textColor
                    }
                }
            }

            TableViewColumn {
                role: "userunit"
                title: i18n("User unit")
                width: parent.width * 0.08
                horizontalAlignment: Text.AlignHCenter
                delegate: Component {
                    id: unitDelegate
                    CheckBox {
                        checked: styleData.value
                        enabled: false
                    }
                }
            }

            TableViewColumn {
                role: "actions"
                title: i18n("Actions")
                width: parent.width * 0.1
                horizontalAlignment: Text.AlignHCenter
                delegate: Component {
                    id: actionDelegate
                    Row {
                        id: row
                        Button {
                            iconName: "list-remove"
                            onClicked: removeService(model.index)
                            height: 20
                        }

                        Button {
                            iconName: "arrow-up"
                            onClicked: up(model.index)
                            height: 20
                        }

                        Button {
                            iconName: "arrow-down"
                            onClicked: down(model.index)
                            height: 20
                        }
                    }
                }
            }
        }
    }
}
