import { RootState } from "reducers";

export const selectScriptState = (state: RootState) => state.script;
export const selectScript = (state: RootState, id: string) => state.script.scripts[id];
export const selectScriptContent = (state: RootState, id: string) => state.script.scripts[id]?.content;
