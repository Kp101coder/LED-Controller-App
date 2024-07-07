ERROR:dbus.connection:Unable to set arguments (dbus.ObjectPath('/org/bluez/example/advertisement0'), {}) according to signature None: <class 'ValueError'>: Unable to guess signature from an empty dict
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/dbus/connection.py", line 606, in msg_reply_handler
    reply_handler(*message.get_args_list(**get_args_opts))
  File "/usr/lib/python3/dist-packages/dbus/proxies.py", line 403, in _introspect_reply_handler
    self._introspect_execute_queue()
  File "/usr/lib/python3/dist-packages/dbus/proxies.py", line 389, in _introspect_execute_queue
    proxy_method(*args, **keywords)
  File "/usr/lib/python3/dist-packages/dbus/proxies.py", line 131, in __call__
    self._connection.call_async(self._named_service,
  File "/usr/lib/python3/dist-packages/dbus/connection.py", line 586, in call_async
    message.append(signature=signature, *args)
ValueError: Unable to guess signature from an empty dict
import dbus
import dbus.exceptions
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib
from advertisement import Advertisement
from gatt_server import Application, Service, Characteristic

BLUEZ_SERVICE_NAME = "org.bluez"
GATT_MANAGER_IFACE = "org.bluez.GattManager1"
DBUS_OM_IFACE = "org.freedesktop.DBus.ObjectManager"
DBUS_PROP_IFACE = "org.freedesktop.DBus.Properties"

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
    ad_manager.RegisterAdvertisement(adv.get_path(), {},
                                     reply_handler=register_ad_cb,
                                     error_handler=register_ad_error_cb)

    mainloop.run()

if __name__ == '__main__':
    main()
