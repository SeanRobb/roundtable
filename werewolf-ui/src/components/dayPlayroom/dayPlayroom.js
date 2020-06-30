import React from 'react';
import PropTypes from 'prop-types';
import styles from './dayPlayroom.module.css';

const DayPlayroom = () => (
  <div className={styles.dayPlayroom} data-testid="DayPlayroom">
    DayPlayroom Component
  </div>
);

DayPlayroom.propTypes = {};

DayPlayroom.defaultProps = {};

export default DayPlayroom;
