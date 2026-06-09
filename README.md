# SSHeaderForVim

A bespoke Vim plugin designed to automatically initialise, format, and maintain a custom "Ser Superior" ASCII art header for source files. It features filetype-specific comment delimiter detection and automatic modification timestamp updates upon saving.

## Features

- **Custom ASCII Art Logo:** Inserts a beautifully formatted 11-line "Ser Superior" header block.
- **Dynamic Filetype Delimiters:** Automatically detects appropriate comment delimiters (e.g. `/* ... */` for C/C++ and `#` for Python/Makefiles).
- **Automatic Timestamp Updates:** Listens to the `BufWritePre` event to update the `Updated:` field automatically upon saving, only if the buffer has been modified.
- **Conflict Resolution:** Deactivates the global school `stdheader.vim` autocommand group on `VimEnter` to prevent layout corruption and username/logo overrides.
- **Scoping Resolution:** Uses script-local scoping (`<SID>`) for all event handlers to guarantee reliable execution within the Vim environment.

## Installation and Symlinking

To integrate this plugin into your Vim configuration, clone the repository and put the `ssheader.vim` in your local Vim plugin directory:

```bash
git clone <git@github.com:marcioeduine/SSHeaderForVim.git>
cd SSHeaderForVim/
mkdir -p ~/.vim/plugin
cp -p SSHeaderForVim/ss_header.vim ~/.vim/plugin/ss_header.vim
```

## How It Works

Upon loading, the plugin registers a `VimEnter` autocommand that disables the system-wide `stdheader` plugin autocommand. This ensures that the global school plugin does not intercept file saving events and corrupt the header spacing:

- Spacing is strictly aligned at 80 columns.
- The user's name is locked to `"Ser Superior"`.
- The filename is padded to 42 characters and truncated if necessary.

## Usage

### Manual Insertion
Type `:SSHeader` or press `<F4>` in normal mode to insert a new header or manually force a timestamp update.

### Automatic Updates
Whenever you save a file that already contains an `SSHeader` (detected by looking for the `Created:` line within the first 12 lines), the `Updated:` timestamp is automatically updated with the current time and user.
