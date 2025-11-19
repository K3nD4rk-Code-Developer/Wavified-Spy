import { codifyTable } from "./codify";
import { getInstancePath } from "./instance-util";

type PathNotationStyle = "dot" | "waitforchild" | "findfirstchild";

export function genScript(
	remote: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction,
	args: unknown[],
	pathNotation: PathNotationStyle = "dot",
): string {
	let gen = "";

	const hasArgs = next(args)[0] !== undefined;

	if (hasArgs) {
		gen = `local args = ${codifyTable(args, 0, { pathNotation })}\n\n`;
	}

	gen += `local remote = ${getInstancePath(remote, pathNotation)}\n`;

	if (remote.IsA("RemoteEvent")) {
		if (hasArgs) {
			gen += "remote:FireServer(unpack(args))";
		} else {
			gen += "remote:FireServer()";
		}
	} else if (remote.IsA("RemoteFunction")) {
		if (hasArgs) {
			gen += "local result = remote:InvokeServer(unpack(args))";
		} else {
			gen += "local result = remote:InvokeServer()";
		}
	} else if (remote.IsA("BindableEvent")) {
		if (hasArgs) {
			gen += "remote:Fire(unpack(args))";
		} else {
			gen += "remote:Fire()";
		}
	} else if (remote.IsA("BindableFunction")) {
		if (hasArgs) {
			gen += "local result = remote:Invoke(unpack(args))";
		} else {
			gen += "local result = remote:Invoke()";
		}
	}

	return gen;
}