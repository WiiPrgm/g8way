#tool for interacting with Gateway Systems using python
#only tested on Ubuntu

import usb.core

#Looks for the Starlight Wii
dev = usb.core.find(idVendor=0x1398, idProduct=0x000A)
#Unlocks the drive (REQUIRED!)
dev.ctrl_transfer(0xC0, 0x13, 0x87FB, 0xA207, 1)

#Prints the console's serial number
print(bytes(dev.ctrl_transfer(0xC0, 0x19, 0, 0, 16)).decode())

#Asks the drive how many banks there are
numbanks = dev.ctrl_transfer(0xC0, 0x11, 0, 0, 1)[0]

#Lists all the banks
for i in range(1, numbanks):
  print(i, bytes(dev.ctrl_transfer(0xC0, 0x0C, i, 0, 68, 15000))[4:0x44].split(b"\0")[0].decode())
