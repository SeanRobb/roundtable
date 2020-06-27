import React from 'react';
import PropTypes from 'prop-types';
import styles from './playroom.module.css';

const Playroom = () => (
  <div className={styles.Playroom} data-testid="Playroom">
    Playroom Component
  </div>
);

Playroom.propTypes = {};

Playroom.defaultProps = {};

export default Playroom;
