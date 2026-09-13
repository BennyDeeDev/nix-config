# Ryujinx

Ryujinx configuration is host-local and managed through the UI.

1. Install and launch the Ryujinx Flatpak.
2. Import locally obtained `prod.keys` and firmware through Ryujinx.
3. Add the host's `${my.gaming.gamesPath}/Switch` directory to the game list.
4. Configure controller bindings and resolution per host.
5. Re-import keys or firmware manually when updating versions.

Home Manager only installs Ryujinx, grants access to the Switch directory, and
creates that directory. It does not manage Ryujinx's mutable configuration,
keys, firmware, controller mappings, or graphics settings.

# Ludusavi

Ludusavi scans Steam, Bottles, and the Switch manifest. Game entries are
identified by title rather than by backup root. If a game with the same title
exists in Steam and Bottles, the saves may be combined into one Ludusavi entry
and can conflict with each other. Ludusavi has no per-root namespace for this
case, so the collision cannot currently be avoided in this profile.

# Steam ROM Manager

Home Manager generates the essential SRM settings and parser definitions.
SRM supplies defaults for the remaining parser fields and normalizes its files
when the UI saves them. UI changes to those generated files are overwritten by
the next Home Manager activation; persistent shared changes belong in the gaming
profile and host-specific changes belong in the host's SRM module.
