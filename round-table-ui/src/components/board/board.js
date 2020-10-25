import React, { useState }  from 'react';
import styles from './board.module.css';
import {
  useParams
} from "react-router-dom";
import ReactPolling from 'react-polling';
import WaitingRoom from '../waitingRoom/waitingRoom';
import Playroom from '../playroom/playroom';
import GameOverRoom from '../gameOverRoom/gameOverRoom';
import {getHeaders} from '../../utils/index';
import { config } from '../../utils/constants'


const Board = () => {
  let {game} = useParams();

  const [pageState, setPageState] = useState({
    isLoading:false
  });

  const [state, setState] = useState({
    game:{
      id: game.toUpperCase(),
      created: null,
      roster: [],
      location: { day: 0, time: 'night' },
      hasStarted: false,
      isFinished: false,
      winner: ''
    },
    results: [],
    role: ""
  });

  return (
  <div className={styles.board} data-testid="board">
    <ReactPolling
      url={config.url.API_URL + '/gameroom/' + game.toUpperCase() }
      headers={getHeaders()}
      interval= {3000} // in milliseconds(ms)
      retryCount={3} // this is optional
      onSuccess={(data) => {
        setState(data);
        setPageState({isLoading:false});
        return true;
      }}
      onFailure={() => {
        setPageState({isLoading:false});
        console.log('handle failure');
      }} // this is optional
      method={'GET'}
      render={({ startPolling, stopPolling, isPolling }) => {
        return (
          <div>

            <div> 
              {state.game.hasStarted?
                state.game.hasFinished?
                <GameOverRoom game={state.game} />:
                  <Playroom state={state} />:
                <WaitingRoom state={state.game}/>}
            </div>
          </div>
        );
      }}
    />
  </div>
)};


Board.propTypes = {};

Board.defaultProps = {};

export default Board;
