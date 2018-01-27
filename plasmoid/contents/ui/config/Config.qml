/*
 * Copyright (C) 2017 by David Baum <david.baum@naraesk.eu>
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
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Item {
    property var cfg_services: []

    id: root
    width: parent.width
    height: parent.height

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
        RowLayout {
            id: layout
            Layout.fillWidth: true
            width: parent.width

            Label {
                text: i18n('Service name')
                Layout.alignment: Qt.AlignRight
            }

            TextField {
                id: name
                Layout.fillWidth: true
                placeholderText: "service name"
            }

            Button {
                iconName: "list-add"
                onClicked: {
                    var object = ({'service': name.text})
                    addService(object)
                    name.text = ""
                }
            }
       }

       ListModel {
            id: serviceModel
        }

        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                width: parent.width
                model: serviceModel

                delegate: RowLayout {

                    Label {
                        Layout.fillWidth: true
                        text: model.service
                    }

                    Button {
                        id: removeServiceButton
                        iconName: "list-remove"
                        onClicked: removeService(model.index)
                    }

                    Button {
                        id: moveup
                        iconName: "arrow-up"
                        onClicked: up(model.index)
                    }

                    Button {
                        id: movedown
                        iconName: "arrow-down"
                        onClicked: down(model.index)
                    }
                }
            }
        }
    }
}
