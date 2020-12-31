import React from 'react';
import PropTypes from 'prop-types';
import styles from './waitingRoomPlayer.module.css';

const WaitingRoomPlayer = (props) => (
  <div className={styles.WaitingRoomPlayer} data-testid="waitingRoomPlayer">
    {props.player.name}{props.player.isNarrator?" is the narrator":""}
  </div>
);

WaitingRoomPlayer.propTypes = {};

WaitingRoomPlayer.defaultProps = {};

export default WaitingRoomPlayer;