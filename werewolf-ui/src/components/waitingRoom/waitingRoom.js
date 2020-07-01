import React from 'react';
import PropTypes from 'prop-types';
import styles from './waitingRoom.module.css';
import WaitingRoomPlayer from '../waitingRoomPlayer/waitingRoomPlayer';
import {startGame} from '../../utils/index';
import Button from '@material-ui/core/Button';  

const WaitingRoom = (props) => {

function start(event) {
  event.preventDefault();
  startGame(props.state.id);
};

return (
  <div className={styles.WaitingRoom} data-testid="WaitingRoom">
    <div>
      Welcome to the Waiting Room for {props.state.id}
    </div>
    <div>Players in room:</div>
    {props.state.roster.map((player) => {
      return <WaitingRoomPlayer key={player.name} player={player}></WaitingRoomPlayer>
    })}
    <div>
      <div> {props.state.roster.length < 6? "You need at least 7 players to play":"Ready to play?"}</div>
      <Button variant="outlined" onClick={start} disabled={props.state.roster.length < 6}>
        Start Game
      </Button>
    </div>
  </div>
)};

WaitingRoom.propTypes = {};

WaitingRoom.defaultProps = {};

export default WaitingRoom;
