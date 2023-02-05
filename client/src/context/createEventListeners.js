import React from "react";

import { ethers } from "ethers";
import { ABI } from "../contract";

const addNewEvent = (eventFilter, provider, cb) => {
    provider.removeListener(eventFilter);

    provider.on(eventFilter, (Logs) => {
        const parsedLog = (new ethers.utils.Interface(ABI)).parseLog(Logs);

        cb(parsedLog);
    })
};

export default createEventListeners;
