import React, { useState }  from 'react';
import styles from './board.module.css';
import {
  useParams
} from "react-router-dom";
import ReactPolling from 'react-polling';
import WaitingRoom from '../waitingRoom/waitingRoom';
import Playroom from '../playroom/playroom';


const Board = () => {
  let {game} = useParams();

  const [gameState, setGameState] = useState({
    id: game,
    created: null,
    roster: [{name:'HANNAH'}, {name:'TOPH'}, {name:'LAUREN'}],
    location: { day: 0, time: 'night' },
    hasStarted: false,
    isFinished: false,
    winner: ''
  });

  return (
  <div className={styles.board} data-testid="board">
    <ReactPolling
      url={process.env.REACT_APP_API_URL + '/gameroom/' + game }
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
            <div> 
              {!gameState.hasStarted?
              <WaitingRoom gameState={gameState}></WaitingRoom>
              :<Playroom></Playroom>}
            </div>
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
