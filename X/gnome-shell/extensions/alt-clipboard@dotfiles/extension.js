import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class AltClipboard extends Extension {
    enable() {
        this._settings = this.getSettings();
        this._keyboard = global.stage.context.get_backend().get_default_seat()
            .create_virtual_device(Clutter.InputDeviceType.KEYBOARD_DEVICE);
        this._source = 0;
        for (const action of ['copy', 'paste', 'select-all']) {
            Main.wm.addKeybinding(`alt-${action}`, this._settings,
                Meta.KeyBindingFlags.IGNORE_AUTOREPEAT,
                Shell.ActionMode.NORMAL | Shell.ActionMode.OVERVIEW,
                () => this._queue(action));
        }
    }

    _queue(action) {
        if (this._source)
            GLib.Source.remove(this._source);

        const window = global.display.focus_window;
        const focus = global.stage.key_focus;
        const mode = Main.actionMode;
        const app = window ? Shell.WindowTracker.get_default().get_window_app(window) : null;
        const id = app?.get_id() ?? window?.get_wm_class() ?? '';
        const terminal = /alacritty|gnome-terminal|org\.gnome\.(Console|Ptyxis)|kitty|wezterm|foot/i.test(id);
        const shift = action !== 'select-all' &&
            (terminal || (action === 'paste' && this._settings.get_boolean('paste-with-shift')));
        const deadline = GLib.get_monotonic_time() + 5_000_000;

        // Virtual devices cannot release a physical keyboard's held Alt key.
        // Wait for release, and cancel if focus moves rather than pasting elsewhere.
        this._source = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10, () => {
            if (global.display.focus_window !== window || global.stage.key_focus !== focus ||
                Main.actionMode !== mode || GLib.get_monotonic_time() > deadline) {
                this._source = 0;
                return GLib.SOURCE_REMOVE;
            }
            const modifiers = global.get_pointer()[2];
            const held = Clutter.ModifierType.MOD1_MASK | Clutter.ModifierType.CONTROL_MASK |
                Clutter.ModifierType.SHIFT_MASK | Clutter.ModifierType.SUPER_MASK;
            if (modifiers & held)
                return GLib.SOURCE_CONTINUE;

            this._source = 0;
            const keys = [Clutter.KEY_Control_L];
            if (shift)
                keys.push(Clutter.KEY_Shift_L);
            keys.push({'copy': Clutter.KEY_c, 'paste': Clutter.KEY_v,
                'select-all': Clutter.KEY_a}[action]);
            for (const key of keys)
                this._keyboard.notify_keyval(GLib.get_monotonic_time(), key, Clutter.KeyState.PRESSED);
            for (const key of keys.reverse())
                this._keyboard.notify_keyval(GLib.get_monotonic_time(), key, Clutter.KeyState.RELEASED);
            return GLib.SOURCE_REMOVE;
        });
    }

    disable() {
        for (const action of ['copy', 'paste', 'select-all'])
            Main.wm.removeKeybinding(`alt-${action}`);
        if (this._source)
            GLib.Source.remove(this._source);
        this._source = 0;
        this._keyboard = null;
        this._settings = null;
    }
}
