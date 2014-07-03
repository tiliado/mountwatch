Mount Watch
===========

 *  [Home page](https://github.com/tiliado/mountwatch)
 *  [Support](https://github.com/tiliado/mountwatch/issues)
 
About
-----

Mount Watch monitors mounts (e.g. USB sticks or hard drives) and runs task on mount/unmount events.

Dependencies
------------

  * [valac >= 0.16](https://wiki.gnome.org/Projects/Vala)
  * [gcc](http://gcc.gnu.org/)
  * [glib-2.0 >= 2.32](http://www.gtk.org/)
  * [gio-2.0 >= 2.32](http://www.gtk.org/)
  * [dioriteglib](https://github.com/tiliado/diorite)
  * [python 2](http://python.org/)

Build
-----


    [user]$ ./waf configure
    or
    [user]$./waf configure --prefix=/usr
    
    [user]$ ./waf build

Install
------------

    [root]# ./waf install

Uninstall
---------

    [root]# ./waf uninstall

Usage
-----

Put tasks into ``~/.config/mountwatch/tasks``. Tasks must be executable files with filenames
``"{MOUNT_NAME}--{EVENT}{WHATEVER}"``, e.g. ``"myexthdd--M01_mount_encfs.sh"``.

  * ``{MOUNT_NAME}`` - usually a label of a partition
  * ``{EVENT}``      - ``M`` for mount event, ``U`` for unmount event
  * ``{WHATEVER}``   - short description of the script

Tasks are executed in alphabetical order with two arguments:

  * ``$1`` - a full path of mount's root directory, e.g. "/media/myexthdd"
  * ``$2`` - a mount name, usually a label of a partition, e.g. "myexthdd"

See [examples](./examples).

Run ``mountwatch`` as a regular user, use ``Ctrl-C`` to quit the app.
