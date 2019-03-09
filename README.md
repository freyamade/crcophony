# crcophony */kəˈkɒf(ə)ni/*
*read: cacophony*

A simple Discord terminal ui written in Crystal.

## Initial Design
![initial design](https://raw.githubusercontent.com/freyamade/crcophony/master/demo.png)

## Implemented Features
- Connects to a single channel
- Mentions are parsed back into usernames
- When you are mentioned it is written in your terminal's yellow colour.

## Roadmap
- Obtaining channel history (last 100 messages or so)
- Channel switching

If you can think of stuff I am missing, open an issue c:

## Setup
This project is in ***very*** early alpha. That said, you can currently use it a little bit if you want!
1. Install [Crystal](https://crystal-lang.org/reference/installation/)
2. Clone this repo
3. Run `shards install` to install requirements
4. Gather the following details and use them to assign values to the variables declared within the commented section in `src/crcophony.cr#8`
    - `channel_id`: ID of the channel to connect to (ensure to only replace the number part, leaving the `_u64` suffix intact)
    - `user_id`: Your User ID (ensure to only replace the number part, leaving the `_u64` suffix intact)
    - `token`: Your User token
5. Run `crystal run src/crcophony.cr` and after a couple of seconds it should pop up
6. Type and hit enter and messages should send :D

## Issues
If you run into any issues, check the `.log` files that have been created. If anything looks wrong, include the output in an issue ^^

## Gathering Data
1. Turn on [Developer Mode](https://discordia.me/developer-mode)
2. To get the `channel_id`, right click on the channel you want to join and click "Copy ID". This is the value you should put in as the `channel_id`
3. To get the `user_id`, right click on your own name in the Users sidebar of any channel and click "Copy ID". This is the value you should put in as the `user_id`
4. Follow [this guide](https://discordhelp.net/discord-token) to get your token.
