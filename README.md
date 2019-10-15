# crcophony */kəˈkɒf(ə)ni/*
*read: cacophony*

[![release badge](https://img.shields.io/github/tag-date/freyamade/crcophony.svg?label=version&style=flat-square)](https://github.com/freyamade/crcophony/releases/latest)

A simple Discord Terminal UI written in Crystal.

## WARNING
Self-bots are not allowed by Discord's Terms of Service.
Using crcophony could technically count as using a self-bot.
Use this project at your own risk, it isn't my fault if it gets you banned.

That being said, I'm trying my best to ensure the application is as safe as possible.
You cannot do anything in crcophony that you can't do in the normal Discord client (in fact, there are things you can do in the Discord client that you can't do in crcophony) so it *should* be okay.

Bottom line: ***Use at your own risk***

## Keybinds
### Normal
- <kbd>Ctrl</kbd>+<kbd>C</kbd>: Quit Application
- <kbd>Enter</kbd>: Send Message
- <kbd>Ctrl</kbd>+<kbd>W</kbd> / <kbd>Up</kbd>: Scroll Up
- <kbd>Ctrl</kbd>+<kbd>S</kbd> / <kbd>Down</kbd>: Scroll Down
- <kbd>Ctrl</kbd>+<kbd>N</kbd>: Add line break to message input

### Channel Switching
- <kbd>Ctrl</kbd>+<kbd>K</kbd>: Open / Close Channel Selection Menu
- <kbd>Enter</kbd>: Select Channel
- <kbd>Ctrl</kbd>+<kbd>W</kbd> / <kbd>Up</kbd>: Scroll Selection Up
- <kbd>Ctrl</kbd>+<kbd>S</kbd> / <kbd>Down</kbd>: Scroll Selection Down
- <kbd>ESC</kbd>: Alternative Close Button

## Installation

### PKGBUILD
If you use Arch Linux or any similar variant, then there's a PKGBUILD in the repo.
I haven't published this project to the AUR yet but I intend to at some stage.

### From source
If you're not on Arch, currently the only way is to install from source.

#### Install requirements
The requirements for the application are as follows;
- [`crystal>=0.31.0`](https://crystal-lang.org/reference/installation/)
- [`termbox`](https://github.com/nsf/termbox)
- 'libdbus'

#### Build
1. Clone this repo
2. Run `shards install` and then `shards build --release -Dpreview_mt` to install all the requirements and build the application.
    - This will create an executable in the `bin` folder local to the cloned repo, which can then be moved wherever it needs to be moved.

## Usage
Before you can run Crcophony, you need to gather a bit of data.

### Gathering Data
To use the system, you must gather the following information and export the data as environment variables.
These variables are as follows;

- `CRCOPHONY_TOKEN`: Your user token used to authenticate yourself with the client
- `CRCOPHONY_USER_ID`: Your user id (might not be necessary, requires investigation and could be removed at a later point)

Here are the instructions for you to get these bits of data;
1. Turn on [Developer Mode](https://discordia.me/developer-mode)
3. To get the `user_id`, right click on your own name in the Users sidebar of any channel and click "Copy ID". This is the value you should put in as the `user_id`
4. Follow [this guide](https://discordhelp.net/discord-token) to get your token.

If you use the `fish` or `bash` shells, a sample `.env` file has been included in this project (`.env.sample.fish` and `env.sample.bash` respectively).
Simply rename the appropriate file to `.env`, populate the strings inside with your gathered data and run `source .env` in the directory to get the correct environment variables created.

### Running the Application
After the environment variables are defined, simply run the crcophony executable.

### NOTE
As far as I am currently aware, placing `crcophony` in a bin folder and running it as `crcophony` does not work when attempting to spawn threads.
This is because Crystal tries to spawn by reading the file passed in as the command following it like a path from your current directory.
The workaround I currently use is creating a small bash script that runs crcophony using an absolute path, and placing this executable script in your bin folder.

## Contributing

1. Fork it (https://github.com/freyamade/crcophony/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

Contributors

- freyamade - creator, maintainer
