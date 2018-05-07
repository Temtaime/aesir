# Æsir

Æsir — an open-source cross-platform MMORPG client.

=======

## Building
* Go to https://cloud.acomirei.ru/s/6Y0T4jvdkvYEIRc and grab data.7z and deps.7z.
* Extract data.7z to bin directory.
* Extract deps to utils directory.

For building you should have VC++ 2017, D compiler and Sublime Text.

You can grab D compiler(prefixed with dmd) from the bottom of d.a-rei.ru, but it requires some tweaks to work.

Those compilers are configured to use local copy on VC++, so I think you can just replace sc.ini(settings file) with one from official dmd distribution from dlang.org.

Open the project from sublime text and run build dependencies: packet gen, shader gen, opengl gen.

Then build the Æsir itself using first dub command.
