Nmap Scripts
======

## raikia-screenshot.nse

This nmap script will take a screenshot of http[s]://ip:port, as well as http[s]://hostname:port AND https://sslcert_name:port.  This differs from other screenshot nmap utilities because it will allow javascript execution, and it will have a timeout on the screenshot request, so the scan won't hang.

All screenshots will be stored in a subfolder named "screenshots"

Designed for Kali 2.0

### Requirements:

  * wkimagetopdf (apt-get install wkimagetopdf)

### Example Usage:

     nmap --script=raikia-screenshot.nse -p 80,443,8080,8443 -iL target_list.txt


-------------------------------------

# Contact Information

Feel free to contact me with any changes or feature requests!

* https://twitter.com/raikiasec
* raikiasec@gmail.com

