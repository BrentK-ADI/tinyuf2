# TinyUF2 - MAX32666 Port

This folder contains the port of TinyUF2 for the Maxim Integrated MAX32666 MCU.

## Navigation

- [Requirements](#requirements)
- [Environment Setup](#environment-setup)
- [Available Boards](#available-boards)
- [Building the Bootloader](#building-the-bootloader)
- [Building Demo Applications](#building-demo-applications)
- [Flashing the Bootloader](#flashing-the-bootloader)
- [Notes on SAVELOG=1](#notes-on-savelog1)
- [Cleaning Logs](#cleaning-logs)
- [Flashing Example Applications](#flashing-example-applications)
- [Port Directory Structure](#port-directory-structure)


## Requirements

- [MaximSDK](https://www.analog.com/en/design-center/evaluation-hardware-and-software/software/maxim-sdk.html) installed.
- ARM GNU Toolchain (`arm-none-eabi-gcc`). (Already Available on MaximSDK)
- `make` must be installed:
  - System-wide MSYS2: `C:/msys64/usr/bin/make.exe`
  - MaximSDK MSYS2: `C:/MaximSDK/Tools/MSYS2/usr/bin/make.exe`
- **Git** must be installed to clone and manage submodules:
  - In MSYS2 (if not installed): 
    ```bash
    pacman -S git
    ```
- A terminal environment:
  - Preferred: **MSYS2** provided by MaximSDK, located at `C:/MaximSDK/Tools/MSYS2/`.
  - Alternative: a system-wide MSYS2 or mingw installation (see notes below).

Ensure the environment variable `MAXIM_PATH` points to your MaximSDK installation.
If not set, TinyUF2 will default to using `C:/MaximSDK` on Windows.

```bash
# Example (Linux/macOS)
export MAXIM_PATH=/opt/MaximSDK

# Example (Windows Git Bash)
export MAXIM_PATH=/c/MaximSDK
```


## Environment Setup

### 1. Using MaximSDK's MSYS2

Open MSYS2 (`mingw32.exe` or `mingw64.exe`) from:

```
C:/MaximSDK/Tools/MSYS2/
```

No further setup is needed — the required ARM toolchain should be available.

### 2. Using a System-wide MSYS2 or mingw (Alternative)

If you are using your own MSYS2 or mingw installation (not MaximSDK’s MSYS2), you must manually add the MaximSDK's GNUTools to your PATH before building:

```bash
export PATH="/c/MaximSDK/Tools/GNUTools/10.3/bin/:$PATH"
```

Or in one-line command for building:

```bash
PATH="/c/MaximSDK/Tools/GNUTools/10.3/bin/:$PATH" make BOARD=max32666evkit blinky erase-firmware self-update
```

(Adjust the path if your MaximSDK installation is in a different location.)



## Available Boards

Each port supports multiple hardware platforms.  
The specific boards available for each device can be found inside:

```
ports/maxxxxxx/boards/
```

For example, for MAX32666:

```
tinyuf2/ports/max32666/boards/
    max32666evkit
    max32666fthr
```

When building or flashing, make sure to specify a valid `BOARD` name from the available list:

```bash
make BOARD=max32666evkit all
make BOARD=max32666evkit flash
```

Otherwise, the build will fail if an invalid board name is provided.



## Building the Bootloader

1. Open your MSYS2 terminal (preferably MaximSDK’s).
2. Navigate to the port folder for MAX32666:

```bash
cd ports/max32666
```

3. Build the TinyUF2 bootloader:

```bash
make BOARD=max32666evkit all
```


Output files will appear in `_build/` and build logs under `apps/$(APP)/logs/`.




## Building Demo Applications

TinyUF2 for MAX32666 includes three demo applications:
- **Blinky** (`apps/blinky`)
- **Erase Firmware** (`apps/erase_firmware`)
- **Self-Update** (`apps/self_update`)

### To Build Individual Applications:

```bash
make BOARD=max32666evkit blinky
make BOARD=max32666evkit erase-firmware
make BOARD=max32666evkit self-update
```

### To Clean Individual Applications:

```bash
make BOARD=max32666evkit blinky-clean
make BOARD=max32666evkit erase-firmware-clean
make BOARD=max32666evkit self-update-clean
```

You can add `SAVELOG=1` to any of these commands to generate a saved build log.

```bash
 make BOARD=max32666evkit SAVELOG=1 blinky erase-firmware self-upadte
```



## Flashing the Bootloader

### 1. J-Link (default)

To flash using a J-Link debugger:

```bash
make BOARD=max32666evkit flash
```

To erase before flashing:

```bash
make BOARD=max32666evkit erase flash
```

### 2. OpenOCD from MaximSDK (optional)

If you prefer OpenOCD and you have it installed through MaximSDK:

```bash
make BOARD=max32666evkit flash-msdk
```

Make sure `MAXIM_PATH` is correctly set to the MaximSDK base folder. If your default installation of the MaximSDK is not `C:/MaximSDK` you can pass the MaximSDK location...

```bash
make BOARD=max32666evkit MAXIM_PATH=C:/MaximSDK flash-msdk
```

## Notes on SAVELOG=1

Log export options are available for demo apps.

If `SAVELOG=1` is set during a build:

- Output logs are automatically saved into a `logs/` folder inside each application.
- Each application target (e.g., `blinky`, `blinky-clean`) has its own separate subfolder and timestamped `.log` files.
- Log files are ignored from Git version control.

Example:

```
apps/blinky/logs/blinky/blinky_20250425_134500.log
apps/blinky/logs/blinky-clean/blinky-clean_20250425_134512.log
```


## Cleaning Logs

You can remove all saved build logs across all apps by running:

```bash
make BOARD=max32666evkit clean-logs
```

This deletes all `logs/` directories under `apps/blinky`, `apps/erase_firmware`, and `apps/self_update`.


## Flashing Example Applications

After building any of the demo applications (Blinky, Erase Firmware, or Self-Update), a UF2 file will be generated in:

```
apps/<application>/_build/<board>/<application>-<board>.uf2
```

For example:

```
apps/blinky/_build/<board>/blinky-<board>.uf2
```

### Flashing via Drag-and-Drop

1. **Enter bootloader mode** on your board:
   - Typically, perform a **double-tap on the reset button** within **500 milliseconds**.
   - The board will appear as a **USB mass storage device** (for example, named `TINYUF2`) in your operating system's **File Explorer** (Windows) or **Finder** (macOS) or **File Manager** (Linux).

2. **Using your file explorer**, locate the `.uf2` file you built, and **drag and drop** it onto the mounted TinyUF2 USB drive.

3. The board will automatically reboot and begin running the new application.

### Re-Entering Bootloader Mode

To flash a different application or return to bootloader mode:

- Perform another **double-tap** of the reset button within 500 milliseconds.
- The board will reappear as a USB mass storage device for new UF2 flashing.

> ⚠️ **Note:**  
> If double-tap reset does not work (for example, if the running application has corrupted necessary flash metadata), you may need to manually reflash the TinyUF2 bootloader using a SWD debug tool such as J-Link or OpenOCD.  
> Refer to your board's documentation for additional recovery options if needed.

## Port Directory Structure

Example directory tree for the MAX32666 port:

```
max32666
├── Makefile
├── README.md
├── _build
├── apps
│   ├── blinky
│   │   ├── Makefile
│   │   └── _build
│   ├── erase_firmware
│   │   ├── Makefile
│   │   └── _build
│   └── self_update
│       ├── Makefile
│       └── _build
├── board_flash.c
├── boards
│   ├── apard32690
│   │   ├── board.h
│   │   └── board.mk
│   └── max32666evkit
│       ├── board.h
│       └── board.mk
├── boards.c
├── boards.h
├── linker
│   ├── max32666_app.ld
│   ├── max32666_boot.ld
│   └── max32666_common.ld
├── port.mk
└── tusb_config.h
```