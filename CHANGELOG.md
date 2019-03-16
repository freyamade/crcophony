# CHANGELOG

One stop shop for the updates made to the project with each version, and to check master's status against the latest release

## master
- Fixed issue with parts of messages being removed during the text wrapping process
- Fixed bug that caused channel names to appear twice in the switcher with no search, when your previous channel also has notifications
- Slightly improved channel searching algorithm
    - I've improved the issues a bit, searcher currently only searches through channel names, doesn't include servers to avoid issues

## 0.1.0 - Latest Release
- Currently this application only supports server channels. DMs and Group Chats will come later.
- Mentions are parsed back into usernames, and any mention of the connected user will show up in yellow.
- Loading channel history when a channel is changed to (this can and will be improved).
- Long messages are wrapped.
- Unread messages are kept track of per channel, and a total number can be found at the top right corner.
- Channel Switching that behaves somewhat similarly to Discord's client
    - Without providing search text, it will display the previously visited channel and channels that have notifications
    - Typing search text will filter channels based on Levenshtein ratios
        - The algorithm could be improved somewhat however
