import React, { useState, useEffect }  from 'react';
import PropTypes from 'prop-types';
import styles from './board.module.css';
import {
  useParams
} from "react-router-dom";
import {fetchStatus} from '../../utils/index';
import ReactPolling from 'react-polling';


const Board = () => {
  let {game} = useParams();

  const [gameState, setGameState] = useState({
    id: game,
    created: 1592600150593,
    activePlayers: ['HANNAH', 'TOPH', 'LAUREN'],
    narrator:'SEAN',
    vote: {
      TOPH: ['LAUREN', 'HANNAH'],
    },
    werewolves: 1,
    location: { day: 0, time: 'night' },
    hasStarted: false,
    isFinished: false,
    winner: ''
  });

  return (
  <div className={styles.board} data-testid="board">
    <ReactPolling
      url={'https://trs2utmz46.execute-api.us-east-1.amazonaws.com/dev/gameroom/' + game }
      interval= {3000} // in milliseconds(ms)
      retryCount={3} // this is optional
      onSuccess={(data) => {
        setGameState(data);
        return true;
      }}
      onFailure={() => console.log('handle failure')} // this is optional
      method={'GET'}
      render={({ startPolling, stopPolling, isPolling }) => {
        return (
          <div> 
            {JSON.stringify(gameState)}
          </div>
        );
      }}
    />
  </div>
)};


Board.propTypes = {};

Board.defaultProps = {};

export default Board;
