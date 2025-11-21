/**
 * Syntax highlighting utility for Lua code
 * Converts plain Lua code to RichText with syntax highlighting
 */

const KEYWORDS = [
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"end",
	"false",
	"for",
	"function",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while",
];

const BUILTIN_FUNCTIONS = [
	"print",
	"warn",
	"error",
	"assert",
	"type",
	"typeof",
	"pcall",
	"xpcall",
	"ipairs",
	"pairs",
	"next",
	"select",
	"tonumber",
	"tostring",
	"getmetatable",
	"setmetatable",
	"rawget",
	"rawset",
	"rawequal",
	"unpack",
	"task",
	"wait",
	"spawn",
	"delay",
	"game",
	"workspace",
	"FireServer",
	"InvokeServer",
	"FindFirstChild",
	"WaitForChild",
];

const COLORS = {
	keyword: "86, 156, 214", // Blue
	string: "206, 145, 120", // Orange
	number: "181, 206, 168", // Light green
	comment: "106, 153, 85", // Green
	function: "220, 220, 170", // Yellow
	builtin: "78, 201, 176", // Cyan
	operator: "212, 212, 212", // Light gray
	default: "212, 212, 212", // Light gray
};

function escapeRichText(text: string): string {
	// Need to escape & first, then < and >
	let result = text.gsub("&", "&amp;")[0];
	result = result.gsub("<", "&lt;")[0];
	result = result.gsub(">", "&gt;")[0];
	return result;
}

export function highlightLua(code: string): string {
	let result = "";
	let pos = 1; // Lua strings are 1-indexed

	while (pos <= code.size()) {
		const char = code.sub(pos, pos);

		// Comments
		if (char === "-" && code.sub(pos + 1, pos + 1) === "-") {
			const [endOfLine] = code.find("\n", pos);
			const lineEnd = endOfLine !== undefined ? endOfLine - 1 : code.size();
			const comment = code.sub(pos, lineEnd);
			result += `<font color="rgb(${COLORS.comment})">${escapeRichText(comment)}</font>`;
			pos = lineEnd + 1;
			continue;
		}

		// Strings (double quotes)
		if (char === '"') {
			let endPos = pos + 1;
			let escaped = false;
			while (endPos <= code.size()) {
				const c = code.sub(endPos, endPos);
				if (c === "\\" && !escaped) {
					escaped = true;
				} else if (c === '"' && !escaped) {
					break;
				} else {
					escaped = false;
				}
				endPos++;
			}
			const str = code.sub(pos, endPos);
			result += `<font color="rgb(${COLORS.string})">${escapeRichText(str)}</font>`;
			pos = endPos + 1;
			continue;
		}

		// Strings (single quotes)
		if (char === "'") {
			let endPos = pos + 1;
			let escaped = false;
			while (endPos <= code.size()) {
				const c = code.sub(endPos, endPos);
				if (c === "\\" && !escaped) {
					escaped = true;
				} else if (c === "'" && !escaped) {
					break;
				} else {
					escaped = false;
				}
				endPos++;
			}
			const str = code.sub(pos, endPos);
			result += `<font color="rgb(${COLORS.string})">${escapeRichText(str)}</font>`;
			pos = endPos + 1;
			continue;
		}

		// Numbers
		const [isDigit] = char.match("%d");
		const nextChar = code.sub(pos + 1, pos + 1);
		const [nextIsDigit] = nextChar.match("%d");

		if (isDigit !== undefined || (char === "." && nextIsDigit !== undefined)) {
			let endPos = pos;
			while (endPos <= code.size()) {
				const c = code.sub(endPos, endPos);
				const [isNumChar] = c.match("[%d%.]");
				if (isNumChar === undefined) break;
				endPos++;
			}
			const num = code.sub(pos, endPos - 1);
			result += `<font color="rgb(${COLORS.number})">${num}</font>`;
			pos = endPos;
			continue;
		}

		// Identifiers and keywords
		const [isAlpha] = char.match("[%a_]");
		if (isAlpha !== undefined) {
			let endPos = pos;
			while (endPos <= code.size()) {
				const c = code.sub(endPos, endPos);
				const [isWordChar] = c.match("[%w_]");
				if (isWordChar === undefined) break;
				endPos++;
			}
			const word = code.sub(pos, endPos - 1);

			if (KEYWORDS.includes(word)) {
				result += `<font color="rgb(${COLORS.keyword})">${word}</font>`;
			} else if (BUILTIN_FUNCTIONS.includes(word)) {
				result += `<font color="rgb(${COLORS.builtin})">${word}</font>`;
			} else {
				// Check if it's followed by ( to identify as function
				let checkPos = endPos;
				while (checkPos <= code.size()) {
					const c = code.sub(checkPos, checkPos);
					const [isSpace] = c.match("%s");
					if (isSpace === undefined) break;
					checkPos++;
				}
				if (code.sub(checkPos, checkPos) === "(") {
					result += `<font color="rgb(${COLORS.function})">${word}</font>`;
				} else {
					result += `<font color="rgb(${COLORS.default})">${word}</font>`;
				}
			}
			pos = endPos;
			continue;
		}

		// Operators and other characters
		result += escapeRichText(char);
		pos++;
	}

	return result;
}
