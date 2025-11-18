import Rodux from "@rbxts/rodux";
import actionBarReducer, { ActionBarState } from "./action-bar";
import remoteLogReducer, { RemoteLogState } from "./remote-log";
import scriptReducer, { ScriptState } from "./script";
import tabGroupReducer, { TabGroupState } from "./tab-group";
import tracebackReducer, { TracebackState } from "./traceback";

export interface RootState {
	actionBar: ActionBarState;
	remoteLog: RemoteLogState;
	script: ScriptState;
	tabGroup: TabGroupState;
	traceback: TracebackState;
}

export default Rodux.combineReducers<RootState, Rodux.AnyAction>({
	actionBar: actionBarReducer,
	remoteLog: remoteLogReducer,
	script: scriptReducer,
	tabGroup: tabGroupReducer,
	traceback: tracebackReducer,
});
