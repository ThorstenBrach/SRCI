[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](#license)
![SRCI V1.5.9](https://img.shields.io/badge/SRCI_specification-V1.5.9-informational)
[![Documentation: Wiki](https://img.shields.io/badge/documentation-wiki-2ea44f?logo=github)](https://github.com/ThorstenBrach/SRCI/wiki)

# Standard Robot Command Interface (SRCI) – open client implementations

<p align="center"><img src="https://raw.githubusercontent.com/wiki/ThorstenBrach/SRCI/images/SRCI_Logo.png" width="260" alt="SRCI"></p>

> [!IMPORTANT]
> **Looking for the PLC library?** Up to November 2026 this repository contained the IEC 61131-3
> library. It now lives in **[SRCI_CLIENT_PLC](https://github.com/ThorstenBrach/SRCI_CLIENT_PLC)**, with all
> stars, releases, issues and its history. If you cloned this repository for the library, switch
> the remote once:
>
> ```bash
> git remote set-url origin https://github.com/ThorstenBrach/SRCI_CLIENT_PLC.git
> ```

The **Standard Robot Command Interface (SRCI)** lets a machine controller command an industrial or
collaborative robot through one vendor-neutral interface. Instead of learning the programming
language of every robot brand, you program the robot from your own application: a PLC program in
TwinCAT or CODESYS, or a Python script. The robot controller runs an SRCI server from its vendor that
receives the commands and executes them.

This page is the entry point to an open implementation of the **client side** of SRCI, based on the
specification V1.5.9. More about SRCI: [PROFIBUS & PROFINET International – Robotics / SRCI](https://www.profibus.com/technologies/robotics-srci)

## Repositories

| Repository | What it is |
|---|---|
| **[SRCI_CLIENT_PLC](https://github.com/ThorstenBrach/SRCI_CLIENT_PLC)** | The PLC library: IEC 61131-3 client for TwinCAT 3 and CODESYS 3.5 (library, sources, PLCopen XML, examples). 119 function blocks of the Core, Extended and Optional profiles |
| **[SRCI_CLIENT_PY](https://github.com/ThorstenBrach/SRCI_CLIENT_PY)** | The Python client `srci-client` (`import srci`): the same function blocks with the same names, for Python 3.12+ |
| **[SRCI_CLIENT_CPP](https://github.com/ThorstenBrach/SRCI_CLIENT_CPP)** (planned) | The C++ client library: generated from the PLC library like the Python client, same function blocks in C++ syntax |
| **[SRCI_CLIENT_CS](https://github.com/ThorstenBrach/SRCI_CLIENT_CS)** (planned) | The C# client library: generated from the PLC library like the Python client, same function blocks in C# syntax |
| **[SRCI_CLIENT_PY_HMI](https://github.com/ThorstenBrach/SRCI_CLIENT_PY_HMI)** | Teach pendant in the browser (NiceGUI) on top of the Python client: switch on, jog, teach points, run programs |
| **[SRCI_SERVER_BRIDGE_TCP_IP](https://github.com/ThorstenBrach/SRCI_SERVER_BRIDGE_TCP_IP)** | The PLC as TCP/IP bridge: forwards the SRCI telegrams between the Python client and a robot on PROFINET (TwinCAT and CODESYS) |
| **[SRCI_TEST_CASES](https://github.com/ThorstenBrach/SRCI_TEST_CASES)** (private) | Test case catalog: every test of both implementations with a stable ID, description and coverage |
| **[Wiki](https://github.com/ThorstenBrach/SRCI/wiki)** | User manual for both implementations: setup, concepts, every function block, data types, examples |

## How the parts fit together

```
 PLC program (TwinCAT / CODESYS)        Python script / SRCI_CLIENT_PY_HMI
        │  SRCI_CLIENT_PLC                      │  SRCI_CLIENT_PY
        │                                       │  TCP/IP
        │                         SRCI_SERVER_BRIDGE_TCP_IP (PLC)
        └──────────── PROFINET ─────────────────┘
                          │
                Robot controller with SRCI server
```

The PLC library is the reference (the master). The Python client is generated from it and uses
the same function blocks, parameters and data types; the planned C++ and C# clients will be built
the same way. Every page of the wiki applies to all of them.

## Quality

* Every function block is tested against the SRCI SDK simulator ("SDK in the loop"): about 3,750
  TcUnit tests for the PLC library and the same test cases in Python.
* Findings are fixed in both implementations and listed in the changelogs (`ST-FIX Fnn`).
* The Core profile has been run with robots of several manufacturers; see the wiki page
  *Robot specific information*.

## License

MIT – see the license file of each repository.

## Disclaimer

This project is based on the SRCI technology of PROFIBUS and PROFINET International (PI), but it is
not an official publication of PI. It is a privately initiated project, created and maintained by
Thorsten Brach, and open to contributors. The use of PI technology only serves the interoperability
of the SRCI interface; there is no connection or partnership between this project and PI.

---

[![Donate with PayPal](https://raw.githubusercontent.com/stefan-niedermann/paypal-donate-button/master/paypal-donate-button.png)](https://www.paypal.com/donate/?hosted_button_id=ERN6VH9WA95J6)
