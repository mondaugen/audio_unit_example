# A simple Audio Unit effect.

This is based on the code provided by Apple. This code doesn't need Xcode, but
you need to install the Xcode CommandLineTools (version 8.1 or higher).

The `bin/signal_chain` binary will open an Audio Engine and add the Audio Unit
in process. A sound file is played and processed by a low pass filter whose
output is sent to the system.

Also all of the GUI parts have been removed.

Warning: this code is kind of janky and just shows the idea. What is meant by
janky is the code might not be thread-safe and there may be memory leaks.

TODO: Show how to build an Audio Unit app extension.

## Building

Build by doing

    sh ./build_script.sh
