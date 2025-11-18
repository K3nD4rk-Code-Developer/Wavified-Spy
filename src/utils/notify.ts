/**
 * Notification utility that uses Utility.UtilityNotify if available,
 * otherwise falls back to StarterGui notifications
 */

declare const Utility: {
	UtilityNotify?: (error: boolean, message: string, lifetime: number) => void;
} | undefined;

export function notify(message: string, lifetime: number = 3, isError: boolean = false) {
	// Try to use Utility.UtilityNotify if available
	if (Utility !== undefined && typeOf(Utility) === "table" && Utility.UtilityNotify !== undefined) {
		Utility.UtilityNotify(isError, message, lifetime);
		return;
	}

	// Fallback to StarterGui notifications
	const StarterGui = game.GetService("StarterGui");
	StarterGui.SetCore("SendNotification", {
		Title: isError ? "Error" : "Wavified Spy",
		Text: message,
		Duration: lifetime,
	});
}
