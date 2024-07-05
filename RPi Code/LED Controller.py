import bluetooth
from bluetooth.ble import GATTServer, Service, Characteristic
import struct
import threading

# Define UUIDs for the service and characteristic
SERVICE_UUID = "7a6307c9-5be7-4747-a8b6-51a6cb9b285c"
CHARACTERISTIC_UUID = "ddbf3449-9275-42e5-9f4f-6058fabca551"

class LEDControllerServer:
    def __init__(self):
        self.server = None
        self.service = None
        self.characteristic = None

    def handle_read(self, device, handle):
        print(f"Read request from {device}")
        return b"Hello from Raspberry Pi"

    def handle_write(self, device, handle, value):
        print(f"Received data from {device}: {value.decode()}")
        # Here you can add logic to control your LED or perform other actions
        # based on the received data

    def run(self):
        self.server = GATTServer("LEDController")
        self.service = Service(SERVICE_UUID)
        self.characteristic = Characteristic(
            CHARACTERISTIC_UUID,
            ["read", "write", "notify"],
            self.handle_read,
            self.handle_write
        )
        self.service.add_characteristic(self.characteristic)
        self.server.add_service(self.service)

        print("Starting GATT server...")
        self.server.start()
        print(f"Server started. Address: {bluetooth.get_local_address()}")

        # Keep the script running
        try:
            threading.Event().wait()
        except KeyboardInterrupt:
            print("Stopping server...")
            self.server.stop()

if __name__ == "__main__":
    controller = LEDControllerServer()
    controller.run()