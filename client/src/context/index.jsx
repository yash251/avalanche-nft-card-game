import React, { useState, useEffect, useRef, useContext, createContext } from "react";
import { ethers } from "ethers";
import Web3Modal from "web3modal";
import { useNavigate } from 'react-router-dom';

import { ABI, ADDRESS } from '../contract';
import { createEventListeners } from "./createEventListeners";
import { GetParams } from '../utils/onboard';

const GlobalContext = createContext();

export const GlobalContextProvider = ({ children }) => {
    const [walletAddress, setWalletAddress] = useState('');
    const [provider, setProvider] = useState('');
    const [contract, setContract] = useState('');
    const [showAlert, setShowAlert] = useState({ status: false, type: 'info', message: '' });
    const [battleName, setBattleName] = useState('');
    const [gameData, setGameData] = useState({
        players: [],
        pendingBattles: [],
        activeBattle: null,
    })
    const [updateGameData, setUpdateGameData] = useState(0);
    const [battleGround, setBattleGround] = useState('bg-astral');
    const [step, setStep] = useState(1);
    const [errorMessage, setErrorMessage] = useState('');
    
    const player1Ref = useRef();
    const player2Ref = useRef();
    
    const navigate = useNavigate();

    useEffect(() => {
        const battlegroundFromLocalStorage = localStorage.getItem('battleground');

        if (battlegroundFromLocalStorage) {
            setBattleGround(battlegroundFromLocalStorage);
        }
        else {
            localStorage.setItem('battleground', battleGround);
        }
    }, []);

    // reset web3 onboarding modal params
    useEffect(() => {
        const resetParams = async () => {
            const currentStep = await GetParams();

            setStep(currentStep.step);
        }

        resetParams();

        window?.ethereum?.on('chainChanged', () => resetParams());
        window?.ethereum?.on('accountsChanged', () => resetParams());
    }, []);

    // set the wallet address to the state
    const updateCurrentWalletAddress = async () => {
        const accounts = await window?.ethereum?.request({ method: 'eth_requestAccounts' });
    
        if (accounts) setWalletAddress(accounts[0]);
    };
    
    useEffect(() => {
        updateCurrentWalletAddress();

        window?.ethereum?.on('accountsChanged',
        updateCurrentWalletAddress);
    }, []);

    // set the smart contract & the provider to the state
    useEffect(() => { 
        const setSmartContractAndProvider = async () => {
            const web3Modal = new Web3Modal();
            const connection = await web3Modal.connect();
            const newProvider = new ethers.providers.Web3Provider(connection);
            const signer = newProvider.getSigner();
            const newContract = new ethers.Contract(ADDRESS, ABI, signer);

            setProvider(newProvider);
            setContract(newContract);
        }
        setSmartContractAndProvider();
    }, []);

    useEffect(() => { 
        if (step !== -1 && contract) {
            createEventListeners({
                navigate, contract, provider, walletAddress, setShowAlert, setUpdateGameData, player1Ref, player2Ref
            })
        }
    }, [contract, step]);

    useEffect(() => {
        if(showAlert?.status) {
            const timer = setTimeout(() => {
                setShowAlert({ status: false, type: 'info', message: '' });
            }, 5000);

            return () => clearTimeout(timer);
        }
    }, [showAlert]);

    // handle error messages
    useEffect(() => {
        if (errorMessage) {
            const parsedErrorMessage = errorMessage?.reason?.slice('execution reverted: '.length).slice(0, -1);

            if (parsedErrorMessage) {
                setShowAlert({
                    status: true,
                    type: 'failure',
                    message: parsedErrorMessage
                });
            }
        }
    }, [errorMessage]);
    

    // set the game data to the state
    useEffect(() => {
        const fetchGameData = async () => { 
            const fetchedBattles = await contract.getAllBattles();
            const pendingBattles = fetchedBattles.filter((battle) => battle.status === 0);
            let activeBattle = null;

            fetchedBattles.forEach((battle) => { 
                if (battle.players.find((player) => player.toLowerCase() === walletAddress.toLowerCase())) {
                    if (battle.winner.startsWith('0x00')) {
                        activeBattle = battle;
                    }
                }
            })

            setGameData({
                pendingBattles: pendingBattles.slice(1),
                activeBattle,
            })
        }

        if (contract) fetchGameData();
    }, [contract, updateGameData])
    
    return (
        <GlobalContext.Provider value={{
            contract, walletAddress, showAlert, setShowAlert, battleName, setBattleName, gameData, battleGround, setBattleGround, errorMessage, setErrorMessage, player1Ref, player2Ref, updateCurrentWalletAddress
        }}>
            {children}
        </GlobalContext.Provider>
    )
}

export const useGlobalContext = () => { useContext(GlobalContext) };