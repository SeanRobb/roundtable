import React, { useState }  from 'react';
import styles from './board.module.css';
import {
  useParams
} from "react-router-dom";
import ReactPolling from 'react-polling';
import WaitingRoom from '../waitingRoom/waitingRoom';
import Playroom from '../playroom/playroom';
import {getHeaders} from '../../utils/index';
import AppBar from '@material-ui/core/AppBar';  
import Toolbar from '@material-ui/core/Toolbar';  
import Box from '@material-ui/core/Box';
import Typography from '@material-ui/core/Typography';


const Board = () => {
  let {game} = useParams();

  const [pageState, setPageState] = useState({
    isLoading:false
  });

  const [state, setState] = useState({
    game:{
      id: game,
      created: null,
      roster: [],
      location: { day: 0, time: 'night' },
      hasStarted: false,
      isFinished: false,
      winner: ''
    },
    vote: [],
    role: ""
  });

  return (
  <div className={styles.board} data-testid="board">
    <ReactPolling
      url={process.env.REACT_APP_API_URL + '/gameroom/' + game }
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
            <AppBar position="static">  
              <Toolbar>
                <Typography variant="h6">
                  Werewolf  
                </Typography>  
              </Toolbar>  
            </AppBar> 
            <div> 
              {!state.game.hasStarted?
              <WaitingRoom state={state.game}></WaitingRoom>
              :<Playroom state={state}></Playroom>}
            </div>
            {/* {JSON.stringify(state)} */}
          </div>
        );
      }}
    />
  </div>
)};


Board.propTypes = {};

Board.defaultProps = {};

export default Board;
