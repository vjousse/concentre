import "../main.css";

import { Elm } from "../src-elm/Main.elm";

import { invoke, type InvokeArgs } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";

import { attachConsole } from "@tauri-apps/plugin-log";
import { open } from "@tauri-apps/plugin-dialog";
import { getVersion } from "@tauri-apps/api/app";

// Display logs in the webview inspector
attachConsole();

declare global {
  interface Window {
    __TAURI_INTERNALS__: any;
  }
}

type ElmState = {
  color: string;
  percentage: number;
  paused: boolean;
  sessionStatus: string;
};
type SoundMessage = {
  soundId: string;
  quitAfterPlay: boolean;
};

type Message = {
  name: string;
  value: string | SoundMessage | ElmState;
};

type Notification = {
  body: string;
  title: string;
  name: string;
  red: number;
  green: number;
  blue: number;
};

type RustThemeColors = {
  long_round: string;
  short_round: string;
  focus_round: string;
  focus_round_middle: string;
  focus_round_end: string;
  background: string;
  background_light: string;
  background_lightest: string;
  foreground: string;
  foreground_darker: string;
  foreground_darkest: string;
  accent: string;
};
type ThemeColors = {
  longRound: string;
  shortRound: string;
  focusRound: string;
  focusRoundMiddle: string;
  focusRoundEnd: string;
  background: string;
  backgroundLight: string;
  backgroundLightest: string;
  foreground: string;
  foregroundDarker: string;
  foregroundDarkest: string;
  accent: string;
};

const root = document.querySelector("#app div");

let app = Elm.Main.init({
  node: root,
  flags: {
    appVersion: await getAppVersion(),
  },
});

async function safeInvoke<T = unknown>(
  cmd: string,
  args?: InvokeArgs
): Promise<T | undefined> {
  try {
    return await invoke<T>(cmd, args);
  } catch (err) {
    const message = typeof err === "string" ? err : String(err);
    console.error(`${cmd} failed:`, message);
    app.ports.sendMessageToElm.send({ error: `${cmd}: ${message}` });
    return undefined;
  }
}

app.ports.hideWindow.subscribe(function () {
  safeInvoke("hide_window");
});

app.ports.minimizeWindow.subscribe(function () {
  safeInvoke("minimize_window");
});

app.ports.closeWindow.subscribe(function () {
  safeInvoke("close_window");
});

app.ports.notify.subscribe(function (notification: Notification) {
  safeInvoke("notify", { notification: notification });
});

app.ports.sendMessageFromElm.subscribe(async function (message: Message) {
  switch (message.name) {
    case "get_init_data": {
      const initData = await safeInvoke<[any, Array<RustThemeColors>, any]>(
        "load_init_data"
      );

      if (initData !== undefined) {
        const [config, themes, pomodoroState] = initData;
        app.ports.sendMessageToElm.send({
          config,
          themes,
          pomodoro_state: pomodoroState,
        });
      }
      break;
    }

    case "choose_sound_file": {
      let file: string | null;
      try {
        file = await open({
          multiple: false,
          directory: false,
          filters: [
            {
              name: "audio (mp3, wav, ogg, flac)",
              extensions: ["mp3", "wav", "ogg", "flac"],
            },
          ],
        });
      } catch (err) {
        app.ports.sendMessageToElm.send({
          error: `choose_sound_file: ${String(err)}`,
        });
        break;
      }

      if (file === null) {
        // L’utilisateur a annulé : rien à faire
        break;
      }

      app.ports.sendMessageToElm.send({
        session_type: message.value,
        file_path: file,
      });
      break;
    }

    case "play_sound": {
      const soundMessage: SoundMessage = message.value as SoundMessage;

      safeInvoke("play_sound_command", {
        playSoundMessage: {
          sound_id: soundMessage.soundId,
          quit_after_play: soundMessage.quitAfterPlay,
        },
      });
      break;
    }

    case "quit": {
      safeInvoke("quit");
      break;
    }

    case "update_current_state": {
      const state: ElmState = message.value as ElmState;
      const rgb = hexToRgb(state.color);

      if (rgb !== null) {
        safeInvoke("change_icon", {
          red: rgb.r,
          green: rgb.g,
          blue: rgb.b,
          fillPercentage: state.percentage,
          paused: state.paused,
        });
      } else {
        console.warn(
          `change_icon skipped: unsupported color format "${state.color}"`
        );
      }

      safeInvoke("update_session_status", {
        status: state.sessionStatus,
      });

      break;
    }

    case "update_config": {
      const newState = await safeInvoke("update_config", {
        config: message.value,
      });
      if (newState !== undefined) {
        app.ports.sendMessageToElm.send(newState);
      }
      break;
    }

    default: {
      const newState = await safeInvoke("handle_external_message", message);
      if (newState !== undefined) {
        app.ports.sendMessageToElm.send(newState);
      }
    }
  }
});

app.ports.setThemeColors.subscribe(function (themeColors: ThemeColors) {
  const mainHtmlElement = document.documentElement;
  mainHtmlElement.style.setProperty(
    "--color-long-round",
    themeColors.longRound
  );
  mainHtmlElement.style.setProperty(
    "--color-short-round",
    themeColors.shortRound
  );
  mainHtmlElement.style.setProperty(
    "--color-focus-round",
    themeColors.focusRound
  );
  mainHtmlElement.style.setProperty(
    "--color-background",
    themeColors.background
  );
  mainHtmlElement.style.setProperty(
    "--color-background-light",
    themeColors.backgroundLight
  );
  mainHtmlElement.style.setProperty(
    "--color-background-lightest",
    themeColors.backgroundLightest
  );
  mainHtmlElement.style.setProperty(
    "--color-foreground",
    themeColors.foreground
  );
  mainHtmlElement.style.setProperty(
    "--color-foreground-darker",
    themeColors.foregroundDarker
  );
  mainHtmlElement.style.setProperty(
    "--color-foreground-darkest",
    themeColors.foregroundDarkest
  );
  mainHtmlElement.style.setProperty("--color-accent", themeColors.accent);
});

await listen("tick-event", () => {
  app.ports.tick.send(null);
});

await listen("external-message", (message) => {
  app.ports.sendMessageToElm.send(message.payload);
});

await listen("toggle-play", () => {
  app.ports.togglePlay.send(null);
});

await listen("skip", () => {
  app.ports.skip.send(null);
});

function hexToRgb(hex: string) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16),
      }
    : null;
}

async function getAppVersion() {
  if (window.__TAURI_INTERNALS__ === undefined) {
    return "unknown";
  } else {
    return await getVersion();
  }
}
