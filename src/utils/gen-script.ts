import { codifyTable } from "./codify";
import { getInstancePath } from "./instance-util";

export function genScript(remote: RemoteEvent | RemoteFunction, args: unknown[]): string {
    let gen = "";

    const hasArgs = next(args)[0] !== undefined;

    if (hasArgs) {
        gen = `local args = ${codifyTable(args)}\n\n`;
    }

    gen += `local remote = ${getInstancePath(remote)}\n`;

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
    }

    return gen;
}