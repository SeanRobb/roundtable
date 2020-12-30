import React, { useState } from 'react';
import styles from './betView.module.css';
import { Typography, Grid, Paper, Button, CircularProgress,IconButton } from '@material-ui/core';
import Grade from '@material-ui/icons/Grade';
import CheckIcon from '@material-ui/icons/Check';
import AcUnitIcon from '@material-ui/icons/AcUnit';
import LaunchIcon from '@material-ui/icons/Launch';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import PlusOneIcon from '@material-ui/icons/PlusOne';
import {selectBet,freezeBet,closeBet} from '../../utils/index';
import * as R from 'ramda';


const BetView = (props) => {
  const getPlayerSelection = () => {
    if (props.role.player===undefined){
      return "";
    }
    let player = props.players.find((player) => player.name === props.role.player.name);
    if (player === undefined){
      return "";
    }
    return player.selection;
  }

  const [state, setState] = useState({selection:getPlayerSelection(),isCaptain:props.role.name == "Captain"});

  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(true);

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
  const isCorrectSelection = (selection) =>{
    if (props.bet.correctChoice === ""){
      return false;
    }
    return props.bet.correctChoice === selection
  }

  const renderProgress = () => {
    return (
      <div>
        {loading?<CircularProgress color="inherit" size={24} />:<div/>}
        {success?<CheckIcon />:<div/>}
      </div>
    );
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
          <IconButton 
            onClick={()=> freezeBet(props.gameId, props.bet.id)}
          ><AcUnitIcon/></IconButton>
        )
      case 'FROZEN':
        return (
          <IconButton 
            onClick={()=>closeBet(props.gameId,props.bet.id,state.selection)}
          ><LockOpenIcon/></IconButton>
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
            <Button 
            variant="contained"
            disabled={!isUserRegistered()}
            color={state.selection==selection?"primary":"default"}
            fullWidth={true}
            onClick={()=> { 
              setLoading(true);
              setSuccess(false);
              setState({
                ...state,
                selection: selection,
              });

              selectBet(props.gameId, props.bet.id, selection)
                .then(()=>
                {
                  setTimeout(()=>{
                    setLoading(false);
                    setSuccess(true);
                  }, 500);
                });
            }}>
              <Grid container
                justify='center'
                alignItems='center'>
                <Grid item xs={2} sm={1}> 
                </Grid>
                <Grid item xs={8} sm={10}>
                  {selection}
                </Grid>
                <Grid item xs={2} sm={1}>
                  <Grid container
                  justify='flex-end'>
                    <Grid item>
                      {selection===state.selection?renderProgress():<div/>}
                    </Grid>
                  </Grid>
                </Grid>
              </Grid>
          </Button>
        );
      case 'CLOSING':
        return (
          <div>
            <Button 
              variant="contained"
              disabled={!isUserRegistered()}
              fullWidth={true}
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
            fullWidth={true}
            onClick={()=>setState({
              ...state,
              selection: selection, 
            })}>
            <Grid container
              justify='center'
              alignItems='center'>
              <Grid item xs={2} sm={1}> 
              {state.selection === selection?<Grade />:<div/>}
              </Grid>
              <Grid item xs={8} sm={10}>
                {selection} ({playersThatSelected(selection).length})
              </Grid>
              <Grid item xs={2} sm={1}>
                <Grid container
                  justify='flex-end'>
                    <Grid item>
                      {didPlayerMakeSelection(selection)?<CheckIcon />:<div/>} 
                    </Grid>
                </Grid>
              </Grid>
            </Grid>
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
          <Button 
          variant="contained"
          fullWidth={true}
          disableRipple={true}
          >
          <Grid container
            direction='row'
            justify='space-between'
            alignItems='center'
            >
            <Grid item xs={2} >
              {isCorrectSelection(selection)?<Grade />:<div/>}
            </Grid>
            <Grid item xs={8} >
              <Typography variant={renderTitle(selection)} align='center'>
              {selection} ({playersThatSelected(selection).length})
              </Typography>
            </Grid>
            <Grid item xs={2} >
              <Grid container
                justify='flex-end'>
                <Grid item>
                  {didPlayerMakeSelection(selection)?<CheckIcon />:<div/>}
                </Grid>
              </Grid>
            </Grid>
          </Grid>
          </Button>
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
          direction='column'
          alignItems="stretch"
          justify="center"
        >
          <Grid item xs={12}>
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
                  alignItems='stretch'
                  >
                    <Grid item>
                      <Grid container
                        direction='row'
                        justify='space-between'
                        alignItems='center'>
                        <Grid item xs={2} sm={1}>
                        
                        </Grid>
                        <Grid item xs={8} sm={10}>
                          <Grid container 
                            direction='column'
                            justify='center'
                            alignItems='center'>
                            <Grid item >
                              <Typography variant="h5">{props.bet.title}</Typography>
                            </Grid>
                            <Grid item >
                              <Typography variant="body2">{props.bet.description}</Typography>
                            </Grid>
                          </Grid>
                        </Grid>
                        <Grid item xs={2} sm={1}>
                          <Grid container
                            justify='flex-start'
                            alignItems='flex-end'>
                            <Grid container
                            direction='column'
                            justify='center'
                            alignItems='center'>
                              <Grid item>
                                {renderCaptainButtons()}
                                {isCorrectSelection(getPlayerSelection())?<PlusOneIcon/>:<div/>}
                              </Grid>
                            </Grid>
                          </Grid>
                        </Grid>
                      </Grid>
                    </Grid>
                </Grid>
              </Grid>
              <Grid item>
                <Grid container
                    direction="row"
                    alignItems="center"
                    spacing={2}
                    justify="space-evenly"
                    >
                  <Grid item xs={12} sm={5}>
                    <Paper elevation={3} style={props.style}>
                      {renderOptions(props.bet.choiceA)}
                    </Paper>
                  </Grid>
                  <Grid item xs={12} sm={5}>
                    <Paper elevation={3} style={props.style}>
                      {renderOptions(props.bet.choiceB)}
                    </Paper>
                  </Grid>
                </Grid>
              </Grid>
              <Grid item>
                <Grid container
                alignItems='center'
                justify='space-between'>
                  <Grid item>
                    {<Typography variant="body2">Bets placed: {props.players.length}</Typography>}
                  </Grid> 
                  <Grid item>
                  <IconButton 
                      disabled={props.bet.link === ""}
                      onClick={()=>{
                        var win = window.open(props.bet.link, '_blank');
                        win.focus();
                      }}
                    ><LaunchIcon/></IconButton>
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

BetView.defaultProps = {
  role:{
    player:{
      name:""
    }
  }
};

export default BetView;
