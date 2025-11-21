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
	let i = 0;

	while (i < code.size()) {
		const char = code.sub(i + 1, i + 1);

		// Comments
		if (char === "-" && code.sub(i + 2, i + 2) === "-") {
			const [endOfLine] = code.find("\n", i + 1);
			const lineEnd = endOfLine !== undefined ? endOfLine - 1 : code.size();
			const comment = code.sub(i + 1, lineEnd);
			result += `<font color="rgb(${COLORS.comment})">${escapeRichText(comment)}</font>`;
			i = lineEnd;
			continue;
		}

		// Strings (double quotes)
		if (char === '"') {
			let j = i + 1;
			let escaped = false;
			while (j < code.size()) {
				const c = code.sub(j + 2, j + 2);
				if (c === "\\" && !escaped) {
					escaped = true;
					j++;
					continue;
				}
				if (c === '"' && !escaped) {
					break;
				}
				escaped = false;
				j++;
			}
			const str = code.sub(i + 1, j + 2);
			result += `<font color="rgb(${COLORS.string})">${escapeRichText(str)}</font>`;
			i = j + 1;
			continue;
		}

		// Strings (single quotes)
		if (char === "'") {
			let j = i + 1;
			let escaped = false;
			while (j < code.size()) {
				const c = code.sub(j + 2, j + 2);
				if (c === "\\" && !escaped) {
					escaped = true;
					j++;
					continue;
				}
				if (c === "'" && !escaped) {
					break;
				}
				escaped = false;
				j++;
			}
			const str = code.sub(i + 1, j + 2);
			result += `<font color="rgb(${COLORS.string})">${escapeRichText(str)}</font>`;
			i = j + 1;
			continue;
		}

		// Numbers
		const [isDigit] = char.match("%d");
		const nextChar = code.sub(i + 2, i + 2);
		const [nextIsDigit] = nextChar.match("%d");

		if (isDigit !== undefined || (char === "." && nextIsDigit !== undefined)) {
			let j = i;
			while (j < code.size()) {
				const c = code.sub(j + 2, j + 2);
				const [isNumChar] = c.match("[%d%.]");
				if (isNumChar === undefined) break;
				j++;
			}
			const num = code.sub(i + 1, j + 1);
			result += `<font color="rgb(${COLORS.number})">${num}</font>`;
			i = j;
			continue;
		}

		// Identifiers and keywords
		const [isAlpha] = char.match("[%a_]");
		if (isAlpha !== undefined) {
			let j = i;
			while (j < code.size()) {
				const c = code.sub(j + 2, j + 2);
				const [isWordChar] = c.match("[%w_]");
				if (isWordChar === undefined) break;
				j++;
			}
			const word = code.sub(i + 1, j + 1);

			if (KEYWORDS.includes(word)) {
				result += `<font color="rgb(${COLORS.keyword})">${word}</font>`;
			} else if (BUILTIN_FUNCTIONS.includes(word)) {
				result += `<font color="rgb(${COLORS.builtin})">${word}</font>`;
			} else {
				// Check if it's followed by ( to identify as function
				let k = j + 1;
				while (k < code.size()) {
					const c = code.sub(k + 2, k + 2);
					const [isSpace] = c.match("%s");
					if (isSpace === undefined) break;
					k++;
				}
				if (code.sub(k + 2, k + 2) === "(") {
					result += `<font color="rgb(${COLORS.function})">${word}</font>`;
				} else {
					result += `<font color="rgb(${COLORS.default})">${word}</font>`;
				}
			}
			i = j;
			continue;
		}

		// Operators and other characters
		result += escapeRichText(char);
		i++;
	}

	return result;
}
