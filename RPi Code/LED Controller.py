Failed to register advertisement: org.freedesktop.DBus.Error.UnknownMethod: Method "RegisterAdvertisement" with signature "oa{sv}" on interface "org.bluez.LEAdvertisement1" doesn't exist

import dbus
import dbus.exceptions
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib

BLUEZ_SERVICE_NAME = "org.bluez"
GATT_MANAGER_IFACE = "org.bluez.GattManager1"
DBUS_OM_IFACE = "org.freedesktop.DBus.ObjectManager"
DBUS_PROP_IFACE = "org.freedesktop.DBus.Properties"

class Advertisement(dbus.service.Object):
    PATH_BASE = '/org/bluez/example/advertisement'

    def __init__(self, bus, index, adv_type):
        self.path = self.PATH_BASE + str(index)
        self.bus = bus
        self.ad_type = adv_type
        self.service_uuids = None
        self.manufacturer_data = None
        self.solicit_uuids = None
        self.service_data = None
        self.local_name = None
        self.include_tx_power = False
        self.data = None
        self.discoverable = True
        dbus.service.Object.__init__(self, bus, self.path)

    def get_properties(self):
        properties = dict()
        properties['Type'] = self.ad_type
        if self.service_uuids:
            properties['ServiceUUIDs'] = dbus.Array(self.service_uuids, signature='s')
        if self.manufacturer_data:
            properties['ManufacturerData'] = dbus.Dictionary(self.manufacturer_data, signature='qv')
        if self.solicit_uuids:
            properties['SolicitUUIDs'] = dbus.Array(self.solicit_uuids, signature='s')
        if self.service_data:
            properties['ServiceData'] = dbus.Dictionary(self.service_data, signature='sv')
        if self.local_name:
            properties['LocalName'] = dbus.String(self.local_name)
        if self.include_tx_power:
            properties['IncludeTxPower'] = dbus.Boolean(self.include_tx_power)
        if self.data:
            properties['Data'] = dbus.Dictionary(self.data, signature='yv')
        properties['Discoverable'] = dbus.Boolean(self.discoverable)
        return {'org.bluez.LEAdvertisement1': properties}

    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='s', out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != 'org.bluez.LEAdvertisement1':
            raise dbus.exceptions.DBusException(
                'org.freedesktop.DBus.Error.InvalidArgs: Invalid interface')
        return self.get_properties()['org.bluez.LEAdvertisement1']

    @dbus.service.method('org.bluez.LEAdvertisement1', in_signature='', out_signature='')
    def Release(self):
        print('%s: Released!' % self.path)

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_service_uuid(self, uuid):
        if not self.service_uuids:
            self.service_uuids = []
        self.service_uuids.append(uuid)

    def add_service_data(self, uuid, data):
        if not self.service_data:
            self.service_data = dbus.Dictionary({}, signature='sv')
        self.service_data[uuid] = dbus.Array(data, signature='y')

    def add_manufacturer_data(self, manufacturer_id, data):
        if not self.manufacturer_data:
            self.manufacturer_data = dbus.Dictionary({}, signature='qv')
        self.manufacturer_data[manufacturer_id] = dbus.Array(data, signature='y')

    def add_solicit_uuid(self, uuid):
        if not self.solicit_uuids:
            self.solicit_uuids = []
        self.solicit_uuids.append(uuid)

class Application(dbus.service.Object):
    def __init__(self, bus):
        self.path = '/'
        self.services = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_service(self, service):
        self.services.append(service)
        print(f"Service {service.uuid} added")

    @dbus.service.method('org.freedesktop.DBus.ObjectManager', out_signature='a{oa{sa{sv}}}')
    def GetManagedObjects(self):
        response = {}
        for service in self.services:
            response[service.get_path()] = service.get_properties()
            chrcs = service.get_characteristics()
            for chrc in chrcs:
                response[chrc.get_path()] = chrc.get_properties()
        print("GetManagedObjects called")
        return response

class Service(dbus.service.Object):
    PATH_BASE = '/org/bluez/example/service'

    def __init__(self, bus, index, uuid, primary):
        self.path = self.PATH_BASE + str(index)
        self.bus = bus
        self.uuid = uuid
        self.primary = primary
        self.characteristics = []
        dbus.service.Object.__init__(self, bus, self.path)
        print(f"Service {self.uuid} created at {self.path}")

    def get_properties(self):
        return {
            'org.bluez.GattService1': {
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
        print(f"Characteristic {characteristic.uuid} added to service {self.uuid}")

    def get_characteristic_paths(self):
        result = []
        for chrc in self.characteristics:
            result.append(chrc.get_path())
        return result

    def get_characteristics(self):
        return self.characteristics

    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='s', out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != 'org.bluez.GattService1':
            raise dbus.exceptions.DBusException(
                'org.freedesktop.DBus.Error.InvalidArgs: Invalid interface')
        print(f"GetAll called for interface {interface}")
        return self.get_properties()['org.bluez.GattService1']

class Characteristic(dbus.service.Object):
    def __init__(self, bus, index, uuid, flags, service):
        self.path = service.path + '/char' + str(index)
        self.bus = bus
        self.uuid = uuid
        self.service = service
        self.flags = flags
        self.value = []
        dbus.service.Object.__init__(self, bus, self.path)
        print(f"Characteristic {self.uuid} created at {self.path}")

    def get_properties(self):
        return {
            'org.bluez.GattCharacteristic1': {
                'Service': self.service.get_path(),
                'UUID': self.uuid,
                'Flags': self.flags,
                'Value': dbus.Array(self.value, signature='y')
            }
        }

    def get_path(self):
        return dbus.ObjectPath(self.path)

    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='s', out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != 'org.bluez.GattCharacteristic1':
            raise dbus.exceptions.DBusException(
                'org.freedesktop.DBus.Error.InvalidArgs: Invalid interface')
        print(f"GetAll called for characteristic interface {interface}")
        return self.get_properties()['org.bluez.GattCharacteristic1']

    @dbus.service.method('org.bluez.GattCharacteristic1', in_signature='a{sv}', out_signature='ay')
    def ReadValue(self, options):
        print('ReadValue called')
        return self.value

    @dbus.service.method('org.bluez.GattCharacteristic1', in_signature='aya{sv}')
    def WriteValue(self, value, options):
        print('WriteValue called')
        print('New value:', bytes(value).decode())
        self.value = value
        # Notify the central device of the new value
        self.PropertiesChanged('org.bluez.GattCharacteristic1', {"Value": self.value}, [])
        print(f"Characteristic {self.uuid} value updated to {self.value}")

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
        self.value = [0x00]

    def ReadValue(self, options):
        print('Read LED Controller Characteristic')
        return self.value

    def WriteValue(self, value, options):
        print('Write LED Controller Characteristic')
        print('New value:', bytes(value).decode())
        self.value = value
        # Here you can add logic to control your LED or perform other actions
        # based on the received data
        self.PropertiesChanged(GATT_CHRC_IFACE, {"Value": self.value}, [])
        print(f"LED Controller Characteristic value updated to {self.value}")

class LEDControllerAdvertisement(Advertisement):
    def __init__(self, bus, index):
        Advertisement.__init__(self, bus, index, 'peripheral')
        self.add_service_uuid(LEDControllerService.LED_CONTROLLER_UUID)
        self.include_tx_power = True

def register_app_cb():
    print('GATT application registered')

def register_app_error_cb(error):
    print('Failed to register application:', str(error))
    mainloop.quit()

def register_ad_cb():
    print('Advertisement registered')

def register_ad_error_cb(error):
    print('Failed to register advertisement:', str(error))
    mainloop.quit()

def find_adapter(bus):
    remote_om = dbus.Interface(bus.get_object(BLUEZ_SERVICE_NAME, "/"),
                               DBUS_OM_IFACE)
    objects = remote_om.GetManagedObjects()

    for o, props in objects.items():
        if GATT_MANAGER_IFACE in props.keys():
            print(f"BLE adapter found: {o}")
            return o

    return None

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
    ad_manager = dbus.Interface(
        bus.get_object(BLUEZ_SERVICE_NAME, adapter),
        'org.bluez.LEAdvertisement1')

    app = Application(bus)
    app.add_service(LEDControllerService(bus, 0))

    adv = LEDControllerAdvertisement(bus, 0)

    mainloop = GLib.MainLoop()

    print('Registering GATT application...')
    service_manager.RegisterApplication(app.get_path(), {},
                                        reply_handler=register_app_cb,
                                        error_handler=register_app_error_cb)

    print('Registering advertisement...')
    ad_manager.RegisterAdvertisement(adv.get_path(), dbus.Dictionary({}, signature='sv'),
                                     reply_handler=register_ad_cb,
                                     error_handler=register_ad_error_cb)

    mainloop.run()

if __name__ == '__main__':
    main()
