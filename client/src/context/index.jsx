import React, { useState, useEffect, useRef, useContext, createContext } from "react";
import { ethers } from "ethers";
import Web3Modal from "web3modal";
import { useNavigate } from 'react-router-dom';

const GlobalContext = createContext();

export const GlobalContextProvider = ({ children }) => { 
    return (
        <GlobalContext.Provider value={{
            
        }}>
            {children}
        </GlobalContext.Provider>
    )
}

export const useGlobalContext = () => { useContext(GlobalContext) };