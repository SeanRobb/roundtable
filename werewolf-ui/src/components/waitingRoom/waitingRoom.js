import React from 'react';
import PropTypes from 'prop-types';
import styles from './waitingRoom.module.css';
import WaitingRoomPlayer from '../waitingRoomPlayer/waitingRoomPlayer';
import {startGame} from '../../utils/index';

const WaitingRoom = (props) => {

function start(event) {
  event.preventDefault();
  startGame(props.gameState.id);
};

return (
  <div className={styles.WaitingRoom} data-testid="WaitingRoom">
    <div>
      Welcome to the Waiting Room for {props.gameState.id}
    </div>
    <div>Players in room:</div>
    {props.gameState.roster.map((player) => {
      return <WaitingRoomPlayer key={player.name} player={player}></WaitingRoomPlayer>
    })}
    <div>
      <div> {props.gameState.roster.length < 6? "You need at least 7 players to play":"Ready to play?"}</div>
      <button onClick={start} disabled={props.gameState.roster.length < 6}>
        Start Game
      </button>
    </div>
  </div>
)};

WaitingRoom.propTypes = {};

WaitingRoom.defaultProps = {};

export default WaitingRoom;
