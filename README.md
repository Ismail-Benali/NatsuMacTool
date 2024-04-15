# NatsuMacTool

NatsuMacTool is a simple script written in Bash to automatically set a random MAC address for the primary network interface upon system startup in Linux.

## Features

- Automatically sets a random MAC address for the primary network interface upon system startup.
- Enhances privacy and security by periodically changing the MAC address.
- Easy to use and configure.

## Prerequisites

- Bash
- NetworkManager (nmcli command)

## Usage

1. Clone this repository or download the `NatsuMacTool.sh` script.
2. Make the script executable by running:
    ```
    chmod +x NatsuMacTool.sh
    ```
3. Run the script with sudo privileges:
    ```
    sudo ./NatsuMacTool.sh
    ```
4. Upon system startup, the script will automatically set a random MAC address for the primary network interface.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
