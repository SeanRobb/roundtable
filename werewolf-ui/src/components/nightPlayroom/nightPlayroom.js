import React from 'react';
import PropTypes from 'prop-types';
import styles from './nightPlayroom.module.css';

const NightPlayroom = () => (
  <div className={styles.nightPlayroom} data-testid="NightPlayroom">
    NightPlayroom Component
  </div>
);

NightPlayroom.propTypes = {};

NightPlayroom.defaultProps = {};

export default NightPlayroom;
