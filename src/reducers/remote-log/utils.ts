import { IncomingSignal, OutgoingSignal, RemoteLog } from "./model";
import { TabType } from "reducers/tab-group";
import { getInstanceId, getInstancePath } from "utils/instance-util";
import { stringifyFunctionSignature } from "utils/function-util";

let nextId = 0;

export function createRemoteLog(
	object: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction,
	signal?: OutgoingSignal,
	incomingSignal?: IncomingSignal,
): RemoteLog {
	const id = getInstanceId(object);
	const remoteType = object.IsA("RemoteEvent")
		? TabType.Event
		: object.IsA("RemoteFunction")
			? TabType.Function
			: object.IsA("BindableEvent")
				? TabType.BindableEvent
				: TabType.BindableFunction;
	return {
		id,
		object,
		type: remoteType,
		outgoing: signal ? [signal] : [],
		incoming: incomingSignal ? [incomingSignal] : [],
	};
}

export function createOutgoingSignal(
	object: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction,
	caller: LocalScript | ModuleScript | undefined,
	callback: Callback,
	traceback: Callback[],
	parameters: Record<number, unknown>,
	returns?: Record<number, unknown>,
	isActor?: boolean,
): OutgoingSignal {
	return {
		id: `signal-${nextId++}`,
		remote: object,
		remoteId: getInstanceId(object),
		name: object.Name,
		path: getInstancePath(object),
		pathFmt: getInstancePath(object),
		parameters,
		returns,
		caller,
		callback,
		traceback,
		isActor,
		timestamp: 0, // Will be set by reducer when pushed to store
	};
}

export function createIncomingSignal(
	object: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction,
	caller: LocalScript | ModuleScript | undefined,
	callback: Callback | undefined,
	parameters: Record<number, unknown>,
	isActor?: boolean,
): IncomingSignal {
	return {
		id: `signal-${nextId++}`,
		remote: object,
		remoteId: getInstanceId(object),
		name: object.Name,
		path: getInstancePath(object),
		pathFmt: getInstancePath(object),
		parameters,
		caller,
		callback,
		isActor,
		timestamp: 0,
	};
}

export function stringifySignalTraceback(signal: OutgoingSignal) {
	// Guard against empty or undefined traceback
	if (!signal.traceback || signal.traceback.size() === 0) {
		return ["(no traceback available)"];
	}

	const mapped = signal.traceback.map(stringifyFunctionSignature);
	const length = mapped.size();

	if (length === 0) {
		return ["(no traceback available)"];
	}

	// Reverse order so that the remote caller is last.
	for (let i = 0; i < length / 2; i++) {
		const temp = mapped[i];
		mapped[i] = mapped[length - i - 1];
		mapped[length - i - 1] = temp;
	}

	// Highlight the remote caller.
	if (mapped[length - 1] !== undefined) {
		mapped[length - 1] = `→ ${mapped[length - 1]} ←`;
	}

	return mapped;
}
