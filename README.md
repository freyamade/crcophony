# crcophony */kəˈkɒf(ə)ni/*
*read: cacophony*

[![release badge](https://img.shields.io/github/tag-date/freyamade/crcophony.svg?label=version&style=flat-square)](https://github.com/freyamade/crcophony/releases/latest)

A simple Discord terminal ui written in Crystal.

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

### Channel Switching
- <kbd>Ctrl</kbd>+<kbd>K</kbd>: Open / Close Channel Selection Menu
- <kbd>Enter</kbd>: Select Channel
- <kbd>Ctrl</kbd>+<kbd>W</kbd> / <kbd>Up</kbd>: Scroll Selection Up
- <kbd>Ctrl</kbd>+<kbd>S</kbd> / <kbd>Down</kbd>: Scroll Selection Down
- <kbd>ESC</kbd>: Alternative Close Button

## Usage

### Using pre-built binary
Since the 0.1.0 release I have been including a static binary attached to releases. Here are instructions for running the application using these binaries;

1. Go to the [latest release](https://github.com/freyamade/crcophony/releases/latest) and download the binary.
2. Follow the steps in [Gathering Data](#gathering-data) to set up your environment.
3. Run `./crcophony` from the directory you downloaded the binary to and it should run.

If the pre-built binary doesn't work, open an issue with as much information as possible (from log files and application error trace and such) and then maybe also try installing from source!

### From source
If the pre-built binary didn't work for you, or you want to install from source by choice, here are the instructions;

1. Install [Crystal](https://crystal-lang.org/reference/installation/)
2. Install [termbox](https://github.com/nsf/termbox) following the instructions in their README.
3. Clone this repo.
4. Run `shards install` to install requirements.
5. Follow the steps in [Gathering Data](#gathering-data) to set up your environment.
6. Run `shards build` to build the system, or use `shards build --release` to build with optimisations (slower build but potential speedups over non release mode).
7. Run `bin/crcophony` to open the application.

## Gathering Data
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

## Contributing

1. Fork it (https://github.com/freyamade/crcophony/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

Contributors

- freyamade - creator, maintainer
