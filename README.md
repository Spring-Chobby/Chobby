Chobby, the ingame lobby.

Installation
============

There are multiple ways you can install Chobby.

#### 1. Chobby.exe wrapper ####


Download `chobby.exe` from http://zero-k.info/lobby/chobby.exe and execute it. It will download the newest version of Chobby and required engine, and automatically execute it. Should work under Windows and Linux.

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

You can launch Chobby by running `spring --menu 'CHOBBY $VERSION'` or by setting `DefaultLuaMenu = CHOBBY $VERSION` in your springsettings.cfg


[![Join the chat at https://gitter.im/Spring-Chobby/Chobby](https://badges.gitter.im/Spring-Chobby/Chobby.svg)](https://gitter.im/Spring-Chobby/Chobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
