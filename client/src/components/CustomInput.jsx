import React from "react";
import styles from "../styles";

const regex = /^[a-zA-Z0-9]+$/;

const CustomInput = ({ label, placeholder, value, handleValueChange }) => {
  return (
      <>
          <label htmlFor="name" className={styles.label}>{label}</label>
          <input 
            type="text"
            placeholder={placeholder}
            value={value}
            onChange={(e) => {
            if(e.target.value === '' || regex.test(e.target.value)) {
                handleValueChange(e.target.value);
            }
            }} 
            className={styles.input}
          />
      </>
  );
};

export default CustomInput;
