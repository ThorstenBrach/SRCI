[![create release](https://github.com/ThorstenBrach/SRCI/actions/workflows/build.yml/badge.svg)](https://github.com/ThorstenBrach/SRCI/actions/workflows/build.yml)

# Standard Robot Command Interface (SRCI)

![SRCI](https://raw.githubusercontent.com/wiki/ThorstenBrach/SRCI/images/SRCI_Logo_small.png)

**This is an open PLC client implementation of the SRCI interface for IEC61131-3, based on SRCI specification V1.5 (Jan 2025).**


The Standard Robot Command Interface (SRCI) is an open, manufacturer-independent standard, designed to enable seamless integration and control of robots in PLC-based automation environments. It provides a consistent communication framework that simplifies the programming and operation of industrial and collaborative robots — regardless of the specific PLC or robot brand involved.

More information about SRCI : 

👉 General Info : https://www.profibus.com/technologies/robotics-srci

👉 Project Wiki : https://github.com/ThorstenBrach/SRCI/wiki

# Status
At this point, the SRCI Core Profile was successfully tested with Jaka, Yaskawa, Stäubli, Kuka and Fanuc robots.

Despite this progress, the software is still some way off from being ready for practical use. 
Further optimizations and extensive testing are required to ensure the functionality.

# Software delivery:
The software is delivered as a not compiled library (visible source code) usable for Codesys and TwinCat.  
And in addition also availabel as PLCopen XML, which can be imported in different PLC IDE.

# License
The library is licensed under the MIT license.

# Disclaimer and Delimitation

The developed software is based on the SRCI technology of "PROFIBUS and PROFINET International" (PI), but it is not an official publication of PI. It is a privately initiated project, created and currently maintained by me — but it is open to contributors for further development, improvement and ongoing maintenance.

The use of PI technology only serves to ensure the interoperability and functionality of the SRCI interface. There is no connection or partnership between this project and the PI organization.

This project is provided without any guarantee and can be used for private and commercial purposes. Any use is at the user’s own risk and responsibility.


# Legal Notice
Due to some user concerns, I would like to assure you,
that I have obtained the official approval of the PI organization to release this implementation on GitHub....


[![Donate with PayPal](https://raw.githubusercontent.com/stefan-niedermann/paypal-donate-button/master/paypal-donate-button.png)](https://www.paypal.com/donate/?hosted_button_id=ERN6VH9WA95J6)
