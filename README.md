# crcophony */kəˈkɒf(ə)ni/*
*read: cacophony*

A simple Discord terminal ui written in Crystal.

## Initial Design
![initial design](https://raw.githubusercontent.com/freyamade/crcophony/master/demo.png)

## Implemented Features
- Connects to a single channel
- Mentions are parsed back into usernames
- When you are mentioned it is written in your terminal's yellow colour.
- When you connect to a channel, the client will load the last 50 messages automatically
- The message container can now be scrolled using <kbd>Ctrl</kbd>+<kbd>W</kbd> and <kbd>Ctrl</kbd>+<kbd>S</kbd> for up and down respectively.

## Roadmap
- Channel switching

If you can think of stuff I am missing, open an issue c:

## Setup
This project is in ***very*** early alpha. That said, you can currently use it a little bit if you want!
1. Install [Crystal](https://crystal-lang.org/reference/installation/)
2. Clone this repo
3. Run `shards install` to install requirements
4. Follow the steps in the [Gathering Data](#gathering-data) section to gather necessary information
5. Run `crystal run src/crcophony.cr` and after a couple of seconds it should pop up
6. Type and hit enter and messages should send :D

## Issues
If you run into any issues, check the `.log` files that have been created. If anything looks wrong, include the output in an issue ^^

## Gathering Data
To use the system, you must gather the following information and export the data as environment variables.
These variables are as follows;

- `CRCOPHONY_CHANNEL_ID`: The ID of the channel you wish to connect to (temporary, will be removed once I have sorted out the channel switching functionality)
- `CRCOPHONY_TOKEN`: Your user token used to authenticate yourself with the client
- `CRCOPHONY_USER_ID`: Your user id (might not be necessary, requires investigation and could be removed at a later point)

Here are the instructions for you to get these bits of data;
1. Turn on [Developer Mode](https://discordia.me/developer-mode)
2. To get the `channel_id`, right click on the channel you want to join and click "Copy ID". This is the value you should put in as the `channel_id`
3. To get the `user_id`, right click on your own name in the Users sidebar of any channel and click "Copy ID". This is the value you should put in as the `user_id`
4. Follow [this guide](https://discordhelp.net/discord-token) to get your token.

If you use the `fish` or `bash` shells, a sample `.env` file has been included in this project (`.env.sample.fish` and `env.sample.bash` respectively). Simply rename the appropriate file to `.env`, populate the strings inside with your gathered data and run `source .env` in the directory to get the correct environment variables created.
