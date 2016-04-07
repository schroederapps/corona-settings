# corona-settings by Jason Schroeder

## Overview
This is a Lua module that is designed to add easy saving & loading of user settings in a Corona SDK project. Settings are saved to the app's documents directory as a set of 2 text files:

1. `settings.data` is a base64-encoded JSON string containing key/value pairs that you define in your code.
2. `_settings.data` is a SHA-512 hash of that same JSON string, used to check for any tampering.

While savvy users could technically dig into their settings file and modify the key/value pairs within `settings.data`, the module prevents tampering by checking that a fresh hash of `settings.data` matches the saved hash and reverts user settings to your pre-defined defaults if they do not. Since the key used to generate the hash is not stored in the save files, users will not be able to recreate a matching hash.


## How to use
1. Require the module into your app, preferably near the top of your `main.lua`. Optionally set an encryption key using `settings.setKey()`.

2. Initialize the module using `settings.init()`, which loads in your pre-defined default settings data (as a Lua table), then overwrites any saved user data. This means that you can safely introduce new required settings values into new versions of the same app.

3. Overwrite settings values anywhere in your code by declaring an updated property of the `settings` table. Or add new key/value pairs as needed.

4. Save those settings to disk as needed using `settings.save()`. **Note that the module does not auto-save your settings.** This is by design - I want you to have complete control over when to commit your settings to disk.

```lua
-- require module & set encryption key
local settings = require("settings")
settings.setKey("myKey")

-- define default settings & load saved ones
settings.init({
  playCount = 0,
  hiScore = 0,
  playerNames = {
    "Manny",
    "Moe",
    "Jack",
  }
})

-- update settings
settings.playCount = 1
settings.hiScore = 300
settings.myNewSetting = "I just created a new setting!"
settings.levelScores = {[1] = 100, [2] = 200, [3] = 300}

-- save changes
settings.save()
```

## Functions

### settings.init(defaults)
> Defines your default settings, then overwrites individual key/value pairs with saved settings, if any exist. You can safely introduce new required settings values in subsequent versions of the same app. You can only call `settings.init()` once, preferably at the top of your `main.lua` just after requring the module.
>
> #### Arguments
> This function takes a single argument, `defaults`, which is a table containing key/value pairs representing your default settings.
>
> #### Example
> ```lua
settings.init({
  playCount = 0,
  hiScore = 0,
  playerNames = {
    "Manny",
    "Moe",
    "Jack",
  }
})
```

### settings.save()
> Converts your settings table to a JSON string, then saves that string (`settings.data`) and a hash of it (`_settings.data`) to the app's documents directory.
>
> #### Arguments
> This function accepts no arguments.
>
> #### Example
```lua
settings.save()
```

### settings.reset()
> Removes any saved settings and reverts settings back to your pre-defined defaults. Cannot be undone.
>
> #### Arguments
> This function accepts no arguments.
>
> #### Example
```lua
settings.reset()
```

### settings.setKey(key)
> (Optional) Defines the key used to seed the HMAC generation for the hashed settings save file. This function can only be called once, and must happen before calling settings.init()
>
> #### Arguments
> This function accepts a single argument, `key`, which must be a string.
>
> #### Example
```lua
settings.setKey("myKey")
```
