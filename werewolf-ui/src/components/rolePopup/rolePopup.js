import React from 'react';
import PropTypes from 'prop-types';
import styles from './rolePopup.module.css';

const RolePopup = (props) => (
  <div className={styles.rolePopup} data-testid="rolePopup">
    <div className='popup\_inner'>  
      <div>Role: {props.role.name}</div>
      <div>Description: {props.role.description}</div>
    </div>  
  </div>  
);

RolePopup.propTypes = {};

RolePopup.defaultProps = {};

export default RolePopup;
