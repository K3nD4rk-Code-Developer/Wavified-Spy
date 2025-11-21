import { TabGroupColumn, TabType } from "./model";
import { TextService } from "@rbxts/services";

export const MAX_TAB_CAPTION_WIDTH = 150;

export function createTabColumn(id: string, caption: string, tabType: TabType, canClose = true, scriptContent?: string): TabGroupColumn {
	print("[createTabColumn] Creating tab:", id, "caption:", caption, "tabType:", tabType, "typeof tabType:", typeOf(tabType), "canClose:", canClose);
	const tab: TabGroupColumn = {
		id: id,
		caption: caption,
		type: tabType,
		canClose: canClose,
		scriptContent: scriptContent,
	};
	print("[createTabColumn] Created tab object:", tab, "type property:", tab.type, "typeof tab.type:", typeOf(tab.type));
	return tab;
}

export function getTabCaptionWidth(tab: TabGroupColumn) {
	const textSize = TextService.GetTextSize(tab.caption, 11, "Gotham", new Vector2(300, 0));
	return math.min(textSize.X, MAX_TAB_CAPTION_WIDTH);
}

export function getTabWidth(tab: TabGroupColumn) {
	const captionWidth = getTabCaptionWidth(tab);
	const iconWidth = 16 + 6;
	const closeWidth = tab.canClose ? 16 + 6 : 3;
	return 8 + iconWidth + captionWidth + closeWidth + 8;
}

export function getTabOffset(tabs: TabGroupColumn[], tab: TabGroupColumn) {
	let offset = 0;
	for (const t of tabs) {
		if (t === tab) break;
		offset += getTabWidth(t);
	}
	return offset;
}
