import { getInstancePath, isInstanceInDataModel } from "./instance-util";

type PathNotationStyle = "dot" | "waitforchild" | "findfirstchild";

interface CodifyContext {
	pathNotation: PathNotationStyle;
}

const createTransformers = (context: CodifyContext): Record<string, Callback> => ({
	table: (value: object, level: number) => (level === -1 ? codifyTableFlat(value, context) : codifyTable(value, level + 1, context)),
	string: (value: string) => string.format("%q", value.gsub("\n", "\\n")[0]),
	number: (value: number) => tostring(value),
	boolean: (value: boolean) => tostring(value),
	Instance: (value: Instance) => {
		// Check if instance is in the DataModel
		if (isInstanceInDataModel(value)) {
			return getInstancePath(value, context.pathNotation);
		} else {
			// Instance is not in DataModel, represent it as a created instance
			const parent = value.Parent;
			const parentStr = parent ? codify(parent, 0, context) : "nil";
			return `Instance.new(${string.format("%q", value.ClassName)}, ${parentStr})`;
		}
	},
	BrickColor: (value: BrickColor) => `BrickColor.new("${value.Name}")`,
	Color3: (value: Color3) => `Color3.new(${value.R}, ${value.G}, ${value.B})`,
	ColorSequenceKeypoint: (value: ColorSequenceKeypoint, level: number, context: CodifyContext) =>
		`ColorSequenceKeypoint.new(${value.Time}, ${codify(value.Value, level, context)})`,
	ColorSequence: (value: ColorSequence, level: number, context: CodifyContext) => `ColorSequence.new(${codify(value.Keypoints, level, context)})`,
	NumberRange: (value: NumberRange) => `NumberRange.new(${value.Min}, ${value.Max})`,
	NumberSequenceKeypoint: (value: NumberSequenceKeypoint, level: number, context: CodifyContext) =>
		`NumberSequenceKeypoint.new(${value.Time}, ${codify(value.Value, level, context)})`,
	NumberSequence: (value: NumberSequence, level: number, context: CodifyContext) => `NumberSequence.new(${codify(value.Keypoints, level, context)})`,
	Vector3: (value: Vector3) => `Vector3.new(${value.X}, ${value.Y}, ${value.Z})`,
	Vector2: (value: Vector2) => `Vector2.new(${value.X}, ${value.Y})`,
	UDim2: (value: UDim2) => `UDim2.new(${value.X.Scale}, ${value.X.Offset}, ${value.Y.Scale}, ${value.Y.Offset})`,
	Ray: (value: Ray, level: number, context: CodifyContext) => `Ray.new(${codify(value.Origin, level, context)}, ${codify(value.Direction, level, context)})`,
	CFrame: (value: CFrame) => `CFrame.new(${value.GetComponents().join(", ")})`,
});

export function codify(value: unknown, level = 0, context: CodifyContext = { pathNotation: "dot" }): string {
	const transformers = createTransformers(context);
	const transformer = transformers[typeOf(value)];
	if (transformer) {
		return transformer(value, level, context);
	} else {
		return `${tostring(value)} --[[${typeOf(value)} not supported]]`;
	}
}

export function codifyTable(object: object, level = 0, context: CodifyContext = { pathNotation: "dot" }): string {
	const lines = [];
	const indent = string.rep("	", level + 1);

	for (const [key, value] of pairs(object)) {
		if (typeIs(value, "function") || typeIs(value, "thread")) {
			continue;
		}
		lines.push(`${indent}[${codify(key, level, context)}] = ${codify(value, level, context)}`);
	}

	if (lines.size() === 0) {
		return "{}";
	}

	return `{\n${lines.join(",\n")}\n${indent.sub(1, -2)}}`;
}

export function codifyTableFlat(object: object, context: CodifyContext = { pathNotation: "dot" }): string {
	const lines = [];

	for (const [key, value] of pairs(object)) {
		if (typeIs(value, "function") || typeIs(value, "thread")) {
			continue;
		}
		lines.push(`[${codify(key, -1, context)}] = ${codify(value, -1, context)}`);
	}

	if (lines.size() === 0) {
		return "{}";
	}

	return `{ ${lines.join(", ")} }`;
}
