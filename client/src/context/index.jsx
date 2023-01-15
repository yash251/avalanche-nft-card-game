import React, { useState, useEffect, useRef, useContext, createContext } from "react";
import { ethers } from "ethers";
import Web3Modal from "web3modal";
import { useNavigate } from 'react-router-dom';

import { ABI, ADDRESS } from '../contract';

const GlobalContext = createContext();

export const GlobalContextProvider = ({ children }) => {
    const [walletAddress, setWalletAddress] = useState('');
    const [provider, setProvider] = useState('');
    const [contract, setContract] = useState('');

    const updateCurrentWalletAddress = async () => {
        const accounts = await window.ethereum.request({
            method: 'eth_requestAccounts'
        })
    }

    useEffect(() => {
        updateCurrentWalletAddress();
    }, []);

    useEffect(() => { 
        const setSmartContractAndProvider = async () => {
            const web3Modal = new Web3Modal();
            const connection = await web3Modal.connect();
            const newProvider = new ethers.providers.Web3Provider(connection);
            const signer = newProvider.signer();
            const newContract = new ethers.Contract(ADDRESS, ABI, signer);

            setProvider(newProvider);
        }
        setSmartContractAndProvider();
    }, []);

    return (
        <GlobalContext.Provider value={{
            
        }}>
            {children}
        </GlobalContext.Provider>
    )
}

export const useGlobalContext = () => { useContext(GlobalContext) };