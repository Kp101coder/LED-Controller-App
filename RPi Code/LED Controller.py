Registering GATT application...
ERROR:dbus.service:Unable to append ({dbus.ObjectPath('/org/bluez/example/service0'): {'org.bluez.GattService1': {'UUID': '7a6307c9-5be7-4747-a8b6-51a6cb9b285c', 'Primary': True, 'Characteristics': dbus.Array([dbus.ObjectPath('/org/bluez/example/service0/char0')], signature=dbus.Signature('o'))}}, dbus.ObjectPath('/org/bluez/example/service0/char0'): {'org.bluez.GattCharacteristic1': {'Service': dbus.ObjectPath('/org/bluez/example/service0'), 'UUID': 'ddbf3449-9275-42e5-9f4f-6058fabca551', 'Flags': ['read', 'write'], 'Value': []}}},) to message with signature a{oa{sa{sv}}}: <class 'ValueError'>: Unable to guess signature from an empty list
Failed to register application: org.bluez.Error.Failed: No object received

import dbus
import dbus.exceptions
import dbus.mainloop.glib
import dbus.service

from gi.repository import GLib

BLUEZ_SERVICE_NAME = "org.bluez"
GATT_MANAGER_IFACE = "org.bluez.GattManager1"
DBUS_OM_IFACE = "org.freedesktop.DBus.ObjectManager"
DBUS_PROP_IFACE = "org.freedesktop.DBus.Properties"

GATT_SERVICE_IFACE = "org.bluez.GattService1"
GATT_CHRC_IFACE = "org.bluez.GattCharacteristic1"

class InvalidArgsException(dbus.exceptions.DBusException):
    _dbus_error_name = "org.freedesktop.DBus.Error.InvalidArgs"

class NotSupportedException(dbus.exceptions.DBusException):
    _dbus_error_name = "org.bluez.Error.NotSupported"

class Application(dbus.service.Object):
    def __init__(self, bus):
        self.path = "/"
        self.services = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_service(self, service):
        self.services.append(service)

    @dbus.service.method(DBUS_OM_IFACE, out_signature="a{oa{sa{sv}}}")
    def GetManagedObjects(self):
        response = {}
        for service in self.services:
            response[service.get_path()] = service.get_properties()
            chrcs = service.get_characteristics()
            for chrc in chrcs:
                response[chrc.get_path()] = chrc.get_properties()
        return response

class Service(dbus.service.Object):
    PATH_BASE = "/org/bluez/example/service"

    def __init__(self, bus, index, uuid, primary):
        self.path = self.PATH_BASE + str(index)
        self.bus = bus
        self.uuid = uuid
        self.primary = primary
        self.characteristics = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_properties(self):
        return {
            GATT_SERVICE_IFACE: {
                'UUID': self.uuid,
                'Primary': self.primary,
                'Characteristics': dbus.Array(
                    self.get_characteristic_paths(),
                    signature='o')
            }
        }

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_characteristic(self, characteristic):
        self.characteristics.append(characteristic)

    def get_characteristic_paths(self):
        result = []
        for chrc in self.characteristics:
            result.append(chrc.get_path())
        return result

    def get_characteristics(self):
        return self.characteristics

    @dbus.service.method(DBUS_PROP_IFACE,
                         in_signature='s',
                         out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != GATT_SERVICE_IFACE:
            raise InvalidArgsException()
        return self.get_properties()[GATT_SERVICE_IFACE]

class Characteristic(dbus.service.Object):
    def __init__(self, bus, index, uuid, flags, service):
        self.path = service.path + '/char' + str(index)
        self.bus = bus
        self.uuid = uuid
        self.service = service
        self.flags = flags
        self.value = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_properties(self):
        return {
            GATT_CHRC_IFACE: {
                'Service': self.service.get_path(),
                'UUID': self.uuid,
                'Flags': self.flags,
                'Value': self.value,
            }
        }

    def get_path(self):
        return dbus.ObjectPath(self.path)

    @dbus.service.method(DBUS_PROP_IFACE,
                         in_signature='s',
                         out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != GATT_CHRC_IFACE:
            raise InvalidArgsException()
        return self.get_properties()[GATT_CHRC_IFACE]

    @dbus.service.method(GATT_CHRC_IFACE, in_signature='a{sv}', out_signature='ay')
    def ReadValue(self, options):
        print('ReadValue called')
        return self.value

    @dbus.service.method(GATT_CHRC_IFACE, in_signature='aya{sv}')
    def WriteValue(self, value, options):
        print('WriteValue called')
        print('New value:', bytes(value))
        self.value = value

class LEDControllerService(Service):
    LED_CONTROLLER_UUID = "7a6307c9-5be7-4747-a8b6-51a6cb9b285c"

    def __init__(self, bus, index):
        Service.__init__(self, bus, index, self.LED_CONTROLLER_UUID, True)
        self.add_characteristic(LEDControllerCharacteristic(bus, 0, self))

class LEDControllerCharacteristic(Characteristic):
    LED_CONTROLLER_CHARACTERISTIC_UUID = "ddbf3449-9275-42e5-9f4f-6058fabca551"

    def __init__(self, bus, index, service):
        Characteristic.__init__(
            self, bus, index,
            self.LED_CONTROLLER_CHARACTERISTIC_UUID,
            ['read', 'write'],
            service)

    def ReadValue(self, options):
        print('Read LED Controller Characteristic')
        return [ord(c) for c in "Hello from Raspberry Pi"]

    def WriteValue(self, value, options):
        print('Write LED Controller Characteristic')
        print('New value:', bytes(value).decode())
        # Here you can add logic to control your LED or perform other actions
        # based on the received data

def register_app_cb():
    print('GATT application registered')

def register_app_error_cb(error):
    print('Failed to register application:', str(error))
    global mainloop
    mainloop.quit()

def main():
    global mainloop
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    adapter = find_adapter(bus)

    if not adapter:
        print('BLE adapter not found')
        return

    service_manager = dbus.Interface(
        bus.get_object(BLUEZ_SERVICE_NAME, adapter),
        GATT_MANAGER_IFACE)

    app = Application(bus)
    app.add_service(LEDControllerService(bus, 0))

    mainloop = GLib.MainLoop()

    print('Registering GATT application...')

    service_manager.RegisterApplication(app.get_path(), {},
                                        reply_handler=register_app_cb,
                                        error_handler=register_app_error_cb)

    mainloop.run()

def find_adapter(bus):
    remote_om = dbus.Interface(bus.get_object(BLUEZ_SERVICE_NAME, "/"),
                               DBUS_OM_IFACE)
    objects = remote_om.GetManagedObjects()

    for o, props in objects.items():
        if GATT_MANAGER_IFACE in props.keys():
            return o

    return None

if __name__ == '__main__':
    main()
