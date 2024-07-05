//Krish Prabhu
import asyncio
from bleak import BleakServer
from bleak.backends.characteristic import BleakGATTCharacteristic
from bleak.backends.service import BleakGATTService

# Define UUIDs for the service and characteristic
SERVICE_UUID = "12345678-1234-5678-1234-56789abcdef0"
CHARACTERISTIC_UUID = "87654321-1234-5678-1234-56789abcdef0"

class LEDControllerServer:
    def __init__(self):
        self.connected_devices = set()

    async def handle_read(self, characteristic: BleakGATTCharacteristic, **kwargs):
        return b"Hello from Raspberry Pi"

    async def handle_write(self, characteristic: BleakGATTCharacteristic, data: bytearray):
        print(f"Received data: {data.decode()}")
        # Here you can add logic to control your LED or perform other actions
        # based on the received data

    async def handle_disconnect(self, device):
        print(f"Device {device.address} disconnected")
        self.connected_devices.remove(device)

    async def run(self):
        server = BleakServer()
        service = BleakGATTService(SERVICE_UUID)
        char = BleakGATTCharacteristic(CHARACTERISTIC_UUID, read=True, write=True, notify=True)
        char.add_descriptor(BleakGATTCharacteristic("2902", read=True, write=True))
        service.add_characteristic(char)
        server.add_service(service)

        char.set_read_handler(self.handle_read)
        char.set_write_handler(self.handle_write)

        await server.start()
        print(f"Server started. Address: {server.address}")

        while True:
            for device in server.connected_devices:
                if device not in self.connected_devices:
                    print(f"New device connected: {device.address}")
                    self.connected_devices.add(device)
                    server.set_disconnect_handler(device, self.handle_disconnect)

            await asyncio.sleep(1)

if __name__ == "__main__":
    controller = LEDControllerServer()
    asyncio.run(controller.run())
