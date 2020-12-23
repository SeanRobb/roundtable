import React, { useState } from 'react';
import PropTypes from 'prop-types';
import styles from './betView.module.css';
import { Typography, Grid, Paper, Button } from '@material-ui/core';
import Player from '../player/player';
import {selectBet,freezeBet,closeBet} from '../../utils/index';
import * as R from 'ramda';


const BetView = (props) => {
  const [state, setState] = useState({selection:"",isCaptain:props.role.name == "Captain"});

  const isUserRegistered = () => {
    return !R.isEmpty(props.role)
  }
  const playersThatSelected = (selection) => {
    return props.players.filter((player) => player.selection == selection).map((player)=> player.name)
  }
  const didPlayerMakeSelection = (selection) =>{
    if (!isUserRegistered()){
      return false;
    }
    return playersThatSelected(selection).includes(props.role.player.name);
  } 
  const renderCaptainButtons = () =>{
    if (!state.isCaptain) {
     return (
        <div/>
      );
    }
    switch(props.bet.state) {
      case 'OPEN':
        return (
          <Button onClick={()=> freezeBet(props.gameId, props.bet.id)}>Freeze Bet</Button>
        )
      case 'FROZEN':
        return (
          <Button onClick={()=>closeBet(props.gameId,props.bet.id,state.selection)}>Close Bet</Button>
        )
      case 'CLOSED':
        return (
          <div/>
        );
    }

  }
  const renderOptions = (selection) => {
    switch(props.bet.state) {
      case 'OPEN':
        return (
          <div>
            <Button 
            variant="contained"
            disabled={!isUserRegistered()}
            color={didPlayerMakeSelection(selection)?"primary":"default"}
            onClick={()=> selectBet(props.gameId, props.bet.id, selection)}>{selection}
          </Button>
          </div>
        );
      case 'CLOSING':
        return (
          <div>
            <Button 
              variant="contained"
              disabled={!isUserRegistered()}
              color={didPlayerMakeSelection(selection)?"primary":"default"}
              onClick={()=> closeBet(props.gameId, props.bet.id, selection)}>{selection}
            </Button>
          </div>
        );
      case 'FROZEN':
        return (
          <Button 
            variant="contained"
            color={state.selection==selection?"primary":"default"}
            disabled={!state.isCaptain}
            onClick={()=>setState({
              ...state,
              selection: selection, 
            })}>
            {selection} ({playersThatSelected(selection).length}) {didPlayerMakeSelection(selection)?"*":""}
          </Button>
        );
      case 'CLOSED':
        let renderTitle=(selection)=>{
          if (props.bet.correctChoice == selection){
            return "h6";
          } else {
            return "subtitle1";
          }
        }
        return (
          <Grid container
            direction='column'
            style={{padding:'5px'}}
            >
            <Grid item>
              <Typography variant={renderTitle(selection)}>
                {selection} ({playersThatSelected(selection).length}) {didPlayerMakeSelection(selection)?"*":""}
              </Typography>
            </Grid>
          </Grid>
        );
    }
    return (
      <div>
        <Typography variant="subtitle1">{selection}</Typography>
      </div>
    );
  };
  return (
    <div className={styles.betView} data-testid="betView">
      <Paper style={{height:'100%', padding:'5px'}} elevation={2} >
        <Grid container
          alignItems="stretch"
          justify="center"
        >
          <Grid item>
            <Grid container
              direction="column"
              alignItems="stretch"
              justify="center"
              spacing={2}
              >
              <Grid item>
                <Grid container
                  direction="column"
                  justify='center'
                  alignItems='center'
                  >
                  <Grid item>
                    <Typography variant="body1">{props.bet.title}</Typography>
                  </Grid>
                  <Grid item>
                    <Typography variant="body2">{props.bet.description}</Typography>
                  </Grid>
                </Grid>
              </Grid>
              <Grid item>
                <Grid container
                      direction="row"
                      alignItems="stretch"
                      justify="space-evenly"
                      >
                  <Paper elevation={3} style={props.style}>
                    <Grid item>
                        {renderOptions(props.bet.choiceA)}
                    </Grid>
                  </Paper>
                  <Paper elevation={3} style={props.style}>
                    <Grid item>
                        {renderOptions(props.bet.choiceB)}
                    </Grid>
                  </Paper>
                </Grid>
                  <Grid container
                    alignItems="center"
                    justify="center">
                    <Grid item>
                      {renderCaptainButtons()}
                    </Grid>
                  </Grid>
              </Grid>
            </Grid>
          </Grid>
        </Grid>
      </Paper>
    </div>
  );
  }

BetView.propTypes = {};

BetView.defaultProps = {};

export default BetView;
