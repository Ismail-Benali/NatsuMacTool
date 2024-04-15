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
4. (Optional) Make the script run automatically on system startup by following these steps:
   - Open the `rc.local` file for editing with sudo privileges:
     ```
     sudo nano /etc/rc.local
     ```
   - Add the following line before the line `exit 0`:
     ```
     /bin/bash /path/to/NatsuMacTool.sh
     ```
     Replace `/path/to/NatsuMacTool.sh` with the full path to your script file.
   - Save the changes and exit the editor.
   - Make sure that `rc.local` is executable by running:
     ```
     sudo chmod +x /etc/rc.local
     ```
   - Reboot your system to apply the changes:
     ```
     sudo reboot
     ```
### Contact:

For any inquiries or support, please contact ismail-benali@proton.me.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
