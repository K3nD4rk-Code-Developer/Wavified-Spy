import { TabGroupColumn, TabType } from "reducers/tab-group";

/**
 * Generates a unique script tab name by adding an index if needed
 * @param baseName The base name for the script (e.g., "Script")
 * @param existingTabs All existing tabs
 * @returns A unique name with index if needed (e.g., "Script - 1", "Script - 2")
 */
export function generateUniqueScriptName(baseName: string, existingTabs: TabGroupColumn[]): string {
	// Find all script tabs with the same base name
	const scriptTabs = existingTabs.filter((tab) => {
		if (tab.type !== TabType.Script) return false;
		const match = tab.caption.match(`^${baseName}( - \\d+)?$`);
		return match !== undefined && match[0] !== undefined;
	});

	// If no existing tabs with this name, return the base name
	if (scriptTabs.size() === 0) {
		return baseName;
	}

	// Find the highest index
	let maxIndex = 0;
	for (const tab of scriptTabs) {
		const match = tab.caption.match(`^${baseName} - (\\d+)$`);
		if (match !== undefined && match[0] !== undefined && match[1] !== undefined) {
			const index = tonumber(match[1]);
			if (index !== undefined && index > maxIndex) {
				maxIndex = index;
			}
		} else if (tab.caption === baseName) {
			// If there's a tab with just the base name, treat it as index 0
			maxIndex = math.max(maxIndex, 1);
		}
	}

	// Return the next index
	return `${baseName} - ${maxIndex + 1}`;
}
