import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";

function run(command: string, args: string[]): void {
	execFile(command, args, () => {
		// Notifications are best-effort; do not disturb Pi if a helper fails.
	});
}

export default function (pi: ExtensionAPI) {
	pi.on("agent_settled", (_event, ctx) => {
		const project = ctx.cwd.split("/").filter(Boolean).at(-1) ?? ctx.cwd;

		// Ask the desktop notification daemon to display a notification.
		run("notify-send", ["Pi", `Finished in ${project} — ready for input`]);

		// Trigger Kitty's window-alert-on-bell behavior. Audio bells are disabled
		// in the current Kitty configuration, so this should be visual only.
		process.stdout.write("\x07");

		// Explicitly set the X11 urgency hint so AwesomeWM highlights the client
		// and its tag. Awesome normally clears this when the client is focused.
		if (process.env.WINDOWID) {
			run("xdotool", ["set_window", "--urgency", "1", process.env.WINDOWID]);
		}
	});
}
