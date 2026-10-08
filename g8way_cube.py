#tool for interacting with Gamecube Gateway Systems using python
#only tested on Ubuntu

import usb.core

#Looks for the Gamecube Server
dev = usb.core.find(idVendor=0x1398, idProduct=0x0001)
#Unlocks the drive (REQUIRED!)
dev.ctrl_transfer(0xC0, 0x13, 0x87FB, 0xA207, 1)

#Asks the drive how many banks there are
numbanks = dev.ctrl_transfer(0xC0, 0x11, 0, 0, 1)[0]

#Lists all the banks
for i in range(numbanks):
  print(i, bytes(dev.ctrl_transfer(0xC0, 0x0C, i, 0, 32, 15000))[0:0x20].split(b"\0")[0].decode())

#tool for interacting with Gamecube Gateway Systems using python
#only tested on Ubuntu

import usb.core


#reports drive status
print(dev.ctrl_transfer(0xC0, 0x02, 0, 0, 1)[0])
print("1 is unlocked")
print(dev.ctrl_transfer(0xC0, 0x03, 0, 0, 4))
print("console table")

#loads a game into a console bank. (game 1f into bank 00)
dev.ctrl_transfer(0xC0, 0x04, 0x001f, 0, 1)
#powers off the cube/ejects the game
dev.ctrl_transfer(0xC0, 0x05, 0, 0, 1)
