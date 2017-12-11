Chobby, the ingame lobby.

Installation
============

There are multiple ways you can install Chobby.

#### 1. Chobby.exe wrapper (recommended) ####

Download `chobby.exe` from http://zero-k.info/lobby/chobby.exe and run it. It will download the newest version of Chobby as well as the required engine, and automatically start it. Should work under Windows and Linux.

#### 2. Rapid (pr-downloader) ####

Chobby is on rapid, under the "chobby" tag.

To download with pr-downloader use this command line:

    pr-downloader chobby:test

You will need to obtain the appropriate engine and configure it manually.

#### 3. Development version from Github ####

The development version of Chobby can be obtained directly from here, and should be placed in your games subdirectory.
Example (execute in your games folder):

    git clone https://github.com/Spring-Chobby/Chobby.git Chobby.sdd

Launching
=========

If you're using the wrapper, you don't need to read this. Just go ahead and run the executable.

Chobby is a Lua Menu and requires the newest engine. For exact version, see the engine tag in `modinfo.lua` (https://github.com/Spring-Chobby/Chobby/blob/master/modinfo.lua#L19).

For development version of Chobby (obtained from Github), you can launch Chobby by running `spring --menu 'Chobby $VERSION'` or by setting `DefaultLuaMenu = Chobby $VERSION` in your springsettings.cfg (https://springrts.com/wiki/Springsettings.cfg). Versions obtained from Github should follow the same procedure, but set the appropriate fixed version instead, e.g. `Chobby test-1145-2d0ef36`, instead of `Chobby $VERSION`.

If you are using `chobby:test` from rapid, you can specify rapid directly, instead of setting the version manually.
e.g. `spring --menu 'rapid://chobby:test'` and `DefaultLuaMenu = rapid://chobby:test`

See the [wiki](https://github.com/Spring-Chobby/Chobby/wiki) for more details, including [Game Customization](https://github.com/Spring-Chobby/Chobby/wiki/Game-Customization)

