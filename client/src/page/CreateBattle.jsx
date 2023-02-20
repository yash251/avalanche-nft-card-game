import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from '../styles';
import { useGlobalContext } from '../context';

import { CustomButton, CustomInput, PageHOC } from '../components';

const CreateBattle = () => {
  const { contract, battleName, setBattleName } = useGlobalContext();
  const navigate = useNavigate();
  return (
    <>
      <div className='flex flex-col mb-5'>
        <CustomInput
          label='Battle'
          placeholder='Enter your battle name'
          value={battleName}
          handleValueChange={setBattleName}
        />

        <CustomButton
          title='Create Battle'
          handleClick={handleClick}
        />
      </div>
    </>
  )
};

export default PageHOC(
  CreateBattle,
  <>Create <br /> a new Battle</>,
  <>Create your own battle and wait for other players to join you</>,
);