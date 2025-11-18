const idsByObject = new Map<Instance, string>();
const objectsById = new Map<string, Instance>();
let nextId = 0;

const hasSpecialCharacters = (str: string) => str.match("[a-zA-Z0-9_]+")[0] !== str;

export function isInstanceInDataModel(object: Instance): boolean {
	let current: Instance | undefined = object;
	while (current) {
		if (current === game) {
			return true;
		}
		current = current.Parent;
	}
	return false;
}

export function getInstanceId(object: Instance): string {
	if (!idsByObject.has(object)) {
		const id = `instance-${nextId++}`;
		idsByObject.set(object, id);
		objectsById.set(id, object);
	}
	return idsByObject.get(object)!;
}

export function getInstanceFromId(id: string): Instance | undefined {
	return objectsById.get(id);
}

type PathNotationStyle = "dot" | "waitforchild" | "findfirstchild";

export function getInstancePath(object: Instance, notation: PathNotationStyle = "dot") {
	let path = "";
	let current: Instance | undefined = object;
	let isInDataModel = false;
	let isFirst = true;

	do {
		if (current === game) {
			path = `game${path}`;
			isInDataModel = true;
		} else if (current.Parent === game) {
			path = `:GetService(${string.format("%q", current.ClassName)})${path}`;
		} else {
			if (notation === "dot") {
				path = hasSpecialCharacters(current.Name)
					? `[${string.format("%q", current.Name)}]${path}`
					: `.${current.Name}${path}`;
			} else if (notation === "waitforchild") {
				const nameStr = string.format("%q", current.Name);
				path = isFirst ? `:WaitForChild(${nameStr})${path}` : `:WaitForChild(${nameStr})${path}`;
			} else if (notation === "findfirstchild") {
				const nameStr = string.format("%q", current.Name);
				path = isFirst ? `:FindFirstChild(${nameStr})${path}` : `:FindFirstChild(${nameStr})${path}`;
			}
			isFirst = false;
		}
		current = current.Parent;
	} while (current);

	if (!isInDataModel) {
		path = "(nil)" + path;
	}

	// Reformatting
	[path] = path.gsub('^game:GetService%("Workspace"%)', "workspace");

	return path;
}
