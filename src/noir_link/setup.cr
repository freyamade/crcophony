# File that properly sets up noir to lex whatever we can
require "noir"
# Have to import all lexers manually for some reason...
require "noir/lexers/crystal"
require "noir/lexers/css"
require "noir/lexers/html"
require "noir/lexers/javascript"
require "noir/lexers/json"
require "noir/lexers/python"
require "noir/lexers/ruby"

# Also import the solarized themes
require "noir/themes/monokai"

# Also require the custom formatter that links Noir back to Hydra
require "./formatter"
