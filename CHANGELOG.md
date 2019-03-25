# CHANGELOG

One stop shop for the updates made to the project with each version, and to check master's status against the latest release

## master
- Changed loading messages to use a progress bar
- Added parsing of code blocks
- Added syntax highlighting using the [noir library](https://github.com/MakeNowJust/noir)
    - When I get some free time I think I'll port some more lexers from Rouge to this project
    - Currently, the lib only supports the following languages, and as such these are the only languages that will be highlighted
        - crystal
        - css
        - html
        - javascript
        - json
        - python
        - ruby
    - I'm currently trying to talk to the maintainer of the lib to allow me to add more lexers so this list should hopefully grow soon
- Fixed bug where colouring text would interfere with the text wrapping process
- Fixed bug where a message containing just an image would have a blank line
- Added keybinds for up and down arrows to scroll through messages / channels (requires `shards update`)

## 0.4.0 - Latest Release
- Removed duplicate colour names so all 256 colours are available
- Now renders the timestamp at the right hand side of the screen, similar to some shell themes
- Colour the title of embeds based on the colour that they are in the normal client
- Added handling for Direct Messages and Group Chats

## 0.3.0
- Usernames now have colours
    - Powered by 256 colour terminals. No idea what will happen if you run the system on a system with less colours.

## 0.2.1
- Fixed rendering issue regarding embeds with multi line descriptions
- Fixed major issue regarding the application taking a lot of CPU usage to just run idly

## 0.2.0
- Fixed issue with parts of messages being removed during the text wrapping process
- Fixed bug that caused channel names to appear twice in the switcher with no search, when your previous channel also has notifications
- Slightly improved channel searching algorithm
    - Searcher currently only searches through channel names, doesn't include server names to avoid issues
    - Uses an improved algorithm that scores channel names instead of using basic levenshtein ratios
- Handling of attachments
    - Attachments are now displayed as links below the message body
- Handling of embeds
    - Embeds are now rendered in text form below the message body, and below any attachments

## 0.1.0
- Currently this application only supports server channels. DMs and Group Chats will come later.
- Mentions are parsed back into usernames, and any mention of the connected user will show up in yellow.
- Loading channel history when a channel is changed to (this can and will be improved).
- Long messages are wrapped.
- Unread messages are kept track of per channel, and a total number can be found at the top right corner.
- Channel Switching that behaves somewhat similarly to Discord's client
    - Without providing search text, it will display the previously visited channel and channels that have notifications
    - Typing search text will filter channels based on Levenshtein ratios
        - The algorithm could be improved somewhat however
