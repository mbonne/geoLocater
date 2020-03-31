# geoLocater
Simple script to find geo location of public IP address

To install, add script file to your path.
For example, create a bin directory to your homefolder and add that to your path.
e.g: follow this guide: https://apple.stackexchange.com/questions/99788/os-x-create-a-personal-bin-directory-bin-and-run-scripts-without-specifyin


# Running it:
Type geo in terminal, hit return.
If checkin a specific IP address, 
type: 
`geo 8.8.8.8`



Once it runs against given IP address, you can choose to open google map or virus total.


## Example
```
$ geo 8.8.8.8

IP Address: 	8.8.8.8
Country: 	United States
continent: 	North America
Organisation: 	Google LLC
PTR: 		dns.google.


1) https://www.google.com/maps/search/?api=1&query=37.751,-97.822&z=13
2) https://www.virustotal.com/gui/ip-address/8.8.8.8
3) Quit
Type Number to open Website:
```
