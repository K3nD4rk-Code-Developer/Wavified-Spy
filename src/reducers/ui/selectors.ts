import { RootState } from "reducers";

export const selectUIVisible = (state: RootState) => state.ui.visible;
export const selectToggleKey = (state: RootState) => state.ui.toggleKey;
