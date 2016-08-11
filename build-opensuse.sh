set -e

zypper se -t pattern devel
zypper --non-interactive in --type pattern devel_basis devel_C_C++
zypper --non-interactive in gcc gcc-c++ gtk3-devel gtkmm3-devel gstreamer-0_10-devel clutter-devel libwebkitgtk-devel libgda-5_0-devel gobject-introspection-devel
