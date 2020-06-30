import React from 'react';
import PropTypes from 'prop-types';
import styles from './votePopup.module.css';

const VotePopup = (props) => (
  <div className={styles.votePopup} data-testid="rolePopup">
    <div className='popup\_inner'>  
      <div>Ballot: {props.ballot}</div>
    </div>  
  </div>  
);

VotePopup.propTypes = {};

VotePopup.defaultProps = {};

export default VotePopup;
